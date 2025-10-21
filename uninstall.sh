#!/bin/bash

echo "================================"
echo "Extractor de Metadatos RAW"
echo "Desinstalador de Dependencias"
echo "================================"
echo ""

# Arrays de librerías
declare -a LIBS=(
    "exifread:Lectura de EXIF (recomendada)"
    "Pillow:Lectura básica EXIF JPG"
    "piexif:Lectura/escritura EXIF (recomendada)"
    "pyexiftool:Wrapper de exiftool"
    "rawpy:Lectura de archivos RAW"
    "exif:Lectura de EXIF"
    "imageio:Lectura múltiples formatos"
    "fpdf2:Generación de PDFs"
)

declare -a SELECTED=()

# Menú interactivo
echo "Selecciona las librerías a desinstalar:"
echo ""

for i in "${!LIBS[@]}"; do
    IFS=':' read -r lib desc <<< "${LIBS[$i]}"
    echo "  [$((i+1))] $lib - $desc"
done

echo ""
echo "  [0] Cancelar (no desinstalar nada)"
echo "  [A] Desinstalar TODAS"
echo "  [K] Mantener recomendadas (desinstalar el resto)"
echo ""
read -p "Ingresa las opciones separadas por comas (ej: 1,3,5) o letra: " input

# Procesar entrada
if [[ "$input" == "0" ]]; then
    echo "Operación cancelada"
    exit 0
fi

if [[ "$input" == "A" || "$input" == "a" ]]; then
    echo "Desinstalando TODAS las librerías..."
    for lib_entry in "${LIBS[@]}"; do
        IFS=':' read -r lib desc <<< "$lib_entry"
        echo "  - Desinstalando $lib..."
        pip uninstall -y "$lib" 2>/dev/null || true
    done
fi

if [[ "$input" == "K" || "$input" == "k" ]]; then
    echo "Desinstalando librerías NO recomendadas (manteniendo exifread y piexif)..."
    # Librerías que no funcionan bien: rawpy, exif, imageio, pyexiftool
    libs_to_remove=("rawpy" "exif" "imageio" "pyexiftool")
    for lib in "${libs_to_remove[@]}"; do
        echo "  - Desinstalando $lib..."
        pip uninstall -y "$lib" 2>/dev/null || true
    done
fi

# Procesar números
if [[ "$input" =~ ^[0-9,]+$ ]]; then
    IFS=',' read -ra numbers <<< "$input"
    for num in "${numbers[@]}"; do
        idx=$((num - 1))
        if [[ $idx -ge 0 && $idx -lt ${#LIBS[@]} ]]; then
            lib_entry="${LIBS[$idx]}"
            IFS=':' read -r lib desc <<< "$lib_entry"
            echo "  - Desinstalando $lib..."
            pip uninstall -y "$lib" 2>/dev/null || true
        fi
    done
fi

# Desinstalar exiftool (opcional)
echo ""
read -p "¿Desinstalar exiftool del sistema? (s/n): " remove_exiftool

if [[ "$remove_exiftool" == "s" || "$remove_exiftool" == "S" ]]; then
    echo "Desinstalando exiftool..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get remove -y exiftool > /dev/null 2>&1 && echo "  ✓ exiftool removido vía apt-get" || echo "  ✗ Error al remover exiftool"
        elif command -v yum &> /dev/null; then
            sudo yum remove -y exiftool > /dev/null 2>&1 && echo "  ✓ exiftool removido vía yum" || echo "  ✗ Error al remover exiftool"
        elif command -v pacman &> /dev/null; then
            sudo pacman -R --noconfirm exiftool > /dev/null 2>&1 && echo "  ✓ exiftool removido vía pacman" || echo "  ✗ Error al remover exiftool"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew uninstall exiftool > /dev/null 2>&1 && echo "  ✓ exiftool removido vía Homebrew" || echo "  ✗ Error al remover exiftool"
        fi
    fi
fi

echo ""
echo "================================"
echo "Desinstalación completada"
echo "================================"
echo ""
