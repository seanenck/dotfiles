package main

import (
	"bufio"
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"strings"

	qr "github.com/skip2/go-qrcode"
)

func readStdin() ([]string, error) {
	scanner := bufio.NewScanner(os.Stdin)
	var messages []string
	for scanner.Scan() {
		messages = append(messages, scanner.Text())
	}
	if err := scanner.Err(); err != nil {
		return nil, err
	}
	return messages, nil
}

func main() {
	output := flag.String("output", "output", "output name")
	image := flag.Int("size", 2000, "image size")
	white := flag.String("white", ".", "white color character")
	black := flag.String("black", "X", "black color character")
	html := flag.Bool("html", false, "output html")
	png := flag.Bool("png", true, "output png")
	console := flag.Bool("stdout", true, "output stdout")
	flag.Parse()
	s, err := readStdin()
	if err != nil {
		fmt.Println(err)
		panic("unable to read stdin")
	}
	result := strings.Join(s, "\n")
	result = strings.TrimSpace(result)
	if len(result) == 0 {
		panic("no input/empty")
	}
	q, err := qr.New(result, qr.Medium)
	if err != nil {
		fmt.Println(err)
		panic("unable to read input")
	}
	name := strings.TrimSpace(*output)
	if len(name) == 0 {
		panic("name is invalid")
	}
	wh := strings.TrimSpace(*white)
	bl := strings.TrimSpace(*black)
	if len(wh) == 0 {
		wh = " "
	}
	if len(bl) == 0 {
		bl = " "
	}
	if wh == bl {
		panic("invalid color indicators, cannot be the same and must be a single character")
	}
	saved := false
	if *png {
		saved = true
		err = q.WriteFile(*image, name+".png")
	}
	if err != nil {
		fmt.Println(err)
		panic("unable to produce png")
	}
	b := q.Bitmap()
	out := ""
	iSize := 0
	jSize := 0
	for i := range b {
		iSize = i
		for j, x := range b[i] {
			jSize = j
			val := wh
			if x {
				val = bl
			}
			out = fmt.Sprintf("%s%s", out, val)
		}
		out = fmt.Sprintf("%s\n", out)
	}
	stdout := *console
	size := fmt.Sprintf("%d x %d", iSize+1, jSize+1)
	if stdout {
		fmt.Println(out)
		fmt.Println(size)
	}
	out = fmt.Sprintf("<html><body><pre><code>%s</code></pre>%s</body></html>", out, size)
	if *html {
		saved = true
		ioutil.WriteFile(name+".html", []byte(out), 0644)
	}
	if !saved {
		fmt.Println("no output formats given...")
	}
}
