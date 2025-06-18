#!/bin/bash

CMD="cvlc"
ARGS="/home/z6/Music/focus.mp3"

if pgrep -x "$(basename "$CMD")" > /dev/null; then
    pkill -x "$(basename "$CMD")"
else
    nohup $CMD $ARGS > /dev/null 2>&1 &
fi

