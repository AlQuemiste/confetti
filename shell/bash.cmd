# start a clean shell with no profile
bash --noprofile --norc
apt-mark showmanual | less

# VM
sudo virsh net-start default

# clang-format
find . -regex ".+\.[ch]\(pp\)*" | xargs clang-format -i --

# size of directories
du -sh -- *
df -h
du -hs <dir>

# produce ctags for .c, .h, .cpp, .hpp files
find . -regex ".+\.[ch]\(pp\)*" | etags -

# get detailed view of host machine
hostnamectl

# get the hostname of an IP
host <IP-address>

# SSH
ssh-add ~/.ssh/id_ed25519_myid

# Start the ssh-agent in the background.
eval "$(ssh-agent -s)"
#> Agent pid 59566

ssh-add ~/.ssh/id_ed25519_myid
ssh-add -l
ssh-add -l -E md5

# Jupyter notebook
actPy && python3 -m jupyterlab

# resetting Git tags
git tag --delete v22.0
git push --delete origin v22.0
git tag v22.0
git push --tag

## images
# strip image metadata
mogrify -strip img.png

# show detailed image metadata
identify -verbose img.png

# make an animation from a list of .png images
ffmpeg -framerate 5 -i img_%03d.png -c:v libx264 -pix_fmt yuv420p anim.mp4

# reduce mp3 size
ffmpeg -i input.file -map a -b:a 64k output.mp3

# reduce mp4 size <https://ffmpeg.org/ffmpeg.html>
# `-vcodec libx264`: use the H.264 codec which is widely supported and offers good compression.
# `-crf 28`: sets quality; lower values mean better quality and larger files (range: 18–28 is common).
# `-preset medium`: adjusts encoding speed and efficiency.
# `-c:a copy`: preserves the audio stream.

ffmpeg -i input.mp4 -vcodec libx264 -crf 28 -preset medium -c:a copy output.mp4

## adjust bitrate
## `-b:v 1000k`: sets video bitrate to 1000kbps. Lowering this can greatly reduce size, but also quality.

ffmpeg -i input.mp4 -vcodec h264 -b:v 1000k -acodec mp3 output.mp4
