package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"
	"time"
)

func list(dir string) ([]string, error) {
	files, err := ioutil.ReadDir(dir)
	if err != nil {
		return nil, err
	}
	var results []string
	for _, obj := range files {
		f := obj.Name()
		ext := filepath.Ext(f)
		if ext == ".gpg" {
			results = append(results, strings.Replace(f, ext, "", -1))
		}
	}
	sort.Strings(results)
	return results, nil
}

func clear() {
	cmd := exec.Command("clear")
	cmd.Stdout = os.Stdout
	if err := cmd.Run(); err != nil {
		fmt.Println(fmt.Sprintf("unable to clear screen: %v", err))
	}
}

func chanOutput(command, disp string, env []string, comm chan string, args ...string) {
	cmd := exec.Command(command, args...)
	if env != nil {
		cmd.Env = env
	}
	out, err := cmd.Output()
	if err != nil {
		fmt.Println(fmt.Sprintf("%s: %v", disp, err))
		comm <- ""
		return
	}
	comm <- strings.TrimSpace(string(out))
}

func getToken(token string, env []string, comm chan string) {
	chanOutput("pass", fmt.Sprintf("unable to retrieve token: %s", token), env, comm, "show", token)
}

func oath(name, token string, comm chan string) {
	chanOutput("oathtool", fmt.Sprintf("token %s read failed", name), nil, comm, "--base32", "--totp", token)
}

func display(token, pass, totp string, available []string) error {
	show := available
	tok := strings.TrimSpace(token)
	if tok != "" {
		matched := false
		for _, obj := range available {
			if obj == tok {
				matched = true
				show = []string{obj}
			}
		}
		if !matched {
			return fmt.Errorf("invalid totp request: %s", tok)
		}
	}
	if len(show) == 0 {
		return fmt.Errorf("nothing to display")
	}
	env := []string{fmt.Sprintf("PASSWORD_STORE_DIR=%s", pass)}
	chans := make(map[string]chan string)
	clear()
	if len(show) > 1 {
		fmt.Println("getting tokens...")
	}
	for _, t := range show {
		c := make(chan string)
		go getToken(filepath.Join(totp, t), env, c)
		chans[t] = c
	}
	objects := make(map[string]string)
	for k, v := range chans {
		t := <-v
		if t == "" {
			continue
		}
		objects[k] = t
	}
	if len(objects) == 0 {
		return fmt.Errorf("no tokens available")
	}
	first := true
	running := 0
	lastSecond := -1
	for {
		if !first {
			time.Sleep(500 * time.Millisecond)
		}
		first = false
		running++
		if running > 120 {
			fmt.Println("exiting (timeout)")
			return nil
		}
		now := time.Now()
		last := now.Second()
		if last == lastSecond {
			continue
		}
		lastSecond = last
		left := 60 - last
		expires := fmt.Sprintf("%s, expires: %2d (seconds)", now.Format("15:04:05"), left)
		outputs := []string{expires}
		results := make(map[string]chan string)
		for tk, tv := range objects {
			c := make(chan string)
			go oath(tk, tv, c)
			results[tk] = c
		}
		var displaying []string
		for rk, rc := range results {
			val := <-rc
			if val == "" {
				continue
			}
			displaying = append(displaying, fmt.Sprintf("%s\n    %s", rk, val))
		}
		if len(displaying) == 0 {
			return fmt.Errorf("unable to values for display")
		}
		sort.Strings(displaying)
		outputs = append(outputs, displaying...)
		outputs = append(outputs, "-> CTRL+C to exit")
		startColor := ""
		endColor := ""
		if left < 10 {
			startColor = "\033[1;31m"
			endColor = "\033[0m"
		}
		clear()
		fmt.Println(fmt.Sprintf("%s%s%s", startColor, strings.Join(outputs, "\n\n"), endColor))
	}
	return nil
}

func main() {
	totp := flag.String("totp", "services/totp", "directory of totp codes in a pass database")
	pass := flag.String("pass", "", "pass database")
	listNames := flag.Bool("list", false, "list available totp options")
	subcmd := flag.String("command", "", "command or totp token to few")
	flag.Parse()
	cmd := *subcmd
	passDir := *pass
	totpSub := *totp
	dir := filepath.Join(passDir, totpSub)
	list, err := list(dir)
	if err != nil {
		fmt.Println(fmt.Sprintf("unable to list totp objects: %v", err))
		return
	}
	if *listNames {
		if cmd != "" {
			fmt.Println("command not supported in list mode")
			return
		}
		for _, f := range list {
			fmt.Println(f)
		}
		return
	}
	if err := display(cmd, passDir, totpSub, list); err != nil {
		fmt.Println(fmt.Sprintf("unable to display tokens: %v", err))
	}
}
