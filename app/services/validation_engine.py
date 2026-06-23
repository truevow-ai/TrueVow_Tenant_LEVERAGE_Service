"""
TrueVow DRAFT™ Service - Validation Engine
Validates documents against compliance rules
"""

import re
import time
import logging
from typing import Dict, Any, List, Optional

logger = logging.getLogger(__name__)


def validate_document(
    document_text: str,
    rules: List[Dict[str, Any]]
) -> Dict[str, Any]:
    """
    Validate document against compliance rules.
    
    Args:
        document_text: Document text to validate
        rules: List of validation rules
    
    Returns:
        Dictionary with validation results:
        - validation_passed: bool
        - errors: List of error violations
        - warnings: List of warning violations
        - info: List of info messages
        - total_rules_checked: int
        - errors_count: int
        - warnings_count: int
        - info_count: int
        - validation_duration_ms: int
    """
    start_time = time.time()
    
    errors = []
    warnings = []
    info = []
    
    document_text_lower = document_text.lower()
    document_lines = document_text.split('\n')
    
    for rule in rules:
        rule_id = rule.get("id", "unknown")
        rule_name = rule.get("rule_name", "Unknown Rule")
        rule_type = rule.get("rule_type", "unknown")
        severity = rule.get("severity", "error")
        rule_config = rule.get("rule_config", {})
        
        try:
            violation = _check_rule(document_text, document_text_lower, document_lines, rule_type, rule_config)
            
            if violation:
                violation_result = {
                    "rule_id": rule_id,
                    "rule_name": rule_name,
                    "rule_type": rule_type,
                    "severity": severity,
                    "violated": True,
                    "message": violation.get("message", rule_config.get("error_message", "Rule violation")),
                    "details": violation.get("details", {})
                }
                
                if severity == "error":
                    errors.append(violation_result)
                elif severity == "warning":
                    warnings.append(violation_result)
                else:
                    info.append(violation_result)
        except Exception as e:
            logger.error(f"Error checking rule {rule_id}: {e}", exc_info=True)
            # Continue with other rules even if one fails
    
    duration_ms = int((time.time() - start_time) * 1000)
    
    return {
        "validation_passed": len(errors) == 0,
        "errors": errors,
        "warnings": warnings,
        "info": info,
        "total_rules_checked": len(rules),
        "errors_count": len(errors),
        "warnings_count": len(warnings),
        "info_count": len(info),
        "validation_duration_ms": duration_ms
    }


def _check_rule(
    document_text: str,
    document_text_lower: str,
    document_lines: List[str],
    rule_type: str,
    rule_config: Dict[str, Any]
) -> Optional[Dict[str, Any]]:
    """Check a single rule against the document"""
    
    if rule_type == "required_field":
        return _check_required_field(document_text, rule_config)
    elif rule_type == "content_check":
        return _check_content(document_text, document_text_lower, document_lines, rule_config)
    elif rule_type == "format_check":
        return _check_format(document_text, document_text_lower, document_lines, rule_config)
    elif rule_type == "citation_check":
        return _check_citation(document_text, document_text_lower, rule_config)
    elif rule_type == "length_check":
        return _check_length(document_text, rule_config)
    else:
        logger.warning(f"Unknown rule type: {rule_type}")
        return None


def _check_required_field(document_text: str, rule_config: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    """Check if required field exists with pattern match"""
    field_name = rule_config.get("field_name", "")
    pattern = rule_config.get("pattern", "")
    required = rule_config.get("required", True)
    
    if not required:
        return None
    
    if not pattern:
        # Just check if field name appears
        if field_name.lower() in document_text.lower():
            return None
        else:
            return {
                "message": f"Required field '{field_name}' not found",
                "details": {"field_name": field_name, "found": False}
            }
    
    # Check pattern
    matches = re.search(pattern, document_text, re.IGNORECASE | re.MULTILINE)
    if matches:
        return None
    else:
        return {
            "message": rule_config.get("error_message", f"Required field '{field_name}' not found or doesn't match pattern"),
            "details": {"field_name": field_name, "pattern": pattern, "found": False}
        }


def _check_content(
    document_text: str,
    document_text_lower: str,
    document_lines: List[str],
    rule_config: Dict[str, Any]
) -> Optional[Dict[str, Any]]:
    """Check content-based rules"""
    check_type = rule_config.get("check_type", "content_exists")
    
    if check_type == "section_exists":
        return _check_section_exists(document_text, document_text_lower, rule_config)
    elif check_type == "content_exists":
        return _check_content_exists(document_text_lower, rule_config)
    elif check_type == "contains_keywords":
        return _check_keywords(document_text_lower, rule_config)
    elif check_type == "contains_phrase":
        return _check_phrase(document_text_lower, rule_config)
    else:
        logger.warning(f"Unknown content check type: {check_type}")
        return None


def _check_section_exists(
    document_text: str,
    document_text_lower: str,
    rule_config: Dict[str, Any]
) -> Optional[Dict[str, Any]]:
    """Check if a section exists"""
    section_name = rule_config.get("section_name", "")
    keywords = rule_config.get("keywords", [])
    required = rule_config.get("required", True)
    
    if not required:
        return None
    
    # Check if section name appears (as heading)
    section_found = False
    
    # Look for section heading (usually uppercase, on its own line, or followed by colon)
    section_patterns = [
        rf"^{re.escape(section_name)}$",
        rf"^{re.escape(section_name)}:",
        rf"^{re.escape(section_name)}\s*$",
    ]
    
    for pattern in section_patterns:
        if re.search(pattern, document_text, re.IGNORECASE | re.MULTILINE):
            section_found = True
            break
    
    # Also check for keywords
    keywords_found = all(keyword.lower() in document_text_lower for keyword in keywords) if keywords else True
    
    if section_found and keywords_found:
        return None
    else:
        return {
            "message": rule_config.get("error_message", f"Section '{section_name}' not found or missing required keywords"),
            "details": {
                "section_name": section_name,
                "keywords": keywords,
                "section_found": section_found,
                "keywords_found": keywords_found,
                "found": section_found and keywords_found
            }
        }


def _check_content_exists(document_text_lower: str, rule_config: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    """Check if specific content exists"""
    required_content = rule_config.get("required_content", "")
    if not required_content:
        return None
    
    if required_content.lower() in document_text_lower:
        return None
    else:
        return {
            "message": rule_config.get("error_message", "Required content not found"),
            "details": {"required_content": required_content, "found": False}
        }


def _check_keywords(document_text_lower: str, rule_config: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    """Check if keywords exist"""
    keywords = rule_config.get("keywords", [])
    require_all = rule_config.get("require_all", False)
    
    if not keywords:
        return None
    
    if require_all:
        found = all(keyword.lower() in document_text_lower for keyword in keywords)
    else:
        found = any(keyword.lower() in document_text_lower for keyword in keywords)
    
    if found:
        return None
    else:
        return {
            "message": rule_config.get("error_message", "Required keywords not found"),
            "details": {"keywords": keywords, "require_all": require_all, "found": False}
        }


def _check_phrase(document_text_lower: str, rule_config: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    """Check if exact phrase exists"""
    phrase = rule_config.get("phrase", "")
    if not phrase:
        return None
    
    if phrase.lower() in document_text_lower:
        return None
    else:
        return {
            "message": rule_config.get("error_message", "Required phrase not found"),
            "details": {"phrase": phrase, "found": False}
        }


def _check_format(
    document_text: str,
    document_text_lower: str,
    document_lines: List[str],
    rule_config: Dict[str, Any]
) -> Optional[Dict[str, Any]]:
    """Check format-based rules"""
    check_type = rule_config.get("check_type", "header_exists")
    
    if check_type == "header_exists":
        # Check if document has header (first few lines contain firm name, address, etc.)
        header_found = len(document_lines) > 0 and len(document_lines[0].strip()) > 0
        if header_found:
            return None
        else:
            return {
                "message": rule_config.get("error_message", "Document header not found"),
                "details": {"found": False}
            }
    else:
        logger.warning(f"Unknown format check type: {check_type}")
        return None


def _check_citation(
    document_text: str,
    document_text_lower: str,
    rule_config: Dict[str, Any]
) -> Optional[Dict[str, Any]]:
    """Check citation-based rules"""
    citation = rule_config.get("citation", "")
    if not citation:
        return None
    
    if citation.lower() in document_text_lower:
        return None
    else:
        return {
            "message": rule_config.get("error_message", f"Required citation '{citation}' not found"),
            "details": {"citation": citation, "found": False}
        }


def _check_length(document_text: str, rule_config: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    """Check length-based rules"""
    word_count = len(document_text.split())
    char_count = len(document_text)
    
    min_words = rule_config.get("min_words")
    max_words = rule_config.get("max_words")
    min_chars = rule_config.get("min_characters")
    max_chars = rule_config.get("max_characters")
    
    violations = []
    
    if min_words and word_count < min_words:
        violations.append(f"Document has {word_count} words, minimum is {min_words}")
    if max_words and word_count > max_words:
        violations.append(f"Document has {word_count} words, maximum is {max_words}")
    if min_chars and char_count < min_chars:
        violations.append(f"Document has {char_count} characters, minimum is {min_chars}")
    if max_chars and char_count > max_chars:
        violations.append(f"Document has {char_count} characters, maximum is {max_chars}")
    
    if violations:
        return {
            "message": rule_config.get("error_message", "; ".join(violations)),
            "details": {
                "word_count": word_count,
                "character_count": char_count,
                "min_words": min_words,
                "max_words": max_words,
                "min_chars": min_chars,
                "max_chars": max_chars
            }
        }
    
    return None

