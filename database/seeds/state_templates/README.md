# State-Specific Validation Rule Templates

This directory contains validation rule templates for all US states and federal courts.

## Template Status

### ✅ **Fully Implemented** (4)
- **Arizona** - 3 templates, 24 rules
- **California** - 3 templates, 24 rules
- **Texas** - 3 templates, 23 rules
- **Federal** - 4 templates, 31 rules

### 🔲 **Ready for Implementation** (47 + DC)

The following states have placeholder files ready to be populated:

**Alabama** - `alabama_templates.json`  
**Alaska** - `alaska_templates.json`  
**Arkansas** - `arkansas_templates.json`  
**Colorado** - `colorado_templates.json`  
**Connecticut** - `connecticut_templates.json`  
**Delaware** - `delaware_templates.json`  
**Florida** - `florida_templates.json`  
**Georgia** - `georgia_templates.json`  
**Hawaii** - `hawaii_templates.json`  
**Idaho** - `idaho_templates.json`  
**Illinois** - `illinois_templates.json`  
**Indiana** - `indiana_templates.json`  
**Iowa** - `iowa_templates.json`  
**Kansas** - `kansas_templates.json`  
**Kentucky** - `kentucky_templates.json`  
**Louisiana** - `louisiana_templates.json`  
**Maine** - `maine_templates.json`  
**Maryland** - `maryland_templates.json`  
**Massachusetts** - `massachusetts_templates.json`  
**Michigan** - `michigan_templates.json`  
**Minnesota** - `minnesota_templates.json`  
**Mississippi** - `mississippi_templates.json`  
**Missouri** - `missouri_templates.json`  
**Montana** - `montana_templates.json`  
**Nebraska** - `nebraska_templates.json`  
**Nevada** - `nevada_templates.json`  
**New Hampshire** - `new_hampshire_templates.json`  
**New Jersey** - `new_jersey_templates.json`  
**New Mexico** - `new_mexico_templates.json`  
**New York** - `new_york_templates.json`  
**North Carolina** - `north_carolina_templates.json`  
**North Dakota** - `north_dakota_templates.json`  
**Ohio** - `ohio_templates.json`  
**Oklahoma** - `oklahoma_templates.json`  
**Oregon** - `oregon_templates.json`  
**Pennsylvania** - `pennsylvania_templates.json`  
**Rhode Island** - `rhode_island_templates.json`  
**South Carolina** - `south_carolina_templates.json`  
**South Dakota** - `south_dakota_templates.json`  
**Tennessee** - `tennessee_templates.json`  
**Utah** - `utah_templates.json`  
**Vermont** - `vermont_templates.json`  
**Virginia** - `virginia_templates.json`  
**Washington** - `washington_templates.json`  
**West Virginia** - `west_virginia_templates.json`  
**Wisconsin** - `wisconsin_templates.json`  
**Wyoming** - `wyoming_templates.json`  
**District of Columbia** - `district_of_columbia_templates.json`  

---

## Template Structure

Each state template follows this structure:

```json
{
  "state": "state_name",
  "templates": [
    {
      "template_name": "State Demand Letter (Personal Injury)",
      "template_description": "Description with state-specific requirements",
      "template_category": "demand_letter",
      "state": "state_name",
      "jurisdiction_type": "state",
      "template_source": "truevow",
      "template_version": "1.0",
      "rules": [
        {
          "rule_name": "Rule Name",
          "rule_description": "Rule description",
          "rule_type": "required_field",
          "rule_config": {
            "field_name": "Field Name",
            "pattern": "regex_pattern",
            "required": true,
            "error_message": "Error message"
          },
          "severity": "error"
        }
      ]
    }
  ]
}
```

---

## Common Document Types

Each state should include templates for:

1. **Demand Letter (Personal Injury)** - Pre-litigation settlement demands
2. **Complaint/Petition** - Initial court filing
3. **Motion** - Common motions (Motion to Compel, Motion to Dismiss, etc.)
4. **Discovery** - Discovery requests and responses (optional)
5. **Settlement Agreement** - Settlement documents (optional)

---

## State-Specific Requirements

Each state has unique requirements for:

- **Statute of Limitations** - Different time limits and statutes
- **Court Caption Format** - Different court naming conventions
- **Procedural Rules** - Different civil procedure rules
- **Bar Requirements** - Different attorney identification requirements
- **Jurisdictional Requirements** - Different venue and jurisdiction rules

---

## How to Populate a New State

1. Research state-specific requirements:
   - Review state Rules of Civil Procedure
   - Check state Bar association guidelines
   - Review local court rules
   - Consult with local attorneys

2. Create templates for common document types:
   - Start with Demand Letter (most common)
   - Add Complaint/Petition
   - Add common motions

3. Define validation rules:
   - Required fields (client name, dates, amounts)
   - Content checks (required sections, citations)
   - Format checks (caption format, headers)
   - State-specific citations (statutes, case law)

4. Test templates:
   - Test with sample documents
   - Verify rules catch common errors
   - Adjust severity levels (error vs. warning)

5. Seed into database:
   ```bash
   python -m app.services.draft.templates.seed_templates state_name
   ```

---

## Priority States for Implementation

Based on attorney population and TrueVow customer base:

**High Priority:**
1. ✅ California (already implemented)
2. ✅ Texas (already implemented)
3. Florida
4. New York
5. Pennsylvania
6. Illinois
7. Ohio
8. Michigan
9. Georgia
10. North Carolina

**Medium Priority:**
11. New Jersey
12. Virginia
13. Washington
14. Massachusetts
15. Maryland
16. ✅ Arizona (already implemented)
17. Tennessee
18. Indiana
19. Missouri
20. Wisconsin

**Lower Priority:**
- Remaining 27 states
- District of Columbia

---

## Seeding Instructions

### Seed Single State
```bash
python -m app.services.draft.templates.seed_templates arizona
```

### Seed All Implemented States
```bash
python -m app.services.draft.templates.seed_templates
```

### Verify Seeding
```python
from app.services.draft.templates.seed_templates import TemplateSeed

async with get_draft_db_session() as db:
    seeder = TemplateSeed()
    results = await seeder.verify_templates(db)
    print(results)
```

---

## Contributing

To add a new state template:

1. Copy an existing template file (e.g., `arizona_templates.json`)
2. Rename to `{state_name}_templates.json`
3. Update state-specific information
4. Research and add state-specific rules
5. Test validation with sample documents
6. Submit for review

---

## Support

Questions about state-specific requirements?
- Check state Bar association websites
- Review state Rules of Civil Procedure
- Consult with local attorneys
- Contact TrueVow compliance team

