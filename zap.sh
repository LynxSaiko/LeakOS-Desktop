#!/usr/bin/env bash
# =========================================================
# OWASP ZAP Launcher - Fixed for Minimal Linux / DWM / LFS
# =========================================================

SCRIPTNAME="$0"
while [ -L "${SCRIPTNAME}" ]; do
  cd "$(dirname "${SCRIPTNAME}")" >/dev/null
  SCRIPTNAME="$(readlink "$(basename "${SCRIPTNAME}")")"
done
cd "$(dirname "${SCRIPTNAME}")" >/dev/null
BASEDIR="$(pwd -P)"

# =========================================================
# === FIX: GUI blank white & AWT access issues ============
# =========================================================
export _JAVA_AWT_WM_NONREPARENTING=1
export AWT_TOOLKIT=MToolkit
export GDK_BACKEND=x11
export JAVA_FONTS=/usr/share/fonts
export BROWSER=/usr/bin/xdg-open
export GTK_THEME=leak
JAVA_OPTS="--add-opens java.desktop/sun.awt.X11=ALL-UNNAMED \
-Dsun.java2d.opengl=true \
-Dsun.java2d.xrender=true \
-Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel \
-Dawt.useSystemAAFontSettings=on \
-Dswing.aatext=true \
-Djava.awt.headless=false"

# =========================================================
# === Detect Java =========================================
# =========================================================
if ! command -v java >/dev/null 2>&1; then
  echo "Error: Java tidak ditemukan di PATH."
  echo "Pastikan sudah install OpenJDK 17 atau lebih baru."
  exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | awk -F\" '/version/ {print $2}')
JAVA_MAJOR_VERSION=${JAVA_VERSION%%[.|-]*}
if [ ${JAVA_MAJOR_VERSION:-0} -lt 17 ]; then
  echo "ZAP membutuhkan minimal Java 17 (ditemukan: $JAVA_VERSION)"
  exit 1
fi

# =========================================================
# === Hitung memori =======================================
# =========================================================
if [ -r /proc/meminfo ]; then
  MEM=$(awk '/MemTotal:/ {printf "%.0f", $2/1024}' /proc/meminfo)
  if [ "$MEM" -gt 512 ]; then
    JMEM="-Xmx$((MEM/4))m"
  else
    JMEM="-Xmx512m"
  fi
else
  JMEM="-Xmx512m"
fi

# =========================================================
# === Jalankan ZAP ========================================
# =========================================================
ZAP_JAR="${BASEDIR}/zap-2.16.1.jar"

if [ ! -f "$ZAP_JAR" ]; then
  echo "File ZAP jar tidak ditemukan di: $ZAP_JAR"
  exit 1
fi

echo "Menjalankan ZAP..."
echo "Java: $(java -version 2>&1 | head -n 1)"
echo "Memori: $JMEM"
echo "Opsi: $JAVA_OPTS"

exec java $JAVA_OPTS $JMEM -jar "$ZAP_JAR" "$@"
