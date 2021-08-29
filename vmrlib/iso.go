package main

import (
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"path/filepath"

	"github.com/hooklift/iso9660"
)

type (
	errorISO struct {
		message string
	}
)

func (e *errorISO) Error() string {
	return e.message
}

func main() {
	source := flag.String("src", "", "source file")
	dest := flag.String("dst", "", "destination dir")
	flag.Parse()
	if err := extract(*source, *dest); err != nil {
		message := fmt.Sprintf("failed to extract: %v", err)
		panic(message)
	}
}

func extract(image, dest string) error {
	file, err := os.Open(image)
	if err != nil {
		return err
	}

	r, err := iso9660.NewReader(file)
	if err != nil {
		return err
	}

	for {
		f, err := r.Next()
		if errors.Is(err, io.EOF) {
			break
		}

		if err != nil {
			return err
		}

		fp := filepath.Join(dest, f.Name())
		if f.IsDir() {
			if err := os.MkdirAll(fp, f.Mode()); err != nil {
				return err
			}
			continue
		}

		parentDir, _ := filepath.Split(fp)
		if err := os.MkdirAll(parentDir, f.Mode()); err != nil {
			return err
		}

		freader, ok := f.Sys().(io.Reader)
		if !ok {
			return &errorISO{"unable to get io.Reader"}
		}
		ff, err := os.OpenFile(fp, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, f.Mode())
		if err != nil {
			return err
		}
		if _, err = io.Copy(ff, freader); err != nil {
			_ = ff.Close()
			return err
		}
		if err := ff.Close(); err != nil {
			return err
		}
	}
	return nil
}
