import weechat
import copy
import threading
import os

SERVERS = []
lock = threading.RLock()

def inactivity_cb(data, remaining_calls):
    global SERVERS
    inactive = int(weechat.info_get("inactivity", ""))
    if inactive < 900:
        with lock:
            if len(SERVERS) > 0:
                weechat.prnt("", "reconnecting...")
                for serv in SERVERS:
                    weechat.command("", "/connect %s" % serv)
                SERVERS = []
    else:
        do = False
        with lock:
            do = len(SERVERS) == 0
        if do:
            weechat.prnt("", "disconnecting - inactive")
            servers = weechat.infolist_get('irc_server', '', '')
            discon = []
            while weechat.infolist_next(servers):
                name = weechat.infolist_string(servers, 'name')
                is_connected = weechat.infolist_integer(servers,'is_connected')
                if is_connected == 1:
                    discon.append(name)
            if len(discon) > 0:
                with lock:
                    SERVERS = discon
                    for srv in discon:
                        weechat.command("", "/disconnect %s" % srv)
    return weechat.WEECHAT_RC_OK

if weechat.register("inactive", "enckse", "1.0", "MIT", "Disconnect after inactivity periods", "", ""):
    weechat.hook_timer(1000, 0, 0, "inactivity_cb", "")
