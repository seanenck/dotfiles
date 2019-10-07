package main

import (
	"flag"
	"fmt"
	"os/exec"
	"path/filepath"
	"time"
)

var (
	localBin string
)

func run(local bool, cmd string, args ...string) {
	exe := cmd
	if local {
		exe = filepath.Join(localBin, cmd)
	}
	command := exec.Command(cmd, args...)
	if err := command.Run(); err != nil {
		fmt.Println(fmt.Sprintf("%s %v -> %v", exe, args, err))
	}
}

func daemon(local bool, cmd string, args ...string) {
	for {
		run(local, cmd, args...)
		time.Sleep(1 * time.Second)
	}
}

func main() {
	bin := flag.String("bin", "", "local binary path")
	home := flag.String("home", "", "user home")
	flag.Parse()
	localBin = *bin
	homeDir := *home
	run(true, "subsystem", "backlight", "mid")
	run(true, "subsystem", "workspaces", "mobile")
	go func() {
		daemon(true, "dwm-bin")
	}()
	time.Sleep(1 * time.Second)
	dunstConf := filepath.Join(homeDir, ".config", "dunst")
	go func() {
		daemon(false, "dunst", "-config", dunstConf)
	}()
	xautolock := fmt.Sprintf("\"%s lock\"", filepath.Join(localBin, "locking"))
	go func() {
		daemon(false, "xautolock", "-time", "5", "-locker", xautolock)
	}()
	go func() {
		daemon(true, "status", "daemon")
	}()
	go func() {
		daemon(true, "syncing")
	}()
	for {
		time.Sleep(1 * time.Minute)
	}
}
