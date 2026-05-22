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
## get size of a folder and its subfolders
du -h --max-depth=N .

# produce ctags for .c, .h, .cpp, .hpp files
find . -regex ".+\.[ch]\(pp\)*" | etags -

# EMacs tags
find . -name '*.[ch]pp' -o -name '*.[ch]xx' -o -name '*.[ch]' | xargs etags

# zip/unzip
zip -r file.zip dir
unzip file.zip -d outdir

# apt
apt list
apt policy mypkg

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

# Python and Jupyter notebook
actPy && python3 -m jupyterlab
python3 -c "import numpy as np;"

# resetting Git tags
git tag --delete v22.0
git push --delete origin v22.0
git tag v22.0
git push --tag

# safely remove a external harddisk or usb stick
lsblk
sudo umount /dev/sdX
sudo udisksctl power-off -b /dev/sdX
# or
sudo udisks --detach /dev/sdX

## images
# strip image metadata
mogrify -strip img*.png

# show detailed image metadata
identify -verbose img.png

# montage images
montage $imgs -tile 2x2 -geometry +30+30 final_2by2.png

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

ffmpeg -i input.mp4 -vf "scale=trunc(iw/4)*2:trunc(ih/4)*2" -c:v libx264 -crf 28 -c:a aac -b:a 64k output.mp4

## adjust bitrate
## `-b:v 1000k`: sets video bitrate to 1000kbps. Lowering this can greatly reduce size, but also quality.

ffmpeg -i input.mp4 -vcodec h264 -b:v 1000k -acodec mp3 output.mp4

# mpv play
mpv --autofit-larger=50%x50% --volume=50 <video-link>
mpv --no-video --start=00:30:00 <video-link>

# reduce PDF size
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile=output.pdf input.pdf

# pandoc

## convert markdown to pdf
pandoc --template=eisvogel.latex --from markdown myfile.md --pdf-engine=xelatex -o myfile.pdf

## templates for markdown to LaTeX:
<https://github.com/Wandmalfarbe/pandoc-latex-template>

# inkscape <https://inkscape.org/doc/inkscape-man.html>
inkscape --export-dpi=150 --export-area-drawing --export-background=#ffffff --pdf-poppler --export-type=png --export-png-color-mode=Gray_8 --pdf-page=<PAGE_NUMBER> --export-filename="$input_file" "$output_file"

# tee: capture stdout and stderr in a file
df -h 2>&1 | tee log.txt
