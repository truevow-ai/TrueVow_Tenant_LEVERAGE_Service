"""
Generate placeholder template files for all US states

This script creates empty template JSON files for states that don't have
templates yet. These can be populated later with state-specific rules.
"""

import json
from pathlib import Path

# All US states + DC
ALL_STATES = [
    "alabama", "alaska", "arizona", "arkansas", "california", "colorado",
    "connecticut", "delaware", "florida", "georgia", "hawaii", "idaho",
    "illinois", "indiana", "iowa", "kansas", "kentucky", "louisiana",
    "maine", "maryland", "massachusetts", "michigan", "minnesota",
    "mississippi", "missouri", "montana", "nebraska", "nevada",
    "new_hampshire", "new_jersey", "new_mexico", "new_york",
    "north_carolina", "north_dakota", "ohio", "oklahoma", "oregon",
    "pennsylvania", "rhode_island", "south_carolina", "south_dakota",
    "tennessee", "texas", "utah", "vermont", "virginia", "washington",
    "west_virginia", "wisconsin", "wyoming", "district_of_columbia"
]

# States already implemented
IMPLEMENTED_STATES = ["arizona", "california", "texas"]

# State name mapping (for display)
STATE_NAMES = {
    "alabama": "Alabama", "alaska": "Alaska", "arizona": "Arizona",
    "arkansas": "Arkansas", "california": "California", "colorado": "Colorado",
    "connecticut": "Connecticut", "delaware": "Delaware", "florida": "Florida",
    "georgia": "Georgia", "hawaii": "Hawaii", "idaho": "Idaho",
    "illinois": "Illinois", "indiana": "Indiana", "iowa": "Iowa",
    "kansas": "Kansas", "kentucky": "Kentucky", "louisiana": "Louisiana",
    "maine": "Maine", "maryland": "Maryland", "massachusetts": "Massachusetts",
    "michigan": "Michigan", "minnesota": "Minnesota", "mississippi": "Mississippi",
    "missouri": "Missouri", "montana": "Montana", "nebraska": "Nebraska",
    "nevada": "Nevada", "new_hampshire": "New Hampshire", "new_jersey": "New Jersey",
    "new_mexico": "New Mexico", "new_york": "New York",
    "north_carolina": "North Carolina", "north_dakota": "North Dakota",
    "ohio": "Ohio", "oklahoma": "Oklahoma", "oregon": "Oregon",
    "pennsylvania": "Pennsylvania", "rhode_island": "Rhode Island",
    "south_carolina": "South Carolina", "south_dakota": "South Dakota",
    "tennessee": "Tennessee", "texas": "Texas", "utah": "Utah",
    "vermont": "Vermont", "virginia": "Virginia", "washington": "Washington",
    "west_virginia": "West Virginia", "wisconsin": "Wisconsin", "wyoming": "Wyoming",
    "district_of_columbia": "District of Columbia"
}


def generate_placeholder_template(state: str) -> dict:
    """
    Generate placeholder template for a state
    
    Args:
        state: State name (lowercase with underscores)
    
    Returns:
        Template dictionary
    """
    state_display = STATE_NAMES[state]
    
    return {
        "state": state,
        "templates": [
            {
                "template_name": f"{state_display} Demand Letter (Personal Injury)",
                "template_description": f"{state_display}-specific demand letter format for personal injury cases. "
                                       f"[TO BE POPULATED: Add {state_display}-specific statute of limitations, "
                                       f"procedural requirements, and Bar compliance rules]",
                "template_category": "demand_letter",
                "state": state,
                "jurisdiction_type": "state",
                "template_source": "truevow",
                "template_version": "1.0",
                "rules": [
                    {
                        "rule_name": f"{state_display} Statute of Limitations Reference",
                        "rule_description": f"[TO BE POPULATED: Research {state_display} statute of limitations for personal injury cases]",
                        "rule_type": "content_check",
                        "rule_config": {
                            "check_type": "section_exists",
                            "section_name": "Statute of Limitations",
                            "required": True,
                            "keywords": ["statute of limitations"],
                            "error_message": f"[TO BE POPULATED: Add {state_display}-specific SOL citation requirement]"
                        },
                        "severity": "error"
                    },
                    {
                        "rule_name": "Total Demand Amount Required",
                        "rule_description": "Demand letter must state a specific total dollar amount",
                        "rule_type": "required_field",
                        "rule_config": {
                            "field_name": "Total Demand Amount",
                            "pattern": "\\$[0-9,]+(\\.\\d{2})?",
                            "required": True,
                            "error_message": "Demand letter must state a specific dollar amount"
                        },
                        "severity": "error"
                    },
                    {
                        "rule_name": "Client Full Name Required",
                        "rule_description": "Demand letter must include client's full legal name",
                        "rule_type": "required_field",
                        "rule_config": {
                            "field_name": "Client Name",
                            "pattern": "[A-Z][a-z]+ [A-Z][a-z]+",
                            "required": True,
                            "error_message": "Demand letter must include client's full name"
                        },
                        "severity": "error"
                    },
                    {
                        "rule_name": "Professional Letterhead Check",
                        "rule_description": f"Professional letterhead required per {state_display} Bar rules",
                        "rule_type": "format_check",
                        "rule_config": {
                            "check_type": "header_exists",
                            "required": True,
                            "error_message": f"[TO BE POPULATED: Add {state_display} Bar letterhead requirements]"
                        },
                        "severity": "warning"
                    }
                ]
            },
            {
                "template_name": f"{state_display} Complaint (State Court)",
                "template_description": f"{state_display} state court complaint format. "
                                       f"[TO BE POPULATED: Add {state_display} Rules of Civil Procedure requirements]",
                "template_category": "complaint",
                "state": state,
                "jurisdiction_type": "state",
                "template_source": "truevow",
                "template_version": "1.0",
                "rules": [
                    {
                        "rule_name": f"Caption Format ({state_display} State Court)",
                        "rule_description": f"Proper court caption format for {state_display} state courts",
                        "rule_type": "format_check",
                        "rule_config": {
                            "check_type": "caption_format",
                            "required_elements": ["STATE", "COUNTY", "COURT"],
                            "error_message": f"[TO BE POPULATED: Add {state_display} caption requirements]"
                        },
                        "severity": "error"
                    },
                    {
                        "rule_name": "Parties Section Required",
                        "rule_description": "Complaint must identify all parties",
                        "rule_type": "content_check",
                        "rule_config": {
                            "check_type": "section_exists",
                            "section_name": "Parties",
                            "required": True,
                            "keywords": ["plaintiff", "defendant"],
                            "error_message": "Complaint must identify all parties"
                        },
                        "severity": "error"
                    },
                    {
                        "rule_name": "Prayer for Relief Required",
                        "rule_description": "Complaint must include prayer for relief",
                        "rule_type": "content_check",
                        "rule_config": {
                            "check_type": "section_exists",
                            "section_name": "Prayer for Relief",
                            "required": True,
                            "keywords": ["prayer", "wherefore", "demands"],
                            "error_message": "Complaint must include prayer for relief"
                        },
                        "severity": "error"
                    }
                ]
            }
        ]
    }


def generate_all_placeholders(output_dir: Path, overwrite: bool = False):
    """
    Generate placeholder templates for all states
    
    Args:
        output_dir: Directory to save templates
        overwrite: If True, overwrite existing files
    """
    created = []
    skipped = []
    
    for state in ALL_STATES:
        # Skip if already implemented (unless overwrite=True)
        if state in IMPLEMENTED_STATES and not overwrite:
            skipped.append(f"{state} (already implemented)")
            continue
        
        # Skip federal templates
        if state == "federal":
            continue
        
        # Check if file exists
        filepath = output_dir / f"{state}_templates.json"
        if filepath.exists() and not overwrite:
            skipped.append(f"{state} (file exists)")
            continue
        
        # Generate placeholder
        template = generate_placeholder_template(state)
        
        # Save to file
        with open(filepath, "w") as f:
            json.dump(template, f, indent=2)
        
        created.append(state)
    
    return created, skipped


if __name__ == "__main__":
    # Get output directory
    output_dir = Path(__file__).parent
    
    print("="*60)
    print("GENERATING PLACEHOLDER STATE TEMPLATES")
    print("="*60)
    print()
    
    # Generate placeholders
    created, skipped = generate_all_placeholders(output_dir, overwrite=False)
    
    # Print results
    print(f"✅ Created {len(created)} placeholder templates:")
    for state in created:
        print(f"   • {STATE_NAMES[state]}")
    
    print()
    print(f"⏭️  Skipped {len(skipped)} files:")
    for item in skipped:
        print(f"   • {item}")
    
    print()
    print("="*60)
    print("DONE!")
    print("="*60)
    print()
    print("Next steps:")
    print("1. Review generated placeholder files")
    print("2. Populate state-specific rules one at a time")
    print("3. Test validation with sample documents")
    print("4. Seed into database using:")
    print("   python -m app.services.draft.templates.seed_templates <state_name>")

