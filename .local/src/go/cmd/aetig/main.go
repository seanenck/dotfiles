package main

import (
	"encoding/json"
	"flag"
	"fmt"
	html "html/template"
	"io/ioutil"
	"net/http"
	"path/filepath"
	"strings"
	"sync"
	"time"

	yaml "gopkg.in/yaml.v2"
	"voidedtech.com/home/assets"
)

const (
	issuesURL   = "/issues/"
	staticURL   = issuesURL + "static/"
	closedState = "closed"
	openState   = "open"
	// Headers
	milestoneHeader = "milestone"
)

var (
	locker     = &sync.Mutex{}
	cached     [][]string
	cacheTime  int64
	cacheState string
)

type (
	// Repo represents a gitea repository definition
	Repo struct {
		FullName  string `json:"full_name"`
		HasIssues bool   `json:"has_issues"`
		Archived  bool
	}

	// Table is how output data is defined for templating
	Table struct {
		Data    html.JS
		Columns html.JS
		State   string
		URL     string
		Static  string
	}

	// Column represents a datatable column definition
	Column struct {
		Title string `json:"title"`
	}

	// Issue represents a gitea issue
	Issue struct {
		Parent string
		URL    string
		Number int
		User   struct {
			UserName string
		}
		Title    string
		Assignee struct {
			UserName string
		}
		Labels []struct {
			Name string
		}
		State     string
		CreatedOn string `json:"created_at"`
		UpdatedOn string `json:"updated_at"`
		ClosedOn  string `json:"closed_at"`
		Milestone struct {
			Title string
		}
		Assignees []struct {
		}
		PullRequest struct {
			Merged *bool
		} `json:"pull_request"`
	}

	dataRequest struct {
		url    string
		token  string
		owners []string
		purge  int64
		prs    bool
		tmpl   *html.Template
	}

	// Config holds aetig's configuration
	Config struct {
		URL          string
		Token        string
		Bind         string
		Owners       []string
		Lifespan     int
		PullRequests bool
	}
)

func request(url, token, api string, params []string) []byte {
	parameters := ""
	if len(params) > 0 {
		parameters = fmt.Sprintf("&%s", strings.Join(params, "&"))
	}
	call := fmt.Sprintf("%s/api/v1/%s?access_token=%s%s", url, api, token, parameters)
	res, err := http.Get(call)
	if err != nil {
		warn("http call failed", err)
		return []byte{}
	}
	defer res.Body.Close()
	b, err := ioutil.ReadAll(res.Body)
	if err != nil {
		warn("invalid response body", err)
		return []byte{}
	}
	return b
}

func issues(url, token string, owners, states []string, repos []Repo) []Issue {
	var results []Issue
	tracked := make(map[string]struct{})
	filterOwners := len(owners) > 0
	for _, r := range repos {
		if !r.HasIssues || r.Archived {
			continue
		}
		if filterOwners {
			skip := true
			for _, owner := range owners {
				if strings.HasPrefix(r.FullName, fmt.Sprintf("%s/", owner)) {
					skip = false
				}
			}
			if skip {
				continue
			}
		}
		api := fmt.Sprintf("repos/%s/issues", r.FullName)
		for _, s := range states {
			count := 1
			state := fmt.Sprintf("state=%s", s)
			for {
				var params []string
				params = append(params, state)
				if count > 1 {
					params = append(params, fmt.Sprintf("page=%d", count))
				}
				data := request(url, token, api, params)
				if len(data) == 0 {
					break
				}
				var issues []Issue
				if err := json.Unmarshal(data, &issues); err != nil {
					warn("json unmarshal", err)
					continue
				}
				if len(issues) == 0 {
					break
				}
				for _, i := range issues {
					if _, ok := tracked[i.URL]; ok {
						continue
					}
					tracked[i.URL] = struct{}{}
					i.Parent = r.FullName
					results = append(results, i)
				}
				count = count + 1
			}
		}
	}
	return results
}

func fetch(url, token string, owners, states []string, purge int64, pullRequests bool) ([][]string, error) {
	locker.Lock()
	defer locker.Unlock()
	now := time.Now().UnixNano()
	newState := strings.Join(states, ";")
	if purge > 0 {
		if len(cached) > 0 {
			if cacheTime > 0 && cacheState == newState {
				delta := now - cacheTime
				mins := delta / 1000000000 / 60
				if mins > purge {
					cached = [][]string{}
					info("purging cache")
				}
				if len(cached) > 0 {
					return cached, nil
				}
			}
		}
	}
	repoBytes := request(url, token, "user/repos", []string{})
	var r []Repo
	if err := json.Unmarshal(repoBytes, &r); err != nil {
		return nil, err
	}
	list := issues(url, token, owners, states, r)
	var objects [][]string
	headers := []string{
		"issue",
		"author",
		"title",
		"assignee",
		"labels",
		milestoneHeader,
		"created",
		"updated"}
	hasState := len(states) > 1
	closedState := strings.Contains(newState, closedState)
	if closedState {
		headers = append(headers, "closed")
	}
	if hasState {
		headers = append(headers, "state")
	}
	if pullRequests {
		headers = append(headers, "type")
	}
	objects = append(objects, headers)
	for _, l := range list {
		labels := ""
		if len(l.Labels) > 0 {
			var merge []string
			for _, label := range l.Labels {
				merge = append(merge, label.Name)
			}
			labels = strings.Join(merge, ";")
		}
		typed := "issue"
		if l.PullRequest.Merged != nil {
			if !pullRequests {
				continue
			}
			typed = "pr"
		}
		assignees := len(l.Assignees)
		userName := l.Assignee.UserName
		hasAssignee := assignees > 0 || len(userName) > 0
		assigned := ""
		if hasAssignee {
			if assignees > 1 {
				userName = fmt.Sprintf("many (%d)", assignees)
			}
			assigned = fmt.Sprintf("%s", userName)
		}
		obj := []string{
			fmt.Sprintf("<a href='%s/%s/issues/%d'>%s/%d</a>", url, l.Parent, l.Number, l.Parent, l.Number),
			l.User.UserName,
			l.Title,
			assigned,
			labels,
			l.Milestone.Title,
			l.CreatedOn,
			l.UpdatedOn,
		}
		if closedState {
			obj = append(obj, l.ClosedOn)
		}
		if hasState {
			obj = append(obj, l.State)
		}
		if pullRequests {
			obj = append(obj, typed)
		}
		objects = append(objects, obj)
	}
	cached = objects
	cacheTime = now
	cacheState = newState
	return objects, nil
}

func fetchObjects(req dataRequest, states []string) ([][]string, error) {
	return fetch(req.url, req.token, req.owners, states, req.purge, req.prs)
}

func openedMilestone(w http.ResponseWriter, r *http.Request, req dataRequest) {
	all, err := fetchObjects(req, []string{openState})
	if err != nil {
		warn("fetch failed", err)
		return
	}
	if len(all) == 0 {
		warn("no data...", nil)
		return
	}
	headers := all[0]
	milestoneIdx := -1
	for idx, header := range headers {
		if header == milestoneHeader {
			milestoneIdx = idx
			break
		}
	}
	if milestoneIdx < 0 {
		warn("unable to find milestone information in header", nil)
		return
	}
	results := make(map[string]int)
	if len(all) > 0 {
		data := all[1:]
		for _, obj := range data {
			milestone := obj[milestoneIdx]
			if strings.TrimSpace(milestone) == "" {
				milestone = "n/a"
			}
			if _, ok := results[milestone]; !ok {
				results[milestone] = 0
			}
			results[milestone]++
		}
	}
	b, err := json.Marshal(results)
	if err != nil {
		warn("json unmarshal of results", err)
		return
	}
	w.Write(b)
}

func retrieve(w http.ResponseWriter, r *http.Request, req dataRequest, state string, opened, closed bool) {
	var states []string
	if opened {
		states = append(states, openState)
	}
	if closed {
		states = append(states, closedState)
	}
	if len(states) == 0 {
		return
	}
	all, err := fetchObjects(req, states)
	if err != nil {
		warn("fetch failed on states", err)
		return
	}
	if len(all) == 0 {
		warn("no data in states", err)
		return
	}
	header := all[0]
	var items [][]string
	if len(all) > 1 {
		items = all[1:]
	}
	var cols []Column
	for _, h := range header {
		cols = append(cols, Column{Title: h})
	}
	data, err := json.Marshal(items)
	if err != nil {
		warn("unable to unmarshal state response", err)
		return
	}
	columns, err := json.Marshal(cols)
	if err != nil {
		warn("unable to create output columns", err)
		return
	}
	table := Table{}
	table.URL = staticURL
	table.Data = html.JS(string(data))
	table.Columns = html.JS(string(columns))
	table.State = state
	if strings.TrimSpace(state) == "" {
		table.State = "opened"
	}
	if err := req.tmpl.Execute(w, table); err != nil {
		warn("template", err)
	}
}

func main() {
	config := flag.String("config", "", "configuration file")
	flag.Parse()
	configBytes, err := ioutil.ReadFile(*config)
	if err != nil {
		fatal("no config data", err)
	}
	conf := &Config{}
	if err := yaml.Unmarshal(configBytes, &conf); err != nil {
		fatal("unable to read yaml", err)
	}
	tmpl, err := createTemplate()
	if err != nil {
		fatal("unable to read template in", err)
	}
	r := dataRequest{}
	r.url = conf.URL
	r.token = conf.Token
	r.tmpl = tmpl
	r.owners = conf.Owners
	r.prs = conf.PullRequests
	r.purge = int64(conf.Lifespan)
	http.HandleFunc(issuesURL, func(w http.ResponseWriter, req *http.Request) {
		parts := strings.Split(req.URL.Path, "/")
		if len(parts) < 3 {
			return
		}
		state := parts[2]
		closed := false
		opened := true
		if state == "closed" {
			closed = true
			opened = false
		}
		if state == "all" {
			closed = true
		}
		retrieve(w, req, r, state, opened, closed)
	})
	http.HandleFunc(issuesURL+"api/opened/milestone", func(w http.ResponseWriter, req *http.Request) {
		openedMilestone(w, req, r)
	})
	http.HandleFunc(staticURL, func(w http.ResponseWriter, req *http.Request) {
		parts := strings.Split(req.URL.Path, "/")
		if len(parts) < 4 {
			return
		}
		resource := parts[3]
		css := filepath.Ext(resource) == ".css"
		if css {
			if err := serveCSS(resource, w, req); err != nil {
				warn("css serve", err)
			}
			return
		}
		static, err := readAsset(resource)
		if err != nil {
			warn("asset failure", err)
			return
		}
		mime := ""
		if strings.HasSuffix(resource, ".js") {
			mime = "text/javascript"
		}
		if len(mime) > 0 {
			w.Header().Set("Content-Type", mime)
		}
		w.Write(static)
	})
	binding := conf.Bind
	info(fmt.Sprintf("listening: %s/%s", binding, issuesURL))
	if err := http.ListenAndServe(binding, nil); err != nil {
		fatal("bind failed", err)
	}
}

func info(message string) {
	fmt.Println(message)
}

func warn(message string, err error) {
	msg := message
	if err != nil {
		msg = fmt.Sprintf("%s: %v", msg, err)
	}
	fmt.Println(fmt.Sprintf("ERROR: %s", msg))
}

func fatal(message string, err error) {
	warn(message, err)
	panic("^ execution halted")
}

func createTemplate() (*html.Template, error) {
	b, err := readAsset("app.html")
	if err != nil {
		return nil, err
	}
	t, err := html.New("t").Parse(string(b))
	return t, err
}

func readAsset(name string) ([]byte, error) {
	return assets.Asset(fmt.Sprintf("assets/aetig/%s", name))
}

func serveCSS(file string, w http.ResponseWriter, r *http.Request) error {
	b, err := readAsset(file)
	if err != nil {
		return err
	}
	w.Header().Set("Content-Type", "text/css")
	w.Write(b)
	return nil
}
