"""Offline document text extraction. Never executes document content."""
import sys,json,pathlib,zipfile,xml.etree.ElementTree as ET
from pypdf import PdfReader
LIMIT=2_000_000
def extract(path):
 p=pathlib.Path(path)
 if not p.is_file() or p.stat().st_size>20_000_000: raise ValueError('Choose a readable file below 20 MB.')
 if p.suffix.lower()=='.pdf':
  reader=PdfReader(str(p))
  if reader.is_encrypted: raise ValueError('Password-protected PDFs are not supported. Export an unlocked copy.')
  if len(reader.pages)>100: raise ValueError('Maximum 100 PDF pages.')
  parts=[];size=0
  for page in reader.pages:
   text=page.extract_text() or '';size+=len(text)
   if size>LIMIT: raise ValueError('Extracted text exceeds 2 MB.')
   parts.append(text)
  result='\n'.join(parts)
  if not result.strip(): raise ValueError('No selectable text found. Scanned PDFs need OCR first, or paste the formatted questions.')
 elif p.suffix.lower()=='.docx':
  with zipfile.ZipFile(p) as z:
   info=z.getinfo('word/document.xml')
   if info.file_size>LIMIT*4: raise ValueError('Word document text is too large.')
   root=ET.fromstring(z.read(info))
  ns='{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'
  result='\n'.join(''.join((n.text or '') if n.tag==ns+'t' else '\t' if n.tag==ns+'tab' else '\n' if n.tag==ns+'br' else '' for n in para.iter()) for para in root.iter(ns+'p'))
 elif p.suffix.lower()=='.txt': result=p.read_text(encoding='utf-8-sig')
 else: raise ValueError('Use PDF, DOCX or UTF-8 TXT.')
 if len(result)>LIMIT: raise ValueError('Extracted text exceeds 2 MB.')
 return result
if __name__=='__main__':
 try: result={'text':extract(sys.argv[1]),'error':''}
 except Exception as e: result={'text':'','error':str(e)[:500]}
 target=pathlib.Path(sys.argv[2]);temp=target.with_suffix('.tmp')
 temp.write_text(json.dumps(result,ensure_ascii=False),encoding='utf-8');temp.replace(target)
