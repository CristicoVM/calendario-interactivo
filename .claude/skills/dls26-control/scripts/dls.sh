#!/usr/bin/env bash
# Control de DLS26 vía ADB. Uso: bash dls.sh <comando> [args]
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF="$DIR/dls.conf"
[[ -f "$CONF" ]] || CONF="$DIR/dls.conf.example"
# shellcheck source=/dev/null
source "$CONF"

ADB=("${ADB_BIN:-adb}")
[[ -n "${DLS_SERIAL:-}" ]] && ADB+=(-s "$DLS_SERIAL")
SHOT="${DLS_SHOT:-/tmp/dls_screen.png}"

die() { echo "error: $*" >&2; exit 1; }
sh_() { "${ADB[@]}" shell "$@"; }

# Coordenadas de un botón por nombre (PASS, SHOOT, THROUGH, SPRINT, PAUSE)
btn() {
  local n="${1^^}" x y
  x="${n}_X"; y="${n}_Y"
  [[ -n "${!x:-}" && -n "${!y:-}" ]] || die "botón desconocido: $1"
  echo "${!x} ${!y}"
}

# Dirección (N, NE, ... o grados; 0=derecha, 90=arriba) -> punto en el joystick
joy_target() {
  local d="${1^^}" deg
  case "$d" in
    E) deg=0;; NE) deg=45;; N) deg=90;; NW) deg=135;;
    W) deg=180;; SW) deg=225;; S) deg=270;; SE) deg=315;;
    *) [[ "$d" =~ ^-?[0-9]+$ ]] || die "dirección inválida: $1"; deg="$d";;
  esac
  awk -v x="$JOY_X" -v y="$JOY_Y" -v r="$JOY_R" -v a="$deg" 'BEGIN{
    t=a*3.14159265/180; printf "%d %d\n", x+r*cos(t), y-r*sin(t) }'
}

tap()  { read -r x y < <(btn "$1"); sh_ input tap "$x" "$y"; }
hold() { read -r x y < <(btn "$1"); sh_ input swipe "$x" "$y" "$x" "$y" "${2:-400}"; }
move() {
  read -r tx ty < <(joy_target "$1")
  sh_ input swipe "$JOY_X" "$JOY_Y" "$tx" "$ty" "${2:-500}"
}
lob() {
  read -r x y < <(btn "$1")
  sh_ input swipe "$x" "$y" "$x" "$((y - LOB_DY))" "${2:-150}"
}

case "${1:-help}" in
  check)
    "${ADB[@]}" get-state >/dev/null || die "no hay dispositivo ADB"
    sh_ wm size
    sh_ dumpsys window 2>/dev/null | grep -iE 'mCurrentFocus|mFocusedApp' | head -2 || true
    echo "config: $CONF" ;;
  shot)
    "${ADB[@]}" exec-out screencap -p > "$SHOT"; echo "$SHOT" ;;
  tap)   tap "${2:?botón}" ;;
  hold)  hold "${2:?botón}" "${3:-400}" ;;
  move)  move "${2:?dirección}" "${3:-500}" ;;
  lob)   lob "${2:?botón}" "${3:-150}" ;;
  xy)    sh_ input tap "${2:?x}" "${3:?y}" ;;
  swipe) sh_ input swipe "${2:?}" "${3:?}" "${4:?}" "${5:?}" "${6:-300}" ;;
  pause) tap PAUSE ;;
  combo)
    # combo <nombre> <dirección> <ms_joystick> <botón> <ms_botón> [retraso_ms]
    # Mueve el joystick y, tras el retraso, pulsa el botón en paralelo.
    dir="${3:?dirección}"; jms="${4:?ms}"; b="${5:?botón}"; bms="${6:-150}"
    delay="${7:-$(( jms / 2 ))}"
    move "$dir" "$jms" &
    sleep "$(awk -v d="$delay" 'BEGIN{print d/1000}')"
    hold "$b" "$bms"
    wait ;;
  help|*)
    sed -n '2,3p' "$0"
    echo "comandos: check | shot | tap B | hold B ms | move DIR ms | lob B | xy X Y |"
    echo "          swipe X1 Y1 X2 Y2 ms | pause | combo nombre DIR ms B ms [retraso]" ;;
esac
