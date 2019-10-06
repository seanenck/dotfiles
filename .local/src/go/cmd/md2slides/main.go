package main

import (
	"crypto/md5"
	"encoding/json"
	"flag"
	"fmt"
	"html/template"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
)

const (
	pdfUnite     = "pdfunite"
	wkHTMLToPDF  = "wkhtmltopdf"
	pygmentize   = "pygmentize"
	templateHTML = `<!doctype html>
<html lang='en'>
<head><style>
{{ $.Style }}
</style></head>
<body>
<div class="slide">{{ $.Progress }}</div>
<div class="{{ $.ID }} {{ $.DirID }} {{ $.ObjectID }}">
{{ $.Content }}
</div>
</body>
</html>
`
	defaultCSS = `
body {
    padding-left: 0.5in;
    padding-right: 0.5in;
    padding-top: 0.5in;
    padding-bottom: 0.5in;
    font-size: 32px;
    line-height: 1.5;
    font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
}
h1 {
    background-color: #c2d6d6;
    text-align: center;
    font-size: 48px;
}
li:nth-child(odd){
    background: #e6f2ff;
}
li {
    background: #cce6ff;
    list-style-type: square;
    margin: 3px 0;
}
.slide {
    font-size: 18px;
}

table {
  width: 100%;
}

th, td {
  text-align: left;
  padding: 4px;
}

tr:nth-child(even) {
    background-color: #f2f2f2
}

tr {
    background-color: #e6e6e6;
}

th {
  background-color: #666699;
  color: #ffffff;
}
`
)

type (
	runRequest struct {
		outputDirectory string
		cssFile         string
		mergeCSS        bool
		noHighlight     bool
		noIndex         bool
		useCSS          string
		templateHTML    *template.Template
	}

	// Slide represents an output slide
	Slide struct {
		Style    template.CSS
		Progress string
		ID       string
		DirID    string
		ObjectID string
		Content  string
	}

	buildObject struct {
		input string
		md    string
		html  string
		pdf   string
		ident int
	}
)

func (r *runRequest) check(run bool) error {
	if run {
		if !exists(r.outputDirectory) {
			if err := os.Mkdir(r.outputDirectory, 0755); err != nil {
				return err
			}
		}
	}
	if r.cssFile == "" {
		if r.mergeCSS {
			return fmt.Errorf("merge CSS invalid with no CSS file")
		}
		r.useCSS = defaultCSS
	} else {
		if !exists(r.cssFile) {
			return fmt.Errorf("css file does not exist: %s", r.cssFile)
		}
		b, err := ioutil.ReadFile(r.cssFile)
		if err != nil {
			return err
		}
		if r.mergeCSS {
			r.useCSS = fmt.Sprintf("%s\n%s", defaultCSS, string(b))
		} else {
			r.useCSS = string(b)
		}
	}
	if err := pythonMarkdown("--version"); err != nil {
		return fmt.Errorf("python markdown issue: %v", err)
	}
	for _, cmd := range [...]string{pdfUnite, wkHTMLToPDF, pygmentize} {
		if err := isCommandAvailable(cmd); err != nil {
			return fmt.Errorf("%s command not found: %v", cmd, err)
		}
	}
	return nil
}

func exists(file string) bool {
	if _, err := os.Stat(file); os.IsNotExist(err) {
		return false
	}
	return true
}

func fatal(message string, err error) {
	msg := message
	if err != nil {
		msg = fmt.Sprintf("%s -> %v", msg, err)
	}
	fmt.Println(msg)
	os.Exit(1)
}

func (r *runRequest) listMarkdownFiles() ([]string, error) {
	var files []string
	rooted, err := os.Getwd()
	if err != nil {
		return nil, err
	}
	err = filepath.Walk(".", func(path string, info os.FileInfo, err error) error {
		n := info.Name()
		ext := filepath.Ext(n)
		if ext != ".md" {
			return nil
		}
		full, err := filepath.Abs(path)
		if err != nil {
			return err
		}
		rel, err := filepath.Rel(rooted, full)
		if err != nil {
			return err
		}
		m, err := filepath.Match(filepath.Join(r.outputDirectory, "*"), rel)
		if err != nil {
			return err
		}
		if m {
			return nil
		}
		files = append(files, path)
		return nil
	})
	if err != nil {
		return nil, err
	}
	sort.Strings(files)
	return files, nil
}

/*
func newHTML() {
	Slide struct {
		Style    template.CSS
		Progress string
		ID       string
		DirID    string
		ObjectID string
		Content  string
	}
}*/

func isCommandAvailable(name string) error {
	cmd := exec.Command("which", name)
	if err := cmd.Run(); err != nil {
		return err
	}
	return nil
}

func pythonMarkdown(parameters ...string) error {
	args := []string{"-m", "markdown", "-x", "markdown.extensions.tables"}
	if parameters == nil || len(parameters) == 0 {
		return fmt.Errorf("invalid parameters (none given)")
	}
	args = append(args, parameters...)
	cmd := exec.Command("python", args...)
	if err := cmd.Run(); err != nil {
		return err
	}
	return nil
}

func (o buildObject) log(message string) {
	fmt.Println(fmt.Sprintf("%3d -> %s", o.ident, message))
}

func (o buildObject) err(message string, err error) {
	o.log(fmt.Sprintf("ERROR %s (%v)", message, err))
}

func build(channel chan string, obj buildObject, state map[string]string) {
	fmt.Println("converting", obj.input, obj.md)
	b, err := ioutil.ReadFile(obj.input)
	if err != nil {
		obj.err("unable to read input file", err)
		channel <- ""
	}
	hash := fmt.Sprintf("%x", md5.Sum(b))
	old, ok := state[obj.input]
	if ok {
		if old == hash {
			channel <- hash
		}
	}
	channel <- hash
}

func (r *runRequest) process() error {
	files, err := r.listMarkdownFiles()
	if err != nil {
		return err
	}
	if len(files) == 0 {
		fatal("no files found", nil)
	}
	state := make(map[string]string)
	stateFile := filepath.Join(r.outputDirectory, "state.json")
	if exists(stateFile) {
		b, err := ioutil.ReadFile(stateFile)
		if err != nil {
			return err
		}
		if err := json.Unmarshal(b, &state); err != nil {
			return err
		}
	}
	chans := make(map[string]chan string)
	for idx, f := range files {
		c := make(chan string)
		root := filepath.Join(r.outputDirectory, fmt.Sprintf("%d.", idx))
		obj := buildObject{
			input: f,
			md:    root + "md",
			html:  root + "html",
			pdf:   root + "pdf",
			ident: idx,
		}
		go build(c, obj, state)
		chans[f] = c
	}
	newState := make(map[string]string)
	for k, c := range chans {
		result := <-c
		if result == "" {
			fatal("error building file", nil)
		}
		newState[k] = result
	}
	b, err := json.MarshalIndent(newState, "", "  ")
	if err != nil {
		return err
	}
	if err := ioutil.WriteFile(stateFile, b, 0644); err != nil {
		return err
	}
	return nil
}

func main() {
	output := flag.String("output", "bin/", "output directory")
	css := flag.String("css", "", "CSS to use (can be overriden by pygments)")
	mergeCSS := flag.Bool("merge-css", false, "merge given CSS with default css (else override)")
	noHighlight := flag.Bool("no-highlighting", false, "disable pygments highlighting")
	printCSS := flag.Bool("print-css", false, "print CSS (don't process)")
	noIndex := flag.Bool("no-index", false, "disable index output (header numbering)")
	flag.Parse()
	tmpl, err := template.New("t").Parse(templateHTML)
	if err != nil {
		fatal("invalid template", err)
	}
	r := &runRequest{
		outputDirectory: filepath.Dir(*output),
		cssFile:         *css,
		mergeCSS:        *mergeCSS,
		noHighlight:     *noHighlight,
		noIndex:         *noIndex,
		templateHTML:    tmpl,
	}
	printCSSOnly := *printCSS
	if err := r.check(!printCSSOnly); err != nil {
		fatal("unable to process", err)
	}
	if printCSSOnly {
		fmt.Println(r.useCSS)
		return
	}
	if err := r.process(); err != nil {
		fatal("processing failed", err)
	}
}
