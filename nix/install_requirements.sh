#!/usr/bin/sh

# package requirements
rq_firmware="firmware-linux firmware-iwlwifi firmware-realtek nvidia-driver"
rq_build="build-essential emacs cups"
rq_pass="keepassxc"

rq_fonts="fonts-inconsolata ttf-bitstream-vera"
rq_tex="texlive texlive-extra-utils texlive-latex-extra texlive-bibtex-extra cm-super"
rq_pdf="pdftk okular evince mupdf mupdf-tools" # okular needs `qt5-style-plugins`
rq_edit="kate gedit" # kate needs `konsole` for the terminal
rq_img="gpicview libtiff-dev imagemagick kolourpaint"
# kolourpaint needs `breeze-icon-theme`
rq_multimedia="ffmpeg mpv"
rq_xfce="xfce4-battery-plugin xfce4-datetime-plugin
 xfce4-screenshooter xfce4-taskmanager xfce4-weather-plugin
 xfce4-xkb-plugin"

requirements="$rq_firmware $rq_build
 $rq_pass
 $rq_fonts
 $rq_tex
 $rq_pdf
 $rq_edit
 $rq_img
 $rq_multimedia
 $rq_xfce
"

pkgStatus ()
# check package status (installed or not installed)
{
  dpkg -l "$1" 2>/dev/null | grep -e "^ii"
}

for pkg in $requirements; do
  echo "==> Package: $pkg"
  pkg_status=$(pkgStatus "$pkg")
  if [ ! -z "$pkg_status" ]; then
      echo "\t$pkg already installed:"
      echo "\t$pkg_status"
  else
    # install the package
    echo "%%%" apt install "$pkg"
  fi
  echo "========================================"
done
