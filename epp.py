import os
from pathlib import Path
from fpdf import FPDF
import imageio.v2 as imageio

# Importar librerías funcionales
try:
    import exifread
except ImportError:
    exifread = None

try:
    from PIL import Image
except ImportError:
    Image = None

try:
    import piexif
except ImportError:
    piexif = None


def extract_with_exifread(filepath):
    try:
        if exifread is None:
            return "Librería no encontrada"
        
        with open(filepath, 'rb') as f:
            tags = exifread.process_file(f, details=False)
        
        if not tags:
            return "No se pudo leer este archivo"
        
        data = {}
        for tag, value in tags.items():
            data[tag] = str(value)
        return data
    except Exception as e:
        return f"Error: {str(e)}"


def extract_with_pillow(filepath):
    try:
        if Image is None:
            return "Librería no encontrada"
        
        image = Image.open(filepath)
        exif_data = image._getexif()
        
        if not exif_data:
            return "No se pudo leer este archivo"
        
        data = {}
        for tag_id, value in exif_data.items():
            data[f"Tag {tag_id}"] = str(value)
        return data
    except Exception as e:
        return f"Error: {str(e)}"


def extract_with_piexif(filepath):
    try:
        if piexif is None:
            return "Librería no encontrada"
        
        exif_dict = piexif.load(filepath)
        
        if not exif_dict:
            return "No se pudo leer este archivo"
        
        data = {}
        for ifd_name in ("0th", "Exif", "GPS", "1st"):
            ifd = exif_dict[ifd_name]
            for tag in ifd:
                tag_name = piexif.TAGS[ifd_name][tag]["name"]
                value = ifd[tag]
                data[tag_name] = str(value)
        return data
    except Exception as e:
        return f"Error: {str(e)}"


def format_metadata(metadata):
    if isinstance(metadata, str):
        return metadata
    
    if isinstance(metadata, dict):
        lines = []
        for key, value in metadata.items():
            lines.append(f"{key}: {value}")
        return "\n".join(lines) if lines else "No se pudo leer este archivo"
    
    return str(metadata)


def extract_all_metadata(filepath):
    results = {}
    
    extractors = [
        ('exifread', extract_with_exifread),
        ('Pillow', extract_with_pillow),
        ('piexif', extract_with_piexif),
    ]
    
    for name, extractor in extractors:
        try:
            metadata = extractor(filepath)
            results[name] = format_metadata(metadata)
        except Exception as e:
            results[name] = f"Error: {str(e)}"
    
    return results


def create_pdf(filename, metadata_results):
    pdf_filename = f"{Path(filename).stem}_report.pdf"
    
    pdf = FPDF()
    pdf.set_auto_page_break(auto=True, margin=15)
    pdf.set_left_margin(15)
    pdf.set_right_margin(15)
    
    for library_name, metadata_text in metadata_results.items():
        pdf.add_page()
        
        # Título de la librería
        pdf.set_font("Helvetica", "B", 14)
        pdf.cell(0, 10, library_name, new_x="LMARGIN", new_y="NEXT")
        pdf.ln(5)
        
        # Datos metadatos
        pdf.set_font("Courier", "", 8)
        
        for line in metadata_text.split('\n'):
            # Sanitizar caracteres problemáticos
            line = line.encode('utf-8', 'ignore').decode('utf-8')
            line = line.replace('\x00', '')
            
            # Partir líneas muy largas
            if len(line) > 100:
                line = line[:100]
            
            try:
                pdf.multi_cell(0, 4, line, new_x="LMARGIN", new_y="NEXT")
            except:
                pdf.multi_cell(0, 4, "Línea con caracteres no procesables", new_x="LMARGIN", new_y="NEXT")
    
    pdf.output(pdf_filename)
    print(f"✓ PDF generado: {pdf_filename}")


def main():
    current_dir = Path('.')
    supported_formats = {'.dng', '.nef', '.cr2', '.cr3', '.arw', '.pef', '.raf', '.orf', '.jpg', '.jpeg', '.mp4', '.mov'}
    
    files = [f for f in current_dir.iterdir() 
             if f.is_file() and f.suffix.lower() in supported_formats]
    
    if not files:
        print("No se encontraron archivos soportados en la carpeta.")
        return
    
    print(f"\nEncontrados {len(files)} archivo(s).\n")
    
    for file_path in files:
        print(f"Procesando: {file_path.name}")
        metadata = extract_all_metadata(str(file_path))
        create_pdf(str(file_path), metadata)
    
    print("\n✓ Proceso completado.")


if __name__ == "__main__":
    main()
