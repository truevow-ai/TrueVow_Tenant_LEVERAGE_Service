"""
Tests for app/services/validation_engine.py
Pure functions — no DB, no mocks needed for most cases.
"""

import pytest
from app.services.validation_engine import (
    validate_document,
    _check_rule,
    _check_required_field,
    _check_content,
    _check_section_exists,
    _check_content_exists,
    _check_keywords,
    _check_phrase,
    _check_format,
    _check_citation,
    _check_length,
)


# ─────────────────────────────────────────────────
#  validate_document  (top-level)
# ─────────────────────────────────────────────────

class TestValidateDocument:
    def test_returns_passed_when_no_rules(self):
        result = validate_document("some text", [])
        assert result["validation_passed"] is True
        assert result["errors"] == []
        assert result["warnings"] == []
        assert result["info"] == []
        assert result["total_rules_checked"] == 0
        assert result["errors_count"] == 0
        assert result["warnings_count"] == 0
        assert result["info_count"] == 0
        assert "validation_duration_ms" in result

    def test_error_severity_goes_to_errors_list(self):
        rules = [
            {
                "id": "r1",
                "rule_name": "Require SSN",
                "rule_type": "required_field",
                "severity": "error",
                "rule_config": {"field_name": "SSN", "required": True},
            }
        ]
        # Document truly does not contain the word 'SSN'
        result = validate_document("The defendant was negligent.", rules)
        assert result["validation_passed"] is False
        assert len(result["errors"]) == 1
        assert result["errors_count"] == 1

    def test_warning_severity_goes_to_warnings_list(self):
        rules = [
            {
                "id": "r2",
                "rule_name": "Prefer short doc",
                "rule_type": "length_check",
                "severity": "warning",
                "rule_config": {"max_words": 1},
            }
        ]
        result = validate_document("two words here", rules)
        assert result["validation_passed"] is True
        assert len(result["warnings"]) == 1
        assert result["warnings_count"] == 1

    def test_info_severity_goes_to_info_list(self):
        rules = [
            {
                "id": "r3",
                "rule_name": "FYI citation",
                "rule_type": "citation_check",
                "severity": "info",
                "rule_config": {"citation": "MissingCitation"},
            }
        ]
        result = validate_document("no citation", rules)
        assert result["validation_passed"] is True
        assert len(result["info"]) == 1
        assert result["info_count"] == 1

    def test_passing_rule_does_not_add_violation(self):
        rules = [
            {
                "id": "r4",
                "rule_name": "Phrase check",
                "rule_type": "content_check",
                "severity": "error",
                "rule_config": {"check_type": "contains_phrase", "phrase": "attorney"},
            }
        ]
        result = validate_document("This document is signed by the attorney.", rules)
        assert result["validation_passed"] is True
        assert result["errors"] == []

    def test_bad_rule_type_does_not_crash(self):
        rules = [
            {
                "id": "r5",
                "rule_name": "Unknown",
                "rule_type": "nonexistent_type",
                "severity": "error",
                "rule_config": {},
            }
        ]
        result = validate_document("text", rules)
        assert result["validation_passed"] is True  # no violation from unknown type

    def test_exception_in_rule_is_swallowed(self):
        # rule_config with a regex that will throw TypeError when document can't be parsed
        rules = [
            {
                "id": "r6",
                "rule_name": "Broken rule",
                "rule_type": "required_field",
                "severity": "error",
                "rule_config": {"field_name": "X", "pattern": "[invalid_regex"},
            }
        ]
        # Should not raise; continues to next rule
        result = validate_document("some text", rules)
        # Broken regex raises, caught internally — still returns result dict
        assert isinstance(result, dict)

    def test_multiple_rules_accumulate_violations(self):
        rules = [
            {
                "id": "r1",
                "rule_name": "Need SSN",
                "rule_type": "required_field",
                "severity": "error",
                "rule_config": {"field_name": "SSN"},
            },
            {
                "id": "r2",
                "rule_name": "Need DOB",
                "rule_type": "required_field",
                "severity": "error",
                "rule_config": {"field_name": "date of birth"},
            },
        ]
        result = validate_document("empty document", rules)
        assert result["errors_count"] == 2
        assert result["total_rules_checked"] == 2

    def test_duration_ms_is_non_negative(self):
        result = validate_document("text", [])
        assert result["validation_duration_ms"] >= 0


# ─────────────────────────────────────────────────
#  _check_required_field
# ─────────────────────────────────────────────────

class TestCheckRequiredField:
    def test_field_not_required_returns_none(self):
        result = _check_required_field("anything", {"field_name": "SSN", "required": False})
        assert result is None

    def test_field_name_present_no_pattern_returns_none(self):
        result = _check_required_field("SSN is present", {"field_name": "SSN"})
        assert result is None

    def test_field_name_absent_no_pattern_returns_violation(self):
        result = _check_required_field("nothing here", {"field_name": "SSN"})
        assert result is not None
        assert "SSN" in result["message"]

    def test_pattern_matches_returns_none(self):
        result = _check_required_field(
            "SSN: 123-45-6789",
            {"field_name": "SSN", "pattern": r"\d{3}-\d{2}-\d{4}"},
        )
        assert result is None

    def test_pattern_absent_returns_violation(self):
        result = _check_required_field(
            "no ssn",
            {"field_name": "SSN", "pattern": r"\d{3}-\d{2}-\d{4}"},
        )
        assert result is not None
        assert result["details"]["found"] is False

    def test_custom_error_message_used(self):
        # error_message is only used when a pattern is specified (no-pattern path
        # uses a hardcoded message). Use a pattern to trigger the custom message.
        result = _check_required_field(
            "nothing",
            {"field_name": "F", "pattern": r"\d+", "error_message": "Custom error msg"},
        )
        assert result["message"] == "Custom error msg"


# ─────────────────────────────────────────────────
#  _check_content / subtypes
# ─────────────────────────────────────────────────

class TestCheckContent:
    def test_unknown_check_type_returns_none(self):
        result = _check_content("text", "text", ["text"], {"check_type": "unknown_type"})
        assert result is None

    def test_section_exists_found(self):
        result = _check_content(
            "INTRODUCTION\nsome text",
            "introduction\nsome text",
            ["INTRODUCTION", "some text"],
            {"check_type": "section_exists", "section_name": "INTRODUCTION"},
        )
        assert result is None

    def test_content_exists_found(self):
        result = _check_content(
            "Hello world",
            "hello world",
            ["Hello world"],
            {"check_type": "content_exists", "required_content": "hello"},
        )
        assert result is None

    def test_contains_keywords_found(self):
        result = _check_content(
            "The attorney signs here",
            "the attorney signs here",
            [],
            {"check_type": "contains_keywords", "keywords": ["attorney"]},
        )
        assert result is None

    def test_contains_phrase_found(self):
        result = _check_content(
            "binding arbitration clause",
            "binding arbitration clause",
            [],
            {"check_type": "contains_phrase", "phrase": "binding arbitration"},
        )
        assert result is None


class TestCheckSectionExists:
    def test_section_on_own_line(self):
        doc = "INTRODUCTION\nsome content"
        result = _check_section_exists(doc, doc.lower(), {"section_name": "INTRODUCTION"})
        assert result is None

    def test_section_with_colon(self):
        doc = "INTRODUCTION: something"
        result = _check_section_exists(doc, doc.lower(), {"section_name": "INTRODUCTION"})
        assert result is None

    def test_section_missing_returns_violation(self):
        result = _check_section_exists("no section", "no section", {"section_name": "INTRODUCTION"})
        assert result is not None
        assert result["details"]["section_found"] is False

    def test_section_not_required_returns_none(self):
        result = _check_section_exists("no section", "no section", {"section_name": "X", "required": False})
        assert result is None

    def test_keywords_must_be_present(self):
        doc = "INTRODUCTION\ncontent here"
        result = _check_section_exists(
            doc, doc.lower(),
            {"section_name": "INTRODUCTION", "keywords": ["missing_keyword"]}
        )
        assert result is not None
        assert result["details"]["keywords_found"] is False

    def test_keywords_all_present(self):
        doc = "INTRODUCTION\ncontent here with detail"
        result = _check_section_exists(
            doc, doc.lower(),
            {"section_name": "INTRODUCTION", "keywords": ["content", "detail"]}
        )
        assert result is None


class TestCheckContentExists:
    def test_present_returns_none(self):
        assert _check_content_exists("hello world", {"required_content": "hello"}) is None

    def test_absent_returns_violation(self):
        result = _check_content_exists("hello world", {"required_content": "missing"})
        assert result is not None
        assert result["details"]["found"] is False

    def test_empty_required_content_returns_none(self):
        assert _check_content_exists("anything", {"required_content": ""}) is None


class TestCheckKeywords:
    def test_require_all_true_all_present(self):
        result = _check_keywords("alpha beta gamma", {"keywords": ["alpha", "beta"], "require_all": True})
        assert result is None

    def test_require_all_true_one_missing(self):
        result = _check_keywords("alpha", {"keywords": ["alpha", "beta"], "require_all": True})
        assert result is not None

    def test_require_all_false_any_present(self):
        result = _check_keywords("alpha", {"keywords": ["alpha", "missing"], "require_all": False})
        assert result is None

    def test_require_all_false_none_present(self):
        result = _check_keywords("nothing", {"keywords": ["alpha", "beta"], "require_all": False})
        assert result is not None

    def test_empty_keywords_returns_none(self):
        assert _check_keywords("text", {"keywords": []}) is None


class TestCheckPhrase:
    def test_phrase_present(self):
        assert _check_phrase("the quick brown fox", {"phrase": "quick brown"}) is None

    def test_phrase_absent(self):
        result = _check_phrase("the quick brown fox", {"phrase": "lazy dog"})
        assert result is not None
        assert result["details"]["found"] is False

    def test_empty_phrase_returns_none(self):
        assert _check_phrase("anything", {"phrase": ""}) is None


# ─────────────────────────────────────────────────
#  _check_format
# ─────────────────────────────────────────────────

class TestCheckFormat:
    def test_header_exists_non_empty_first_line(self):
        result = _check_format("Smith & Associates\n123 Main St", "smith & associates", ["Smith & Associates", "123 Main St"], {"check_type": "header_exists"})
        assert result is None

    def test_header_missing_empty_lines(self):
        result = _check_format("", "", [], {"check_type": "header_exists"})
        assert result is not None
        assert result["details"]["found"] is False

    def test_unknown_format_check_type_returns_none(self):
        result = _check_format("text", "text", ["text"], {"check_type": "unknown_format"})
        assert result is None


# ─────────────────────────────────────────────────
#  _check_citation
# ─────────────────────────────────────────────────

class TestCheckCitation:
    def test_citation_present(self):
        doc = "See Cal. Civ. Code § 1542 for details."
        result = _check_citation(doc, doc.lower(), {"citation": "Cal. Civ. Code § 1542"})
        assert result is None

    def test_citation_absent(self):
        result = _check_citation("no citations", "no citations", {"citation": "Cal. Civ. Code § 1542"})
        assert result is not None
        assert "Cal. Civ. Code § 1542" in result["message"]

    def test_empty_citation_returns_none(self):
        assert _check_citation("text", "text", {"citation": ""}) is None

    def test_custom_error_message(self):
        result = _check_citation("x", "x", {"citation": "ABC", "error_message": "Missing ABC citation"})
        assert result["message"] == "Missing ABC citation"


# ─────────────────────────────────────────────────
#  _check_length
# ─────────────────────────────────────────────────

class TestCheckLength:
    def test_no_constraints_returns_none(self):
        assert _check_length("hello world", {}) is None

    def test_min_words_violated(self):
        result = _check_length("short", {"min_words": 10})
        assert result is not None
        assert "1 words" in result["message"]

    def test_max_words_violated(self):
        result = _check_length("one two three four five", {"max_words": 3})
        assert result is not None
        assert "5 words" in result["message"]

    def test_min_chars_violated(self):
        result = _check_length("hi", {"min_characters": 100})
        assert result is not None
        assert "characters" in result["message"]

    def test_max_chars_violated(self):
        result = _check_length("a" * 200, {"max_characters": 100})
        assert result is not None
        assert "characters" in result["message"]

    def test_within_all_constraints_returns_none(self):
        doc = "hello world how are you"
        result = _check_length(doc, {"min_words": 1, "max_words": 100, "min_characters": 1, "max_characters": 1000})
        assert result is None

    def test_custom_error_message_in_config(self):
        result = _check_length("hi", {"min_words": 100, "error_message": "Too short!"})
        assert result["message"] == "Too short!"

    def test_multiple_violations_all_reported(self):
        result = _check_length("hi", {"min_words": 5, "min_characters": 1000})
        assert result is not None
        assert result["details"]["word_count"] == 1
        assert result["details"]["character_count"] == 2


# ─────────────────────────────────────────────────
#  _check_rule dispatch
# ─────────────────────────────────────────────────

class TestCheckRuleDispatch:
    def test_required_field_dispatched(self):
        result = _check_rule("SSN present", "ssn present", ["SSN present"], "required_field", {"field_name": "SSN"})
        assert result is None

    def test_content_check_dispatched(self):
        result = _check_rule("keyword", "keyword", ["keyword"], "content_check", {"check_type": "contains_keywords", "keywords": ["keyword"]})
        assert result is None

    def test_format_check_dispatched(self):
        result = _check_rule("header line", "header line", ["header line"], "format_check", {"check_type": "header_exists"})
        assert result is None

    def test_citation_check_dispatched(self):
        result = _check_rule("See ABC", "see abc", [], "citation_check", {"citation": "abc"})
        assert result is None

    def test_length_check_dispatched(self):
        result = _check_rule("hello", "hello", ["hello"], "length_check", {"min_words": 100})
        assert result is not None

    def test_unknown_rule_type_returns_none(self):
        result = _check_rule("text", "text", ["text"], "not_a_real_type", {})
        assert result is None
