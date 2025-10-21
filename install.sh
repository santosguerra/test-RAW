#!/bin/bash

set -e

echo "================================"
echo "Extractor de Metadatos RAW"
echo "Instalador de Dependencias"
echo "================================"
echo ""

# Verificar Python
echo "[1/3] Verificando Python..."
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 no está instalado"
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
echo "Python $PYTHON_VERSION encontrado"

if ! python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 8) else 1)'; then
    echo "Error: Se requiere Python 3.8 o superior"
    exit 1
fi

# Instalar librerías Python
echo ""
echo "[2/3] Instalando librerías Python..."
LIBS=(
    "exifread"
    "Pillow"
    "piexif"
    "pyexiftool"
    "rawpy"
    "exif"
    "imageio"
    "fpdf2"
)

for lib in "${LIBS[@]}"; do
    echo "  - Instalando $lib..."
    pip install "$lib" --quiet
done

echo "Librerías Python instaladas correctamente"

# Instalar exiftool del sistema
echo ""
echo "[3/3] Instalando exiftool del sistema..."

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v apt-get &> /dev/null; then
        echo "Detectado: Debian/Ubuntu"
        sudo apt-get update -qq
        sudo apt-get install -y exiftool > /dev/null 2>&1
        echo "exiftool instalado vía apt-get"
    elif command -v yum &> /dev/null; then
        echo "Detectado: Red Hat/CentOS"
        sudo yum install -y exiftool > /dev/null 2>&1
        echo "exiftool instalado vía yum"
    elif command -v pacman &> /dev/null; then
        echo "Detectado: Arch Linux"
        sudo pacman -S --noconfirm exiftool > /dev/null 2>&1
        echo "exiftool instalado vía pacman"
    else
        echo "Advertencia: No se pudo detectar el gestor de paquetes"
        echo "Instala exiftool manualmente: https://exiftool.org"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew &> /dev/null; then
        echo "Detectado: macOS"
        brew install exiftool > /dev/null 2>&1
        echo "exiftool instalado vía Homebrew"
    else
        echo "Advertencia: Homebrew no está instalado"
        echo "Instala con: brew install exiftool"
    fi
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    echo "Detectado: Windows"
    echo "Descarga e instala exiftool desde: https://exiftool.org"
    echo "O usa: choco install exiftool"
else
    echo "Advertencia: Sistema operativo no reconocido"
    echo "Visita: https://exiftool.org para instalar exiftool"
fi

# Confirmar instalación
echo ""
echo "================================"
echo "Verificando instalación..."
echo "================================"

echo ""
echo "Librerías Python instaladas:"
for lib in "${LIBS[@]}"; do
    if python3 -c "import $(echo $lib | sed 's/-/_/g')" 2>/dev/null; then
        echo "  ✓ $lib"
    else
        echo "  ✗ $lib (fallo)"
    fi
done

echo ""
if command -v exiftool &> /dev/null; then
    EXIF_VERSION=$(exiftool -ver)
    echo "  ✓ exiftool ($EXIF_VERSION)"
else
    echo "  ✗ exiftool (no encontrado)"
fi

echo ""
echo "================================"
echo "Instalación completada"
echo "================================"
echo ""
echo "Próximos pasos:"
echo "1. Coloca los archivos RAW/JPG/MP4 en una carpeta"
echo "2. Copia app.py en la misma carpeta"
echo "3. Ejecuta: python3 app.py"
echo ""
