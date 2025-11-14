#!/bin/bash
browser=blank

readmsg() {
  local i n char len=0
  # read and calculate little endian msg length
  for ((i=0; i<4; i++)); do
    IFS= read -r -d '' -n 1 char || return 1
    printf -v n %d "'$char"
    ((len += n << (i*8)))
  done
  # read len of message into msg
  IFS= read -r -N "$len" msg || return 1
  # malformed msg check
  [[ "$msg" == '{"action":"start"}' || "$msg" == '{"action":"stop"}' ]] || return 1
  return 0
}

sendmsg() {
  printf -v x %08X "${#1}";
  printf %b "\x${x:6:2}\x${x:4:2}\x${x:2:2}\x${x:0:2}";
  printf %s "$1";
}

cleanup() {
  pkill -f "playerctl --player=$browser status --follow" 2>/dev/null || true
  exit
}

while readmsg; do
  case "$msg" in
    '{"action":"start"}')
      if ! pgrep -f "playerctl --player=$browser status --follow" > /dev/null; then
        coproc { playerctl --player="$browser" status --follow |
          while read -r status; do
            case $status in
              Playing) playerctl --player="$browser" position 1- ;;
              Paused|Stopped) continue ;;
              *)
                # playerctl crashes and ungraceful browser closures
                pkill -f "playerctl --player=$browser status --follow" 2>/dev/null || true
                exit ;;
            esac
          done
        }
      fi
      sendmsg '{"status":"ok"}' ;;
    '{"action":"stop"}')
      sendmsg '{"status":"ok"}'
      cleanup ;;
  esac
done || cleanup
