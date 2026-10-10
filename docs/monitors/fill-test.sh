#!/usr/bin/env bash
# Открывает полноэкранные тестовые заливки (fill.py) на каждом мониторе.
# Клавиша в любом окне переключает заливку на всех сразу, q — закрыть.
set -eu

dir=$(cd "$(dirname "$0")" && pwd)
state="${XDG_RUNTIME_DIR:-/tmp}/monitor-fill.state"
echo 1 > "$state"

cmd="kitty --class fill-test -o background_opacity=1 -o window_padding_width=0 \
-o hide_window_decorations=yes --start-as=fullscreen python3 $dir/fill.py"

monitors=${*:-$(hyprctl monitors -j | python3 -c 'import json,sys; print(" ".join(m["name"] for m in json.load(sys.stdin)))')}

for m in $monitors; do
  hyprctl dispatch "hl.dsp.focus({monitor=\"$m\"})" > /dev/null
  sleep 0.3
  hyprctl dispatch "hl.dsp.exec_cmd(\"$cmd\")" > /dev/null
  sleep 1.2
done
