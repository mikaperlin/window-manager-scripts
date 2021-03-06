#!/usr/bin/env sh

if [ $(pidof xbacklight) ]; then
  exit 0
fi

med=60
time=200
delta=20

if [ $1 = dec ]; then
  xbacklight -dec $delta -time $time
elif [ $1 = inc ]; then
  xbacklight -inc $delta -time $time
elif [ $1 = dim ]; then
  xbacklight -set 20
elif [ $1 = max ]; then
  xbacklight -set 100
elif [ $1 = set ]; then
  xbacklight -set $2
elif [ $1 = med ]; then
  xbacklight -set $med
fi
