#!/bin/bash
browser=blank
readmsg() {
  local i n len=0;
  for ((i=0;i<4;i++)); do
    read -r -d '' -n 1;
    printf -v n %d "'$REPLY";
   ((len+=n<<i*8));
  done;
  read -r -N "$len" && msg=$REPLY;
}
sendmsg() {
  printf -v x %08X "${#1}";
  printf %b "\x${x:6:2}\x${x:4:2}\x${x:2:2}\x${x:0:2}";
  printf %s "$1";
}
cleanup() {
  pgrep -f "playerctl --player=$browser status --follow" | xargs kill -9
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
              Paused | Stopped) continue ;;
              *) exit ;;
            esac
          done
        }
      fi
      sendmsg '{"status":"ok"}' ;;
    '{"action":"stop"}')
      sendmsg '{"status":"ok"}'
      cleanup ;;
  esac
done

cleanup
