package main

import (
	"fmt"
	"html/template"
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"
	"regexp"
)

const (
	COWSAY_PATH = "/usr/games/cowsay"
)

var (
	modeRE = regexp.MustCompilePOSIX("^-(b|d|g|p|s|t|w)$")
)

// Note: mode must be validated prior to running this!
func cowsay(mode, message string) (string, error) {
	cowcmd := fmt.Sprintf("%s %s -n", COWSAY_PATH, mode)
	log.Printf("Running cowsay as: %s", cowcmd)
	cmd := exec.Command("/bin/sh", "-c", cowcmd)
	stdin, err := cmd.StdinPipe()
	if err != nil {
		return "", err
	}
	go func() {
		defer stdin.Close()
		io.WriteString(stdin, message)
	}()
	outbuf, err := cmd.Output()
	if err != nil {
		return "", err
	}
	return string(outbuf), nil
}

func checkMode(mode string) error {
	if mode == "" {
		return nil
	}
	if !modeRE.MatchString(mode) {
		return fmt.Errorf("Mode must match regexp: %s", modeRE.String())
	}
	return nil
}

const cowTemplateSource = `
<!doctype html>
<html>
	<h1>Cow Say What?</h1>
	<p>I love <a href='https://www.mankier.com/1/cowsay'>cowsay</a> so much that
	I wanted to bring it to the web.  Enjoy!</p>
	{{if .Error}}
	<p><b>{{.Error}}</b></p>
	{{end}}
	<form method="POST" action="/">
	<select name="mode">
		<option value="">Plain</option>
		<option value="-b">Borg</option>
		<option value="-d">Dead</option>
		<option value="-g">Greedy</option>
		<option value="-p">Paranoid</option>
		<option value="-s">Stoned</option>
		<option value="-t">Tired</option>
		<option value="-w">Wired</option>
	</select><br />
	<textarea name="message" placeholder="message" cols="60" rows="10">{{.Message}}</textarea><br />
	<input type='submit' value='Say'><br />
	</form>
	{{if .CowSay}}
	<pre>{{.CowSay}}</pre>
	{{end}}
	<p>Check out <a href='/cowsay.go'>how it works</a>.</p>
</html>
`

var cowTemplate = template.Must(template.New("cowsay").Parse(cowTemplateSource))

type tmplVars struct {
	Error   string
	CowSay  string
	Message string
}

func cowsayHandler(w http.ResponseWriter, r *http.Request) {
	vars := tmplVars{}
	if r.Method == http.MethodPost {
		mode := r.FormValue("mode")
		message := r.FormValue("message")
		vars.Message = message
		if err := checkMode(mode); err != nil {
			vars.Error = err.Error()
		} else {
			if said, err := cowsay(mode, message); err != nil {
				log.Printf("Error running cowsay: %v", err)
				vars.Error = "An error occurred running cowsay."
			} else {
				vars.CowSay = said
			}
		}
	}
	cowTemplate.Execute(w, vars)
}

func sourceHandler(w http.ResponseWriter, r *http.Request) {
	http.ServeFile(w, r, "cowsay.go")
}

func main() {
	addr := "0.0.0.0:6789"
	if len(os.Args) > 1 {
		addr = os.Args[1]
	}
	http.HandleFunc("/cowsay.go", sourceHandler)
	http.HandleFunc("/", cowsayHandler)
	log.Fatal(http.ListenAndServe(addr, nil))
}
