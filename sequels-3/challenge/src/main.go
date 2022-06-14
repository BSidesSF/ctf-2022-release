package main

import (
	"bytes"
	"database/sql"
	"encoding/base64"
	"fmt"
	"html/template"
	"image"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/google/uuid"
	qrcode "github.com/skip2/go-qrcode"

	"github.com/bsidessf/ctf-2022/sequels/quirc"

	_ "image/jpeg"
	_ "image/png"

	_ "github.com/go-sql-driver/mysql"
)

const (
	FORM_FILE_NAME = "fileupload"
	MAX_SIZE       = 1 * 1024 * 1024
)

var (
	indexTemplate = template.Must(template.ParseFiles("templates/base.html", "templates/index.html"))
	viewTemplate  = template.Must(template.ParseFiles("templates/base.html", "templates/view.html"))
)

type QRCodeServer struct {
	db *sql.DB
}

func (s *QRCodeServer) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	log.Printf("[%s] %s: %s %s", time.Now().Format(time.RFC822), r.RemoteAddr, r.Method, r.RequestURI)
	if r.Method == http.MethodPost {
		s.ServePOST(w, r)
		return
	}
	if r.RequestURI == "/" {
		s.serveForm(w, r, nil)
		return
	}
	basePath := filepath.Base(r.RequestURI)
	id, err := uuid.Parse(basePath)
	if err != nil {
		log.Printf("Invalid request for %v", r.RequestURI)
		http.Error(w, "Not Found", http.StatusNotFound)
		return
	}
	// Now serving 1 code!
	row := s.db.QueryRow("SELECT qrdata FROM codes WHERE cid=? LIMIT 1", id.String())
	var buf []byte
	if err := row.Scan(&buf); err != nil {
		log.Printf("Error loading qrdata: %v", err)
		http.Error(w, "Not Found", http.StatusNotFound)
		return
	}
	code, err := qrcode.New(string(buf), qrcode.High)
	if err != nil {
		log.Printf("Error encoding: %v", err)
		http.Error(w, "Server Error", http.StatusInternalServerError)
		return
	}
	imgbuf, err := code.PNG(-3)
	if err != nil {
		log.Printf("Error encoding PNG: %v", err)
		http.Error(w, "Server Error", http.StatusInternalServerError)
		return
	}
	datauri := template.URL(imgToDataURI(imgbuf))
	if err := viewTemplate.Execute(w, &imageView{ImageData: datauri}); err != nil {
		log.Printf("Error rendering view template: %v", err)
	}
}

type imageView struct {
	ImageData template.URL
}

func imgToDataURI(data []byte) string {
	contenttype := "image/png"
	encdata := base64.StdEncoding.EncodeToString(data)
	return fmt.Sprintf("data:%s;base64,%s", contenttype, encdata)
}

func (s *QRCodeServer) ServePOST(w http.ResponseWriter, r *http.Request) {
	ct := r.Header.Get("Content-type")
	ctpieces := strings.Split(ct, ";")
	ct = strings.TrimSpace(ctpieces[0])
	if ct != "multipart/form-data" {
		log.Printf("Got content-type %s, expected multipart/form-data.", ct)
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	fp, fh, err := r.FormFile(FORM_FILE_NAME)
	if err != nil {
		log.Printf("Error getting form field: %s", err)
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	if fh.Size > MAX_SIZE {
		log.Printf("Size (%d) exceeds MAX_SIZE (%d)", fh.Size, MAX_SIZE)
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	defer fp.Close()
	img, _, err := image.Decode(fp)
	if err != nil {
		log.Printf("Error parsing image: %v", err)
		s.serveForm(w, r, &tmplData{
			Error: "Unable to parse image!",
		})
		return
	}
	qrdata, err := quirc.QuircDecode(img)
	if err != nil {
		log.Printf("Error extracting qrcode: %v", err)
		s.serveForm(w, r, &tmplData{
			Error: "Unable to find/decode QR code!",
		})
		return
	}
	if !utf8.Valid(qrdata) {
		s.serveForm(w, r, &tmplData{
			Error: "QR Code contains invalid UTF-8",
		})
		return
	}
	// "sql injection prevention"
	qrdata = bytes.ReplaceAll(qrdata, []byte("\""), []byte("\\\""))
	if len(qrdata) > 4095 {
		s.serveForm(w, r, &tmplData{
			Error: "Data was too long!",
		})
		return
	}
	id := uuid.NewString()
	query := fmt.Sprintf("INSERT INTO codes (cid, qrdata) VALUES(\"%s\", \"%s\")", id, qrdata)
	if _, err := s.db.Exec(query); err != nil {
		log.Printf("DB error: %v (%q)", err, qrdata)
		s.serveForm(w, r, &tmplData{
			Error: "Error saving QR code, please try again later.",
		})
		return
	}
	http.Redirect(w, r, fmt.Sprintf("/%s", id), http.StatusFound)
}

type tmplData struct {
	Error string
}

func (s *QRCodeServer) serveForm(w http.ResponseWriter, r *http.Request, data *tmplData) {
	if data == nil {
		data = &tmplData{}
	}
	if err := indexTemplate.Execute(w, data); err != nil {
		log.Printf("Error rendering index template: %v", err)
	}
}

func GetenvDefault(key, def string) string {
	if rv := os.Getenv(key); rv != "" {
		return rv
	}
	return def
}

func main() {
	db, err := sql.Open("mysql", GetenvDefault("DSN", "sequels3:shugh5cah7At@tcp(127.0.0.1:3306)/sequels3"))
	if err != nil {
		log.Panic(err)
	}
	server := &QRCodeServer{db: db}
	endpoint := GetenvDefault("ENDPOINT", ":3000")
	log.Printf("Listening on %s", endpoint)
	log.Fatal(http.ListenAndServe(endpoint, server))
}
