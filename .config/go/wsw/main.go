package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"net"
	"os"
	"path/filepath"
	"strings"
	"time"

	"voidedtech.com/goutils/logger"
	"voidedtech.com/goutils/opsys"
	"voidedtech.com/goutils/sockets"
)

type Receiver struct {
	sockets.SocketReceive
	context *context
}

func setLink(name string, up bool) {
	op := "down"
	if up {
		op = "up"
	}
	cmd := fmt.Sprintf("ip link set %s %s", name, op)
	opsys.RunBashCommand(cmd)
}

func (r *Receiver) Consume(b []byte) {
	input := string(b)
	parts := strings.Split(input, ".")
	if len(parts) != 3 {
		logger.WriteWarn("invalid parts", parts...)
		return
	}
	profile := filepath.Join(r.context.networks, input)
	if opsys.PathNotExists(profile) {
		logger.WriteWarn("invalid profile", profile)
		return
	}
	contents, err := ioutil.ReadFile(profile)
	if err != nil {
		logger.WriteError("invalid profile file", err)
		return
	}
	ifaces, err := getAddress(r.context, false)
	if err != nil {
		logger.WriteError("could not read addresses", err)
		return
	}
	for _, a := range ifaces {
		setLink(a, false)
	}
	logger.WriteInfo("changing profile", profile)
	err = ioutil.WriteFile(r.context.cache, []byte(input), 0644)
	if err != nil {
		logger.WriteError("unable to write state cache", err)
	}
	opsys.RunBashCommand("pkill wpa_supplicant")
	time.Sleep(3 * time.Second)
	setLink(parts[1], true)
	time.Sleep(3 * time.Second)
	if strings.TrimSpace(string(contents)) != "" {
		flags := ""
		if parts[0] == "wired" {
			flags = "-D wired"
		}
		logger.WriteInfo("starting supplicant")
		opsys.RunBashCommand(fmt.Sprintf("/sbin/wpa_supplicant -c %s -i %s %s", profile, parts[1], flags))
	}
}

type context struct {
	networks string
	socket   *sockets.SocketSetup
	cache    string
}

type callback func(*context) ([]string, error)

func listNetworks(ctx *context) ([]string, error) {
	files, err := ioutil.ReadDir(ctx.networks)
	if err != nil {
		return nil, err
	}
	results := []string{}
	for _, f := range files {
		results = append(results, f.Name())
	}
	return results, nil
}

func daemon(ctx *context) {
	r := &Receiver{}
	r.context = ctx
	l := getLast(ctx)
	logger.WriteInfo("ready to receive...")
	if l != "" {
		go r.Consume([]byte(l))
	}
	sockets.SocketReceiveOnly(ctx.socket, r)
}

func printSafeList(ctx *context, cb callback) {
	n, err := cb(ctx)
	if err != nil {
		return
	}
	for _, f := range n {
		fmt.Println(f)
	}
}

func getAddressAndIp(ctx *context) ([]string, error) {
	return getAddress(ctx, true)
}

func getAddress(ctx *context, addIp bool) ([]string, error) {
	ifaces, err := net.Interfaces()
	if err != nil {
		return nil, err
	}
	results := []string{}
	for _, i := range ifaces {
		addrs, err := i.Addrs()
		if err != nil {
			continue
		}
		result := i.Name
		if result == "lo" {
			continue
		}
		if addIp {
			for _, addr := range addrs {
				var ip net.IP
				switch v := addr.(type) {
				case *net.IPNet:
					ip = v.IP
				case *net.IPAddr:
					ip = v.IP
				}
				ipv4 := ip.To4()
				if ipv4 != nil {
					results = append(results, fmt.Sprintf("%s:%s", result, ip))
				}
			}
		} else {
			results = append(results, result)
		}
	}
	return results, nil
}

func changeNetwork(ctx *context, network string) {
	sockets.SocketSendOnly(ctx.socket, []byte(network))
}

func getLast(ctx *context) string {
	if opsys.PathExists(ctx.cache) {
		f, err := ioutil.ReadFile(ctx.cache)
		if err != nil {
			return ""
		}
		return strings.TrimSpace(string(f))
	}
	return ""
}

func main() {
	networks := flag.String("networks", "/etc/wsw/", "path to network files")
	mode := flag.String("mode", "", "operation command/mode")
	cache := flag.String("cache", "/var/cache/wsw", "state information")
	bind := flag.String("bind", "127.0.0.1:7777", "bind address")
	flag.Parse()
	s := sockets.SocketSettings()
	s.Bind = *bind
	c := &context{}
	c.networks = *networks
	c.socket = s
	c.cache = *cache
	m := *mode
	switch m {
	case "addr":
		printSafeList(c, getAddressAndIp)
	case "list":
		printSafeList(c, listNetworks)
	case "daemon":
		daemon(c)
	case "current":
		last := getLast(c)
		if last != "" {
			fmt.Println(last)
		}
	case "reload":
		last := getLast(c)
		if last != "" {
			changeNetwork(c, last)
		}
	default:
		if m == "" {
			if len(os.Args) > 1 {
				m = os.Args[1]
			} else {
				logger.WriteWarn("invalid mode")
				return
			}
		}
		changeNetwork(c, m)
	}
}
