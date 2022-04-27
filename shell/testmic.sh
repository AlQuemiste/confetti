# https://forums.debian.net/viewtopic.php?t=149268

# list of CAPTURE hardware devices
arecord -l

arecord --device=plughw:0,0 -d 10 --format S16_LE --rate 16000 -c1 /tmp/testmic.mp3
