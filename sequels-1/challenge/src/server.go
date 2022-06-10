package main

import (
	"database/sql"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"

	_ "github.com/go-sql-driver/mysql"
)

var (
	jediHtmlTemplate = template.Must(template.ParseFiles("search.html"))
)

type JediSearch struct {
	db *sql.DB
}

type JediEntry struct {
	Name   string
	Type   string
	Planet string
}

func NewJediSearch(dsn string) (*JediSearch, error) {
	db, err := sql.Open("mysql", dsn)
	if err != nil {
		return nil, err
	}
	return &JediSearch{
		db: db,
	}, nil
}

func (js *JediSearch) FindJediMatching(name string, limit int) ([]JediEntry, error) {
	qry := fmt.Sprintf("SELECT name, `type`, planet FROM jedi WHERE name LIKE '%s%%' LIMIT %d", name, limit)
	rows, err := js.db.Query(qry)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var rv []JediEntry
	for rows.Next() {
		entry := JediEntry{}
		if err := rows.Scan(&entry.Name, &entry.Type, &entry.Planet); err != nil {
			return nil, err
		}
		rv = append(rv, entry)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return rv, nil
}

type JediSearchTemplate struct {
	ErrorMsg string
	Results  []JediEntry
	Query    string
}

func (js *JediSearch) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	query := ""
	if r.Method == http.MethodPost {
		query = r.FormValue("q")
	}
	jst := JediSearchTemplate{
		Query: query,
	}
	if rv, err := js.FindJediMatching(query, 10); err != nil {
		jst.ErrorMsg = err.Error()
	} else {
		jst.Results = rv
	}
	jediHtmlTemplate.Execute(w, jst)
}

func GetenvDefault(key, def string) string {
	res := os.Getenv(key)
	if res != "" {
		return res
	}
	return def
}

func main() {
	fs := http.FileServer(http.Dir("./static"))
	http.Handle("/static/", http.StripPrefix("/static/", fs))

	if js, err := NewJediSearch(GetenvDefault("DSN", "sequels1:xohquief2Chu@tcp(127.0.0.1:3306)/sequels1")); err != nil {
		panic(err)
	} else {
		http.Handle("/", js)
	}

	endpoint := GetenvDefault("LISTEN_ENDPOINT", ":3000")
	log.Printf("Listening on %s", endpoint)
	log.Fatal(http.ListenAndServe(endpoint, nil))
}
