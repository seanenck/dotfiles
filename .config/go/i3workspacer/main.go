package main

import (
	"fmt"
	"github.com/mdirkse/i3ipc"
)
func main() {
	ipcsocket, err := i3ipc.GetIPCSocket()
	if err != nil {
		panic("unable to open socket")
	}
	i3ipc.StartEventListener()
	ws_events, err := i3ipc.Subscribe(i3ipc.I3WorkspaceEvent)
	if err != nil {
		panic("unable to subscribe")
	}
	for {
	    event := <-ws_events
		tree, err := ipcsocket.GetTree()
		if err != nil {
			continue
		}
		workspaces := tree.Workspaces()
		for _, w := range workspaces {
		}
	    fmt.Printf("Received an event: %v\n", event)
	}
}
