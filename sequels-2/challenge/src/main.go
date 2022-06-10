package main

import (
	"crypto/sha256"
	"database/sql"
	"encoding/base64"
	"encoding/hex"
	"fmt"
	"html/template"
	"io/ioutil"
	"log"
	"math/rand"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"time"

	exif "github.com/dsoprea/go-exif/v2"
	jpegstructure "github.com/dsoprea/go-jpeg-image-structure"
	pngstructure "github.com/dsoprea/go-png-image-structure/v2"
	_ "github.com/go-sql-driver/mysql"
)

const (
	FORM_FILE_NAME      = "fileupload"
	MAX_SIZE            = 1 * 1024 * 1024
	FILE_EXPIRE_MINUTES = 60
)

var (
	indexTemplate = template.Must(template.ParseFiles("templates/base.html", "templates/index.html"))
	viewTemplate  = template.Must(template.ParseFiles("templates/base.html", "templates/view.html"))
	fidRe         = regexp.MustCompile("^[0-9a-f]{64}$")
)

type IndexHandler struct {
	db *sql.DB
}

func (h *IndexHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodPost {
		h.ServePOST(w, r)
		return
	}
	h.sendTemplate(w, nil)
}

func (h *IndexHandler) ServePOST(w http.ResponseWriter, r *http.Request) {
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
	fname := filepath.Base(fh.Filename)
	ext := filepath.Ext(fname)
	if ext == ".jpg" || ext == ".jpeg" || ext == ".png" {
		if fpbuf, err := ioutil.ReadAll(fp); err != nil {
			log.Printf("Error reading form file: %v", err)
			w.WriteHeader(http.StatusInternalServerError)
			return
		} else {
			if fid, err := h.SaveFileData(fname, r.RemoteAddr, fpbuf); err != nil {
				log.Printf("Error parsing file: %v", err)
				w.WriteHeader(http.StatusInternalServerError)
				fmt.Fprintf(w, "Error: %v", err)
				return
			} else {
				log.Printf("Redirecting to fid %v", fid)
				http.Redirect(w, r, fmt.Sprintf("/view/%s", fid), http.StatusFound)
				return
			}
		}
	} else {
		h.sendTemplate(w, indexTemplateData{Error: "Only JPG/PNG supported."})
		return
	}
}

func (h *IndexHandler) SaveFileData(fname, remote_addr string, buf []byte) (string, error) {
	hasher := sha256.New()
	hasher.Write(buf)
	fid := hex.EncodeToString(hasher.Sum(nil))
	var tagMap map[string]string

	if tags, err := getExifTags(buf); err != nil {
		return "", err
	} else {
		for _, t := range tags {
			log.Printf("TAG: %s", t)
		}
		tagMap = mapExifTags(tags)
	}

	tx, err := h.db.Begin()
	if err != nil {
		return "", err
	}
	defer tx.Rollback()

	addrPieces := strings.Split(remote_addr, ":")
	addr_host := strings.Join(addrPieces[0:len(addrPieces)-1], ":")

	if _, err = tx.Exec("INSERT INTO files (fid, filename, remote_addr, rawimg) VALUES(?, ?, ?, ?)", fid, fname, addr_host, buf); err != nil {
		return "", err
	}
	var pieces []string
	for k, v := range tagMap {
		pieces = append(pieces, fmt.Sprintf("(\"%s\", \"%s\", \"%s\")", fid, k, v))
	}
	qry := fmt.Sprintf("INSERT INTO exifs (fid, name, value) VALUES %s", strings.Join(pieces, ", "))
	log.Printf("exifs: %s", qry)
	if _, err := tx.Exec(qry); err != nil {
		return "", err
	}

	if err := tx.Commit(); err != nil {
		return "", err
	}

	return fid, nil
}

func mapExifTags(tags []exif.ExifTag) map[string]string {
	rv := make(map[string]string)
	for _, t := range tags {
		if _, ok := rv[t.TagName]; ok {
			log.Printf("Warning: duplicate tag %s", t.TagName)
		}
		rv[t.TagName] = t.Formatted
	}
	return rv
}

func getExifTags(buf []byte) ([]exif.ExifTag, error) {
	jmp := jpegstructure.NewJpegMediaParser()
	if jmp.LooksLikeFormat(buf) {
		ec, err := jmp.ParseBytes(buf)
		if err != nil {
			return nil, err
		}
		if sl, ok := ec.(*jpegstructure.SegmentList); ok {
			_, _, tags, err := sl.DumpExif()
			if err != nil {
				return nil, err
			}
			return tags, nil
		} else {
			return nil, fmt.Errorf("Could not get SegmentList!")
		}
	}
	pmp := pngstructure.NewPngMediaParser()
	if pmp.LooksLikeFormat(buf) {
		ec, err := pmp.ParseBytes(buf)
		if err != nil {
			return nil, err
		}
		if cs, ok := ec.(*pngstructure.ChunkSlice); ok {
			_, exifData, err := cs.Exif()
			if err != nil {
				return nil, err
			}
			return exif.GetFlatExifData(exifData)
		} else {
			return nil, fmt.Errorf("Could not get ChunkSlice!")
		}
	}
	return nil, fmt.Errorf("Unable to find EXIF data.")
}

type indexTemplateData struct {
	Error string
}

func (h *IndexHandler) sendTemplate(w http.ResponseWriter, data interface{}) {
	if err := indexTemplate.Execute(w, data); err != nil {
		log.Printf("Error in template: %s", err)
	}
}

type ViewHandler struct {
	db *sql.DB
}

func maybeValidFID(fid string) bool {
	return fidRe.MatchString(fid)
}

type ViewResponse struct {
	Fid        string
	UploadTS   string
	RemoteAddr string
	Filename   string
	ImageData  template.URL
	EXIFs      []VRExif
}

type VRExif struct {
	Name  string
	Value string
}

func (h *ViewHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	fid := filepath.Base(r.RequestURI)
	log.Printf("fid: %s", fid)
	if !maybeValidFID(fid) {
		http.Error(w, "Bad Request", http.StatusBadRequest)
		return
	}
	vr := ViewResponse{}
	var buf []byte
	row := h.db.QueryRow("SELECT fid, filename, remote_addr, uploadts, rawimg FROM files WHERE fid = ? LIMIT 1", fid)
	if err := row.Scan(&vr.Fid, &vr.Filename, &vr.RemoteAddr, &vr.UploadTS, &buf); err != nil {
		if err == sql.ErrNoRows {
			http.Error(w, "Not Found", http.StatusNotFound)
			return
		} else {
			log.Printf("Error locating file: %s", err)
			http.Error(w, "Internal Server Error", http.StatusInternalServerError)
			return
		}
	}
	log.Printf("Buf len: %d", len(buf))
	vr.ImageData = template.URL(imgToDataURI(buf))
	// Now load exif data
	rows, err := h.db.Query("SELECT name, value FROM exifs WHERE fid=?", fid)
	if err != nil {
		log.Printf("Error getting exif data: %v", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}
	for rows.Next() {
		e := VRExif{}
		if err := rows.Scan(&e.Name, &e.Value); err != nil {
			log.Printf("Error getting exif data: %v", err)
			http.Error(w, "Internal Server Error", http.StatusInternalServerError)
			return
		}
		vr.EXIFs = append(vr.EXIFs, e)
	}

	viewTemplate.Execute(w, vr)
}

type ForceDeleteHandler struct {
	db *sql.DB
}

func (h *ForceDeleteHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	fid := filepath.Base(r.RequestURI)
	log.Printf("fid: %s", fid)
	if !maybeValidFID(fid) {
		http.Error(w, "Bad Request", http.StatusBadRequest)
		return
	}
	if _, err := h.db.Exec("delete from files where fid = ?", fid); err != nil {
		log.Printf("Error in force deleting files: %v", err)
		http.Error(w, "Internal Error", http.StatusInternalServerError)
		return
	}
	w.Write([]byte("OK"))
}

func imgToDataURI(data []byte) string {
	contenttype := ""
	jmp := jpegstructure.NewJpegMediaParser()
	pmp := pngstructure.NewPngMediaParser()
	if jmp.LooksLikeFormat(data) {
		contenttype = "image/jpeg"
	} else if pmp.LooksLikeFormat(data) {
		contenttype = "image/png"
	} else {
		return "data:text/plain,Encoding Failed!"
	}
	encdata := base64.StdEncoding.EncodeToString(data)
	return fmt.Sprintf("data:%s;base64,%s", contenttype, encdata)
}

func looksLikeImage(data []byte) bool {
	jmp := jpegstructure.NewJpegMediaParser()
	if jmp.LooksLikeFormat(data) {
		return true
	}
	pmp := pngstructure.NewPngMediaParser()
	if pmp.LooksLikeFormat(data) {
		return true
	}
	return false
}

func GetenvDefault(key, def string) string {
	if rv := os.Getenv(key); rv != "" {
		return rv
	}
	return def
}

func pruneOldFiles(db *sql.DB) {
	if _, err := db.Exec("delete from files where uploadts < DATE_SUB(NOW(), INTERVAL ? MINUTE);", FILE_EXPIRE_MINUTES); err != nil {
		log.Printf("Error in pruning old files: %v", err)
	}
}

func startPruningOldFiles(db *sql.DB) {
	go func() {
		// loop forever
		for {
			log.Printf("Pruning old files...")
			pruneOldFiles(db)
			n := time.Duration(rand.Int31n(60) - 30)
			time.Sleep(FILE_EXPIRE_MINUTES*time.Minute + n*time.Second)
		}
	}()
}

func main() {
	db, err := sql.Open("mysql", GetenvDefault("DSN", "sequels2:ohRies1jeequ@tcp(127.0.0.1:3306)/sequels2"))
	if err != nil {
		log.Panic(err)
	}
	startPruningOldFiles(db)
	fs := http.FileServer(http.Dir("./static"))
	http.Handle("/static/", http.StripPrefix("/static/", fs))
	fd := &ForceDeleteHandler{db}
	http.Handle("/forcedelete/", fd)
	vh := &ViewHandler{db}
	http.Handle("/view/", vh)
	idx := &IndexHandler{db}
	http.Handle("/", idx)
	endpoint := ":3000"
	log.Printf("Listening on %s", endpoint)
	log.Fatal(http.ListenAndServe(endpoint, nil))
}
