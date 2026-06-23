"""
Tests for document_parser.py - comprehensive coverage of all parse paths.
"""

import io
import struct
import pytest
from unittest.mock import patch, MagicMock

from app.services.document_parser import parse_document, _parse_pdf, _parse_docx, _parse_text


# ─── Helpers ───────────────────────────────────────────────────────────────────

def _minimal_pdf_bytes() -> bytes:
    """Return the smallest valid-ish PDF bytes for PyPDF2 to handle."""
    return b"%PDF-1.4\n1 0 obj\n<< /Type /Catalog >>\nendobj\nxref\n0 1\n0000000000 65535 f \ntrailer\n<< /Size 1 /Root 1 0 R >>\nstartxref\n9\n%%EOF"


def _make_docx_bytes() -> bytes:
    """Create a minimal real DOCX (ZIP with document.xml)."""
    import zipfile, io
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as zf:
        # Minimal word/document.xml
        doc_xml = (
            '<?xml version="1.0" encoding="UTF-8"?>'
            '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
            '<w:body><w:p><w:r><w:t>Hello world</w:t></w:r></w:p></w:body>'
            '</w:document>'
        )
        zf.writestr("word/document.xml", doc_xml)
        zf.writestr("[Content_Types].xml",
                    '<?xml version="1.0"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
                    '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
                    '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
                    '</Types>')
        zf.writestr("_rels/.rels",
                    '<?xml version="1.0"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
                    '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>'
                    '</Relationships>')
    return buf.getvalue()


# ─── parse_document (router) ───────────────────────────────────────────────────

class TestParseDocument:

    def test_routes_pdf_by_mime(self):
        with patch("app.services.document_parser._parse_pdf") as mock_pdf:
            mock_pdf.return_value = {"parse_success": True, "text": "ok", "metadata": {}}
            result = parse_document(b"data", "application/pdf")
            mock_pdf.assert_called_once()
            assert result["parse_success"] is True

    def test_routes_pdf_by_filename(self):
        with patch("app.services.document_parser._parse_pdf") as mock_pdf:
            mock_pdf.return_value = {"parse_success": True, "text": "", "metadata": {}}
            parse_document(b"data", "application/octet-stream", filename="report.pdf")
            mock_pdf.assert_called_once()

    def test_routes_docx_by_mime(self):
        with patch("app.services.document_parser._parse_docx") as mock_docx:
            mock_docx.return_value = {"parse_success": True, "text": "", "metadata": {}}
            parse_document(b"data", "application/vnd.openxmlformats-officedocument.wordprocessingml.document")
            mock_docx.assert_called_once()

    def test_routes_doc_by_mime(self):
        with patch("app.services.document_parser._parse_docx") as mock_docx:
            mock_docx.return_value = {"parse_success": True, "text": "", "metadata": {}}
            parse_document(b"data", "application/msword")
            mock_docx.assert_called_once()

    def test_routes_docx_by_filename(self):
        with patch("app.services.document_parser._parse_docx") as mock_docx:
            mock_docx.return_value = {"parse_success": True, "text": "", "metadata": {}}
            parse_document(b"data", "application/octet-stream", filename="brief.docx")
            mock_docx.assert_called_once()

    def test_routes_doc_by_filename(self):
        with patch("app.services.document_parser._parse_docx") as mock_docx:
            mock_docx.return_value = {"parse_success": True, "text": "", "metadata": {}}
            parse_document(b"data", "application/octet-stream", filename="brief.doc")
            mock_docx.assert_called_once()

    def test_routes_text_by_mime(self):
        result = parse_document(b"hello world", "text/plain")
        assert result["parse_success"] is True
        assert "hello" in result["text"]

    def test_routes_text_by_filename(self):
        result = parse_document(b"hello", "application/octet-stream", filename="notes.txt")
        assert result["parse_success"] is True

    def test_unsupported_mime_returns_error(self):
        result = parse_document(b"data", "application/zip")
        assert result["parse_success"] is False
        assert "Unsupported" in result["error"]
        assert result["text"] == ""

    def test_exception_in_router_caught(self):
        with patch("app.services.document_parser._parse_text", side_effect=RuntimeError("boom")):
            result = parse_document(b"hi", "text/plain")
            assert result["parse_success"] is False
            assert "boom" in result["error"]


# ─── _parse_pdf ────────────────────────────────────────────────────────────────

class TestParsePdf:

    def test_success_with_mocked_reader(self):
        mock_page = MagicMock()
        mock_page.extract_text.return_value = "Page text"
        mock_reader = MagicMock()
        mock_reader.pages = [mock_page, mock_page]
        with patch("app.services.document_parser.PyPDF2.PdfReader", return_value=mock_reader):
            result = _parse_pdf(b"fake-pdf")
        assert result["parse_success"] is True
        assert result["text"] == "Page text\nPage text"
        assert result["metadata"]["page_count"] == 2
        assert result["metadata"]["word_count"] == 4
        assert result["metadata"]["file_type"] == "application/pdf"
        assert len(result["pages"]) == 2

    def test_empty_pdf_pages(self):
        mock_reader = MagicMock()
        mock_reader.pages = []
        with patch("app.services.document_parser.PyPDF2.PdfReader", return_value=mock_reader):
            result = _parse_pdf(b"fake-pdf")
        assert result["parse_success"] is True
        assert result["text"] == ""
        assert result["metadata"]["page_count"] == 0

    def test_pdf_parse_exception(self):
        with patch("app.services.document_parser.PyPDF2.PdfReader", side_effect=Exception("corrupt")):
            result = _parse_pdf(b"bad-pdf")
        assert result["parse_success"] is False
        assert "corrupt" in result["error"]
        assert result["text"] == ""

    def test_pdf_with_filename(self):
        mock_page = MagicMock()
        mock_page.extract_text.return_value = "content"
        mock_reader = MagicMock()
        mock_reader.pages = [mock_page]
        with patch("app.services.document_parser.PyPDF2.PdfReader", return_value=mock_reader):
            result = _parse_pdf(b"pdf", filename="test.pdf")
        assert result["parse_success"] is True

    def test_word_count_calculated(self):
        mock_page = MagicMock()
        mock_page.extract_text.return_value = "one two three four five"
        mock_reader = MagicMock()
        mock_reader.pages = [mock_page]
        with patch("app.services.document_parser.PyPDF2.PdfReader", return_value=mock_reader):
            result = _parse_pdf(b"pdf")
        assert result["metadata"]["word_count"] == 5
        assert result["metadata"]["character_count"] > 0


# ─── _parse_docx ──────────────────────────────────────────────────────────────

class TestParseDocx:

    def test_invalid_zip_returns_error(self):
        result = _parse_docx(b"not-a-zip")
        assert result["parse_success"] is False
        assert "ZIP" in result["error"]

    def test_success_with_mocked_docx(self):
        """Mock python-docx Document to avoid needing actual DOCX structure."""
        import zipfile, io as _io
        # Create valid zip (so ZipFile check passes)
        buf = _io.BytesIO()
        with zipfile.ZipFile(buf, "w") as zf:
            zf.writestr("dummy.txt", "dummy")
        valid_zip = buf.getvalue()

        mock_para = MagicMock()
        mock_para.text = "Hello world"
        mock_doc = MagicMock()
        mock_doc.paragraphs = [mock_para]
        mock_doc.tables = []
        mock_section = MagicMock()
        mock_section.header = MagicMock()
        mock_doc.sections = [mock_section]

        with patch("app.services.document_parser.DocxDocument", return_value=mock_doc):
            result = _parse_docx(valid_zip)
        assert result["parse_success"] is True
        assert "Hello world" in result["text"]
        assert result["metadata"]["paragraph_count"] == 1
        assert result["metadata"]["word_count"] == 2

    def test_docx_with_tables(self):
        import zipfile, io as _io
        buf = _io.BytesIO()
        with zipfile.ZipFile(buf, "w") as zf:
            zf.writestr("dummy.txt", "")
        valid_zip = buf.getvalue()

        mock_cell1 = MagicMock()
        mock_cell1.text = "Cell1"
        mock_cell2 = MagicMock()
        mock_cell2.text = "Cell2"
        mock_row = MagicMock()
        mock_row.cells = [mock_cell1, mock_cell2]
        mock_table = MagicMock()
        mock_table.rows = [mock_row]

        mock_doc = MagicMock()
        mock_doc.paragraphs = []
        mock_doc.tables = [mock_table]
        mock_doc.sections = []

        with patch("app.services.document_parser.DocxDocument", return_value=mock_doc):
            result = _parse_docx(valid_zip)
        assert result["parse_success"] is True
        assert "Cell1" in result["text"]

    def test_docx_parse_exception_after_zip(self):
        import zipfile, io as _io
        buf = _io.BytesIO()
        with zipfile.ZipFile(buf, "w") as zf:
            zf.writestr("dummy.txt", "")
        valid_zip = buf.getvalue()

        with patch("app.services.document_parser.DocxDocument", side_effect=Exception("docx error")):
            result = _parse_docx(valid_zip)
        assert result["parse_success"] is False
        assert "docx error" in result["error"]

    def test_empty_paragraphs_skipped(self):
        import zipfile, io as _io
        buf = _io.BytesIO()
        with zipfile.ZipFile(buf, "w") as zf:
            zf.writestr("dummy.txt", "")
        valid_zip = buf.getvalue()

        mock_para_empty = MagicMock()
        mock_para_empty.text = "   "  # whitespace only - should be skipped
        mock_para_real = MagicMock()
        mock_para_real.text = "Real content"
        mock_doc = MagicMock()
        mock_doc.paragraphs = [mock_para_empty, mock_para_real]
        mock_doc.tables = []
        mock_doc.sections = []

        with patch("app.services.document_parser.DocxDocument", return_value=mock_doc):
            result = _parse_docx(valid_zip)
        assert result["metadata"]["paragraph_count"] == 1  # only non-empty

    def test_has_header_true(self):
        import zipfile, io as _io
        buf = _io.BytesIO()
        with zipfile.ZipFile(buf, "w") as zf:
            zf.writestr("dummy.txt", "")
        valid_zip = buf.getvalue()

        mock_doc = MagicMock()
        mock_doc.paragraphs = []
        mock_doc.tables = []
        mock_section = MagicMock()
        mock_section.header = MagicMock()  # not None
        mock_doc.sections = [mock_section]

        with patch("app.services.document_parser.DocxDocument", return_value=mock_doc):
            result = _parse_docx(valid_zip)
        assert result["metadata"]["has_header"] is True


# ─── _parse_text ──────────────────────────────────────────────────────────────

class TestParseText:

    def test_utf8_content(self):
        result = _parse_text("Hello UTF-8 world".encode("utf-8"))
        assert result["parse_success"] is True
        assert result["text"] == "Hello UTF-8 world"
        assert result["metadata"]["word_count"] == 3
        assert result["metadata"]["file_type"] == "text/plain"

    def test_latin1_fallback(self):
        # Bytes that are invalid UTF-8 but valid Latin-1
        latin_bytes = b"caf\xe9 menu"  # é in Latin-1
        result = _parse_text(latin_bytes)
        assert result["parse_success"] is True
        assert "caf" in result["text"]

    def test_character_count(self):
        text = "abcde"
        result = _parse_text(text.encode("utf-8"))
        assert result["metadata"]["character_count"] == 5

    def test_empty_text(self):
        result = _parse_text(b"")
        assert result["parse_success"] is True
        assert result["text"] == ""
        assert result["metadata"]["word_count"] == 0

    def test_multiline_word_count(self):
        text = "one two\nthree four five"
        result = _parse_text(text.encode("utf-8"))
        assert result["metadata"]["word_count"] == 5

    def test_exception_handling(self):
        with patch("app.services.document_parser.io.BytesIO", side_effect=Exception("io error")):
            # Even if BytesIO fails, decode still works directly
            pass
        # Force an error in decode path
        bad_bytes = MagicMock()
        bad_bytes.decode = MagicMock(side_effect=Exception("decode error"))
        result = _parse_text(bad_bytes)
        assert result["parse_success"] is False
        assert "decode error" in result["error"]
