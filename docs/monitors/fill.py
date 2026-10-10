#!/usr/bin/env python3
# Полноэкранные тестовые заливки. Состояние общее для всех окон через файл:
# клавиша в любом окне переключает заливку на обоих мониторах.
import os, sys, tty, termios, select, shutil, time

STATE = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "monitor-fill.state")

FILLS = {
    "1": ("белый 100%", (255, 255, 255)),
    "2": ("серый 75%", (191, 191, 191)),
    "3": ("серый 50%", (128, 128, 128)),
    "4": ("серый 25%", (64, 64, 64)),
    "5": ("почти чёрный 5%", (13, 13, 13)),
    "r": ("красный", (255, 0, 0)),
    "g": ("зелёный", (0, 255, 0)),
    "b": ("синий", (0, 0, 255)),
    "s": ("телесный (кожа)", (224, 172, 145)),
}
HELP = ("1 белый  2 серый75  3 серый50  4 серый25  5 почти-чёрный  "
        "6 градиент серого  7 цветные полосы  r/g/b  s кожа  q выход")


def out(s):
    sys.stdout.write(s)
    sys.stdout.flush()


def fill(rgb):
    out("\033]11;#%02x%02x%02x\033\\\033[0m\033[2J\033[H" % rgb)


def bars(colors):
    cols, rows = shutil.get_terminal_size()
    fill((0, 0, 0))
    w = cols / len(colors)
    line = ""
    for i, (r, g, b) in enumerate(colors):
        n = int((i + 1) * w) - int(i * w)
        line += "\033[48;2;%d;%d;%dm" % (r, g, b) + " " * n
    out("\033[H" + "\n".join([line] * rows) + "\033[0m")


def render(key, show_help):
    if key == "6":
        steps = 17
        bars([(round(i * 255 / (steps - 1)),) * 3 for i in range(steps)])
    elif key == "7":
        bars([(255, 255, 255), (255, 255, 0), (0, 255, 255), (0, 255, 0),
              (255, 0, 255), (255, 0, 0), (0, 0, 255), (0, 0, 0)])
    else:
        fill(FILLS[key][1])
    if show_help:
        out("\033[H\033[48;2;0;0;0m\033[38;2;200;200;200m " + HELP + " \033[0m")


def read_state():
    try:
        return open(STATE).read().strip() or "1"
    except OSError:
        return "1"


def main():
    old = termios.tcgetattr(0)
    tty.setcbreak(0)
    out("\033[?25l")
    cur, show_help, shown_at = None, True, time.time()
    try:
        while True:
            key = read_state()
            if key == "q":
                break
            if show_help and time.time() - shown_at > 4:
                show_help, cur = False, None
            if key != cur:
                render(key, show_help)
                cur = key
            r, _, _ = select.select([0], [], [], 0.1)
            if r:
                c = os.read(0, 1).decode(errors="ignore").lower()
                if c in FILLS or c in ("6", "7", "q"):
                    open(STATE, "w").write(c)
                elif c == "h":
                    show_help, shown_at, cur = True, time.time(), None
    finally:
        termios.tcsetattr(0, termios.TCSADRAIN, old)
        out("\033]111\033\\\033[0m\033[2J\033[?25h")


if __name__ == "__main__":
    main()
