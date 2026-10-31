#!/usr/bin/env bash
# relaunch deskman on the live Hyprland session and screenshot its window
APP="$HOME/.local/opt/deskman/deskman.py"
# match BOTH launch shapes: direct .py execution and the ~/.local/bin/deskman symlink
pkill -f 'bin/deskman|opt/deskman/deskman' 2>/dev/null
sleep 0.5
export XDG_RUNTIME_DIR=/run/user/1000
export HYPRLAND_INSTANCE_SIGNATURE=$(ls $XDG_RUNTIME_DIR/hypr | head -1)
export WAYLAND_DISPLAY=$(ls $XDG_RUNTIME_DIR | grep -oE 'wayland-[0-9]+' | head -1)
export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus
export GDK_BACKEND=wayland
nohup "${APP}" >/tmp/deskman.log 2>&1 &
sleep 4
pgrep -f "$APP" >/dev/null || { echo "NOT RUNNING"; cat /tmp/deskman.log; exit 1; }
head -5 /tmp/deskman.log
G=$(hyprctl clients -j | python3 -c "
import json,sys
for c in json.load(sys.stdin):
    t=(c.get('initialClass','')+c.get('class','')).lower()
    if 'deskman' in t:
        p,s=c['at'],c['size']; print(f\"{p[0]},{p[1]} {s[0]}x{s[1]}\")")
echo "geom: $G"
[ -n "$G" ] && grim -g "$G" /tmp/deskman-win.png && echo "shot: /tmp/deskman-win.png"
