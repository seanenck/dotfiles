/* See LICENSE file for copyright and license details. */
#include <X11/XF86keysym.h>

/* appearance */
static const unsigned int borderpx  = 1;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 0;        /* 0 means bottom bar */
static const char *fonts[]          = { "monospace:size=14" };
static const char dmenufont[]       = "monospace:size=14";
static const char col_gray1[]       = "#222222";
static const char col_gray2[]       = "#444444";
static const char col_gray3[]       = "#bbbbbb";
static const char col_gray4[]       = "#eeeeee";
static const char col_cyan[]        = "#005577";
static const char *colors[][3]      = {
	/*               fg         bg         border   */
	[SchemeNorm] = { col_gray3, col_gray1, col_gray2 },
	[SchemeSel]  = { col_gray4, col_cyan,  col_cyan  },
};

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class      instance    title       tags mask     isfloating   monitor */
	{ "INVALIDCLASS",  NULL,       NULL,       1 << 8,       0,           -1 },
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },    /* first entry is default */
	{ "[M]",      monocle },
};

/* key definitions */
#define MODKEY Mod1Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { "dmenu-local", "-m", dmenumon, "-fn", dmenufont, "-nb", col_gray1, "-nf", col_gray3, "-sb", col_cyan, "-sf", col_gray4, NULL };
static const char *termcmd[]  = { "kitty", NULL };
static const char *autoclip[] = { "subsystem", "autoclip", "now", NULL };
// volume commands
static const char *volumeup[] = { "volume", "inc", NULL };
static const char *volumedown[] = { "volume", "dec", NULL };
static const char *volumemute[] = { "volume", "togglemute", NULL };
// brightness
static const char *brightup[] = { "subsystem", "backlight", "up", NULL };
static const char *brightdown[] = { "subsystem", "backlight", "down", NULL };
// multimon
static const char *mobile[] = { "subsystem", "workspaces" , "1", NULL };
static const char *docked[] = { "subsystem", "workspaces" , "2", NULL };
// locking
static const char *locked[] = { "locking", "lock", NULL };
static const char *locktoggle[] = { "locking", "toggle", NULL };
static const char *locksleep[] = { "locking", "sleep", NULL };

void
taggedmove(const Arg *arg) {
    tagmon(arg);
    focusmon(arg);
}

static Key keys[] = {
	/* modifier                     key        function        argument */
	{ MODKEY,                       XK_d,      spawn,          {.v = dmenucmd } },
	{ MODKEY,                       XK_Return, spawn,          {.v = termcmd } },
	{ MODKEY,                       XK_Up,     focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_Down,   focusstack,     {.i = -1 } },
	{ MODKEY,                       XK_Left,   incnmaster,     {.i = +1 } },
	{ MODKEY,                       XK_Right,  incnmaster,     {.i = -1 } },
    { MODKEY,                       XK_s,      spawn,          {.v = autoclip } },
	{ MODKEY|ShiftMask,             XK_q,      killclient,     {0} },
	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
	{ MODKEY,                       XK_Tab,    focusmon,       {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_Tab,    taggedmove,     {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_Return, zoom,           {0} },
	{ MODKEY|ShiftMask,             XK_Up,     setmfact,       {.f = -0.05} },
	{ MODKEY|ShiftMask,             XK_Down,   setmfact,       {.f = +0.05} },
	{ MODKEY|ShiftMask,             XK_m,      spawn,          {.v = mobile } },
	{ MODKEY|ShiftMask,             XK_o,      spawn,          {.v = docked } },
	{ MODKEY|ShiftMask,             XK_l,      spawn,          {.v = locked } },
	{ MODKEY|ShiftMask,             XK_x,      spawn,          {.v = locktoggle } },
	{ MODKEY|ShiftMask,             XK_s,      spawn,          {.v = locksleep } },
	{ 0,                            XF86XK_AudioRaiseVolume,   spawn, {.v = volumeup } },
	{ 0,                            XF86XK_AudioLowerVolume,   spawn, {.v = volumedown } },
	{ 0,                            XF86XK_AudioMute,          spawn, {.v = volumemute } },
	{ 0,                            XF86XK_MonBrightnessUp,    spawn, {.v = brightup } },
	{ 0,                            XF86XK_MonBrightnessDown,  spawn, {.v = brightdown } },
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)
	{ MODKEY|ShiftMask,             XK_e,      quit,           {0} },
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkTagBar,            0,              Button1,        view,           {0} },
};

