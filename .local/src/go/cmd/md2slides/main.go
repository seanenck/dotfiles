package main

import (
	"bytes"
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
	"strings"
)

const (
	defaultLexer = "text"
	pdfUnite     = "pdfunite"
	wkHTMLToPDF  = "wkhtmltopdf"
	pygmentize   = "pygmentize"
	codeBlock    = "```"
	formatter    = "html"
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
		Content  template.HTML
	}

	buildObject struct {
		input string
		md    string
		html  string
		pdf   string
		ident int
		total int
		req   *runRequest
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

func isCommandAvailable(name string) error {
	cmd := exec.Command("which", name)
	if err := cmd.Run(); err != nil {
		return err
	}
	return nil
}

func pythonPygments(file string, parameters ...string) error {
	if parameters == nil || len(parameters) == 0 {
		return fmt.Errorf("invalid parameters (none given)")
	}
	stdout, err := os.Create(file)
	if err != nil {
		return err
	}
	defer stdout.Close()
	cmd := exec.Command("pygmentize", parameters...)
	cmd.Stdout = stdout
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

func (o buildObject) hashFile() string {
	return o.md
}

func (o buildObject) warn(message string) {
	o.log(fmt.Sprintf("WARN %s", message))
}

func (o buildObject) pygmentize(md string) ([]byte, string, error) {
	cssFile := o.md + ".css"
	err := pythonPygments(cssFile, "-S", "colorful", "-f", formatter)
	if err != nil {
		return nil, "", err
	}
	b, err := ioutil.ReadFile(cssFile)
	if err != nil {
		return nil, "", err
	}
	usedDefaultLexer := false
	in := false
	var lines []string
	var codeLines []string
	lexer := defaultLexer
	inLines := strings.Split(md, "\n")
	for idx, l := range inLines {
		strip := strings.TrimSpace(l)
		if strings.HasPrefix(strip, codeBlock) {
			if in {
				code := strings.Join(codeLines, "\n")
				if lexer == defaultLexer {
					usedDefaultLexer = true
				}
				fragment := fmt.Sprintf("%s%d", o.md, idx)
				codeFragment := fragment + ".txt"
				htmlFragment := fragment + ".html"
				if err := ioutil.WriteFile(codeFragment, []byte(code), 0644); err != nil {
					return nil, "", err
				}
				if err := pythonPygments(htmlFragment, "-f", formatter, "-l", lexer, codeFragment); err != nil {
					return nil, "", err
				}
				raw, err := ioutil.ReadFile(htmlFragment)
				if err != nil {
					return nil, "", err
				}
				lines = append(lines, string(raw))
				codeLines = []string{}
				lexer = defaultLexer
				in = false
			} else {
				in = true
				lexer = strings.TrimSpace(strings.Replace(strip, codeBlock, "", -1))
				if lexer == "" {
					lexer = defaultLexer
				}
			}
			continue
		}
		if in {
			codeLines = append(codeLines, l)
			continue
		}
		lines = append(lines, l)
	}
	if in {
		return nil, "", fmt.Errorf("unclosed code block")
	}
	if usedDefaultLexer {
		o.warn(fmt.Sprintf("used default lexer: %s", defaultLexer))
	}
	return []byte(strings.Join(lines, "\n")), string(b), nil
}

func cleanPath(path string, withFile bool) string {
	use := path
	if !withFile {
		use = filepath.Dir(path)
	}
	for _, c := range [...]string{"/", ".", "_"} {
		use = strings.Replace(use, c, "-", -1)
	}
	return fmt.Sprintf("md-%s", use)
}

func build(channel chan string, obj buildObject, state map[string]string) {
	obj.log(fmt.Sprintf("%s -> %s", obj.input, obj.md))
	b, err := ioutil.ReadFile(obj.input)
	if err != nil {
		obj.err("unable to read input file", err)
		channel <- ""
		return
	}
	hash := fmt.Sprintf("%x", md5.Sum(b))
	old, ok := state[obj.hashFile()]
	if ok && exists(obj.html) && exists(obj.pdf) {
		if old == hash {
			obj.log(fmt.Sprintf("unchanged: %s", obj.input))
			channel <- hash
			return
		}
	}
	mdRaw := string(b)
	highlight := strings.Contains(mdRaw, codeBlock)
	css := obj.req.useCSS
	if highlight {
		if obj.req.noHighlight {
			obj.warn("highlight block found but disabled")
		} else {
			obj.log(fmt.Sprintf("pygmentize %s", obj.md))
			mdNew, style, err := obj.pygmentize(mdRaw)
			if err != nil {
				obj.err("unable to pygmentize", err)
				channel <- ""
				return
			}
			css = fmt.Sprintf("%s\n%s", css, style)
			b = mdNew
		}
	}
	if err := ioutil.WriteFile(obj.md, b, 0644); err != nil {
		obj.err("unable to write md file", err)
		channel <- ""
		return
	}
	obj.log(fmt.Sprintf("%s -> %s", obj.md, obj.html))
	if err := pythonMarkdown("-f", obj.html, obj.md); err != nil {
		obj.err("unable to convert markdown", err)
		channel <- ""
		return
	}
	b, err = ioutil.ReadFile(obj.html)
	if err != nil {
		obj.err("unable to read html in", err)
		channel <- ""
		return
	}
	progress := ""
	if !obj.req.noIndex && obj.ident > 0 {
		progress = fmt.Sprintf("%d of %d", obj.ident+1, obj.total)
	}
	slide := Slide{
		Style:    template.CSS(css),
		Progress: progress,
		ID:       fmt.Sprintf("md-%d", obj.ident),
		DirID:    cleanPath(obj.input, false),
		ObjectID: cleanPath(obj.input, true),
		Content:  template.HTML(string(b)),
	}
	var buffer bytes.Buffer
	if err := obj.req.templateHTML.Execute(&buffer, slide); err != nil {
		obj.err("unable to execute template", err)
		channel <- ""
		return
	}
	if err := ioutil.WriteFile(obj.html, buffer.Bytes(), 0644); err != nil {
		obj.err("unable to write html", err)
		channel <- ""
		return
	}
	obj.log(fmt.Sprintf("%s -> %s", obj.html, obj.pdf))
	cmd := exec.Command(wkHTMLToPDF,
		"--margin-top", "0",
		"--margin-bottom", "0",
		"--margin-left", "0",
		"--margin-right", "0",
		"-O", "landscape",
		obj.html,
		obj.pdf)
	if err := cmd.Run(); err != nil {
		obj.err("wkhtmltopdf failed", err)
		channel <- ""
		return
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
	count := len(files)
	var pdf []string
	for idx, f := range files {
		c := make(chan string)
		root := filepath.Join(r.outputDirectory, fmt.Sprintf("%d.", idx))
		obj := buildObject{
			input: f,
			md:    root + "md",
			html:  root + "html",
			pdf:   root + "pdf",
			ident: idx,
			req:   r,
			total: count,
		}
		go build(c, obj, state)
		chans[obj.hashFile()] = c
		pdf = append(pdf, obj.pdf)
	}
	newState := make(map[string]string)
	for k, c := range chans {
		result := <-c
		if result == "" {
			fatal("error building file", nil)
		}
		newState[k] = result
	}
	output := filepath.Join(r.outputDirectory, "output.pdf")
	pdf = append(pdf, output)
	fmt.Println("compiling", output)
	cmd := exec.Command(pdfUnite, pdf...)
	if err := cmd.Run(); err != nil {
		return err
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
