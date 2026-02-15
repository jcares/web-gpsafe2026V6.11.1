#!/bin/bash
# =========================================
# web-gpsafe2026V6.11.1.sh
# Instalador interactivo del frontend GPSafe
# =========================================
# Autor: PCCuricó SPA
# Contacto: jcares@pccurico.cl
# =========================================

set -e

echo "========================================="
echo " Instalador interactivo - GPSafe Web 6.11.1"
echo "========================================="

# --- Preguntar origen ---
read -p "Ingresa la ruta local del frontend (dejar vacío para clonar desde GitHub): " SRC
if [ -z "$SRC" ]; then
    read -p "Ingrese la URL del repositorio Git (default: https://github.com/jcares/web-gpsafe2026V6.11.1.git): " REPO
    REPO=${REPO:-https://github.com/jcares/web-gpsafe2026V6.11.1.git}
    SRC="/tmp/web-gpsafe"
    echo "Clonando repositorio $REPO en $SRC..."
    git clone --depth 1 "$REPO" "$SRC"
fi

# Verificar carpeta de origen
if [ ! -d "$SRC" ]; then
    echo "ERROR: No se encontró la carpeta de origen $SRC."
    exit 1
fi

# --- Preguntar destino ---
read -p "Ingresa la ruta destino del servidor (ej: /opt/traccar/web): " DEST
DEST=${DEST:-/opt/traccar/web}

echo "==> Creando carpeta destino si no existe..."
sudo mkdir -p "$DEST"

# --- Opcional: usuario y grupo ---
read -p "Ingresa el usuario propietario de la carpeta destino (default: traccar): " USER
USER=${USER:-traccar}
read -p "Ingresa el grupo propietario de la carpeta destino (default: traccar): " GROUP
GROUP=${GROUP:-traccar}

# --- Copiar con progreso ---
echo "==> Copiando archivos al destino ($DEST)..."
# Contar archivos para progreso
TOTAL=$(find "$SRC" -type f | wc -l)
COUNT=0

# Función para copiar y mostrar porcentaje
copy_file() {
    local SRC_FILE="$1"
    local DEST_FILE="$2"
    cp -a "$SRC_FILE" "$DEST_FILE"
    ((COUNT++))
    PERCENT=$((COUNT*100/TOTAL))
    echo -ne "\rProgreso: $PERCENT% ($COUNT/$TOTAL)"
}

export -f copy_file
export COUNT TOTAL

# Copiar todos los archivos
find "$SRC" -type f | while read FILE; do
    REL_PATH="${FILE#$SRC/}"
    DEST_FILE="$DEST/$REL_PATH"
    sudo mkdir -p "$(dirname "$DEST_FILE")"
    copy_file "$FILE" "$DEST_FILE"
done

echo -e "\n==> Archivos copiados correctamente."

# --- Ajustar permisos ---
echo "==> Ajustando permisos de la carpeta destino..."
sudo chown -R "$USER:$GROUP" "$DEST"
sudo chmod -R 755 "$DEST"

# --- Recomendaciones ---
echo "========================================="
echo " Recomendaciones:"
echo "- Verifica que el servidor GPSafe/Traccar esté apuntando a la carpeta $DEST"
echo "- Reinicia el servicio: sudo systemctl restart traccar"
echo "- Si usas autenticación en la API, revisa el usuario y contraseña en app.js"
echo "========================================="

echo "Instalación completada."
