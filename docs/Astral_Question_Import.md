# Import Astral questions

Open Host Lobby > Astral Library > Import questions. Choose PDF / DOCX / TXT, or paste text. Use example format inserts three working web-development cards. Review questions validates the whole document; Add questions to deck appends them without replacing existing cards. Review each answer in Player Preview, then Save or Use this deck.

## Prepare a document
Copy resources/questions/import_template.txt into Word or a text editor. Replace the example questions and answers. Repeat a [QUESTION] ... [END] block for each card. Save as DOCX, UTF-8 TXT, or export a selectable-text PDF. Use one column, ordinary paragraphs, no page numbers/headers/footers, tables or decorative text. Keep code short; TXT or DOCX best preserves indentation. Labels must be uppercase and start their own lines. CODE, QUESTION, ANSWER and EXPLANATION can continue on following lines. Avoid reserved field labels at the start of code lines.

- MULTIPLE_CHOICE: QUESTION, A, B, C, D and one ANSWER letter are required.
- IDENTIFICATION: QUESTION and ANSWER are required. Repeat ANSWER for each accepted alternative; case and extra whitespace are ignored during play.
- CODE_FIX: QUESTION, CODE containing the broken code, and ANSWER containing the full accepted correction are required. Repeat ANSWER for alternative correct versions. Code matching preserves case and internal spacing; the game does not execute code.
- GOLD is optional, defaults to 25, and accepts whole numbers 1–1000. EXPLANATION is optional. DECK is an optional document title; appending keeps the current deck name.

Ordinary prose is not rewritten into questions by AI. This importer converts already formatted question content. Scanned/image-only PDFs need OCR outside the game. Always review extracted code: PDFs can change spaces, line breaks or reading order. Format validation cannot determine whether a teacher's answer is factually correct.

## Limits and packaging
Offline extraction: PDF/DOCX up to 20 MB, PDFs up to 100 pages, extracted text up to 2 million characters, and decks up to 500 cards. Encrypted PDFs are rejected. Cancel closes the import and cancels extraction. Existing deck and active match selection are unchanged until you add/save/use.

Windows exports must include tools/astral_import/bin/astral_extract.exe beside the game executable at that same relative path. Include resources/questions/import_template.txt in the export's non-resource file filter. The importer can still accept pasted text without the helper. Rebuild the helper with Python, pypdf==6.19.0 and pyinstaller==6.22.3: python -m PyInstaller --clean --noconfirm --onefile --name astral_extract --distpath tools/astral_import/bin tools/astral_import/extract_notes.py.

The background is generated artwork based on the approved Astral Library concept. Panels, fields, buttons, lists and labels are editable Godot nodes in scenes/questions/deck_editor.tscn and question_import_dialog.tscn.
