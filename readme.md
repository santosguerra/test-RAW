# Extractor de Metadatos RAW Multi-Librería

## Descripción

Script de Python que extrae metadatos de archivos RAW, JPG, MP4 y MOV usando múltiples librerías de extracción simultáneamente. Genera un PDF por archivo procesado con un reporte comparativo de qué librería extrae mejor los metadatos de cada formato.

Útil para evaluar y comparar el desempeño de diferentes librerías antes de elegir cuál usar en tu proyecto.

## Propósito

Permite a desarrolladores y fotógrafos:
- Probar múltiples librerías de extracción de metadatos EXIF/RAW
- Generar reportes en PDF comparativos por archivo
- Identificar cuál librería funciona mejor con cada formato de cámara
- Tomar decisiones informadas sobre qué dependencias instalar

## Formatos Soportados

- **RAW**: DNG, NEF (Nikon), CR2 (Canon), CR3 (Canon), ARW (Sony), PEF (Pentax), RAF (Fujifilm), ORF (Olympus)
- **Imágenes**: JPG, JPEG
- **Video**: MP4, MOV

## Scripts Disponibles

### app.py
Script completo que prueba todas las librerías disponibles. Útil para evaluar y comparar el desempeño de cada librería con tus archivos específicos.

### epp.py
Variante optimizada que **solo utiliza las librerías recomendadas**:
- **(e)** exifread
- **(p)** piexif
- **(p)** Pillow

Ideal si ya evaluaste las librerías y solo quieres usar las que funcionan mejor. Genera PDFs más rápido sin intentar librerías que fallan.

**Recomendación:** Comienza con `app.py` para evaluar, luego usa `epp.py` en producción.

## Requisitos del Sistema

- Python 3.8 o superior
- Linux, macOS o Windows

## Instalación

### Opción 1: Instalador automático (recomendado)

```bash
chmod +x install.sh
./install.sh
```

El script:
- Verifica la versión de Python
- Instala todas las librerías
- Instala exiftool del sistema operativo
- Configura los permisos necesarios

### Opción 2: Instalación manual

```bash
# Instalar librerías Python
pip install exifread Pillow piexif pyexiftool rawpy exif imageio fpdf2

# Instalar exiftool según tu SO

# Linux (Debian/Ubuntu):
sudo apt-get install exiftool

# macOS:
brew install exiftool

# Windows:
# Descargar desde https://exiftool.org/ o usar:
choco install exiftool
```

## Uso

1. Coloca los archivos a analizar en una carpeta
2. Copia `app.py` en la misma carpeta
3. Ejecuta:

```bash
python app.py
```

Se generarán PDFs `nombre_archivo_report.pdf` con los resultados de cada librería.

## Estructura del PDF Generado

Cada PDF contiene:
- Una página por librería
- Título con nombre de la librería
- Metadatos extraídos en formato `clave: valor`
- Saltos de página entre librerías

## Desinstalación

```bash
chmod +x uninstall.sh
./uninstall.sh
```

El script permite seleccionar qué librerías desinstalar individualmente.

## Ejemplos de Salida

```
Encontrados 8 archivo(s).

Procesando: _MG_9819.JPG
✓ PDF generado: _MG_9819_report.pdf

Procesando: _DSC6671.NEF
✓ PDF generado: _DSC6671_report.pdf

✓ Proceso completado.
```

## Licencia

GPL v2 - Eres libre de usar, modificar y distribuir este software bajo los términos de la Licencia Pública General GNU versión 2.

## Autor

Santos R. Guerra F.
URL: santosguerra.com

## Notas

- Las librerías fallan silenciosamente si no pueden leer un formato específico
- Se genera un PDF incluso si todas las librerías fallan (para ver qué se intentó)
- Algunos formatos RAW pueden requerir decodificadores adicionales en el sistema
- CR3 (Canon RAW 3) actualmente no se puede leer con las librerías incluidas