import weechat
import copy
import threading
import os
import signal
import time
import calendar

SERVERS = []
PAUSE = 0
lock = threading.RLock()
THRESHOLD = 900

def get_time():
    return calendar.timegm(time.gmtime())

ACTIVE = get_time()

def enable_handler(signal, frame):
    global ACTIVE
    global PAUSE
    with lock:
        ACTIVE = get_time()
        PAUSE = 0


def disable_handler(signal, frame):
    global PAUSE
    with lock:
        PAUSE = 15


def inactivity_cb(data, remaining_calls):
    global SERVERS
    global PAUSE
    global ACTIVE
    inactive = int(weechat.info_get("inactivity", ""))
    force_active = False
    with lock:
        if PAUSE > 0:
            inactive = THRESHOLD + 1
            PAUSE -= 1
        timed = get_time()
        force_active = timed - ACTIVE <= THRESHOLD
    if inactive < THRESHOLD or force_active:
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
    signal.signal(signal.SIGUSR1, disable_handler)
    signal.signal(signal.SIGUSR2, enable_handler)
    with open("/tmp/weechat.ready", 'w') as f:
        f.write("ready")
