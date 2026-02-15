#!/bin/bash
# =========================================
# Instalador desatendido GPSafe Web 6.11.1
# Clona todo el frontend al directorio /opt/traccar/web
# Muestra solo la cantidad de archivos a copiar
# =========================================

set -e
set -o pipefail

REPO_GIT="https://github.com/jcares/web-gpsafe2026V6.11.1.git"
TMP_DIR="/tmp/web-gpsafe"
DEST_DIR="/opt/traccar/web"

echo "==> Inicio de instalación GPSafe Web 6.11.1"

# -----------------------------
# Verificar permisos sudo
# -----------------------------
if [ "$EUID" -ne 0 ]; then
  echo "ERROR: Este script necesita permisos sudo"
  echo "Ejecuta: sudo bash $0"
  exit 1
fi

# -----------------------------
# Clonar repositorio temporal
# -----------------------------
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

echo "==> Clonando repositorio desde GitHub..."
git clone --depth 1 "$REPO_GIT" "$TMP_DIR"

# -----------------------------
# Contar cantidad de archivos
# -----------------------------
TOTAL_FILES=$(find "$TMP_DIR" -type f | wc -l)
echo "==> Archivos a copiar: $TOTAL_FILES"

# -----------------------------
# Backup de frontend anterior
# -----------------------------
if [ -d "$DEST_DIR" ]; then
    BACKUP_DIR="${DEST_DIR}_backup_$(date +%Y%m%d%H%M%S)"
    echo "==> Creando backup de la versión anterior en $BACKUP_DIR"
    mv "$DEST_DIR" "$BACKUP_DIR"
fi

# -----------------------------
# Crear carpeta destino si no existe
# -----------------------------
mkdir -p "$DEST_DIR"

# -----------------------------
# Copiar todo el contenido
# -----------------------------
echo "==> Copiando todos los archivos al destino..."
cp -a "$TMP_DIR/." "$DEST_DIR"

# -----------------------------
# Ajustar permisos
# -----------------------------
TRACCAR_USER=$(ps -eo user,comm | grep traccar | grep -v grep | awk '{print $1}' | head -n1)
if [ -z "$TRACCAR_USER" ]; then
    TRACCAR_USER="traccar"
fi

echo "==> Ajustando permisos para el usuario: $TRACCAR_USER"
chown -R "$TRACCAR_USER":"$TRACCAR_USER" "$DEST_DIR"
chmod -R 755 "$DEST_DIR"

# -----------------------------
# Finalización
# -----------------------------
echo "========================================="
echo " Instalación completada."
echo " Carpeta destino: $DEST_DIR"
echo " Usuario propietario: $TRACCAR_USER"
echo " Archivos copiados: $TOTAL_FILES"
echo " Si es necesario, reinicia el servidor Traccar:"
echo " sudo systemctl restart traccar"
echo "========================================="
