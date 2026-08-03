# Sitecore Migration Toolkit - Complete Documentation

## Overview

This documentation covers the Sitecore Tenant to Global content migration process using three integrated components:
1. **Discovery Template Script** - Discover available templates
2. **Export Items Script** - Export items by template with filtering
3. **Excel Mapper** - Map and prepare items for migration

---

# Part 1: Discovery Template Script (01_DiscoverTemplates.ps1)

## Purpose
Discovers and lists all available Sitecore templates with their GUIDs (Template IDs) from specified template folders. This is the first step to identify which templates you want to export items from.

## When to Use
- At the start of migration planning
- To identify template IDs for your region or global instance
- To verify templates exist before creating export scripts

## Features
- **Interactive Dialog Input** - Simple dialog to enter template paths
- **Dual-Path Support** - Can discover both source and target templates in one run
- **GUID Output** - Displays Template IDs needed for next steps
- **Console Output** - Lists all discovered template IDs for easy copy-paste

## How to Use

### Step 1: Open Sitecore PowerShell Console
- Go to Sitecore → PowerShell ISE or Sitecore → PowerShell Console
- Or use Sitecore PowerShell Extensions (SPE)

### Step 2: Run the Script
Copy and paste the entire `01_DiscoverTemplates.ps1` script into the console and click **Run**.

### Step 3: Fill in the Dialog

The script shows an interactive dialog with two fields:

```
┌─ Template Discovery - Enter Paths ─────┐
│                                         │
│ Source Template Path:                   │
│ [/sitecore/templates/Project/...  ]    │
│                                         │
│ Target Template Path (optional):        │
│ [                                   ]   │
│                                         │
│        [Discover]  [Cancel]            │
└─────────────────────────────────────────┘
```

**Field 1: Source Template Path** (Required)
- Enter the root folder path where templates are located
- Examples:
  - `/sitecore/templates/Project/HartmannDirectES`
  - `/sitecore/templates/Project/HartmannDirectES/Pages`
  - `/sitecore/templates`

**Field 2: Target Template Path** (Optional)
- Leave empty to skip
- Or enter another template path (e.g., Global templates)
- Script will scan both if provided

### Step 4: Review Output

The script outputs:
1. **ListView Dialog** - Professional table showing all discovered templates
2. **Console List** - Template IDs listed one per line for copy-paste

### Output Example

```
═══════════════════════════════════════════════════════════════
Template IDs (Copy and use in next steps):
═══════════════════════════════════════════════════════════════

{EA530DF2-DB04-4D08-9B66-F41CE0D9E30B}
{4D0AE5EB-081F-4B14-8625-9DBC587D0C7B}
{C661A2D6-29DB-4116-BD14-290EB2D36052}
{D4DB810B-099D-411C-8D35-FE00E06D8EB3}
... (more IDs)
```

## Information Displayed

For each template discovered:
- **Template Name** - The display name of the template
- **Template ID** - The GUID (unique identifier)
- **Location** - Whether it's in SOURCE or TARGET path
- **Full Path** - Complete path in Sitecore
- **Field Count** - Number of fields in the template

## Best Practices

✅ **Start with a specific path** - `/Project/YourProject` is better than `/templates`
✅ **One discovery per migration** - Run once per source/target pair
✅ **Copy all IDs** - Even if you don't need all of them initially
✅ **Document your templates** - Note which templates you selected
✅ **Test the path first** - Verify the path exists in Sitecore Content Editor

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No templates found | Check path spelling, try parent folder |
| Too many results | Use more specific path (e.g., add `/Pages`) |
| Dialog doesn't appear | Check if running in SPE, not browser console |
| Can't copy output | The IDs are listed in console - scroll up if needed |

## Next Step
→ Use the discovered Template IDs in **Export Items Script (02_ExportItems.ps1)**

---

# Part 2: Export Items Script (02_ExportItems.ps1)

## Purpose
Exports items from a source location that match specific template IDs. Filters by templates and allows excluding items by template ID or name pattern. Produces a clean list of items ready for mapping.

## When to Use
- After discovering templates (Part 1)
- To get a complete inventory of items to migrate
- To apply exclusion rules (skip certain templates or item names)

## Features
- **Template Filtering** - Only export items with specified templates
- **Template Exclusion** - Skip entire template branches (and all children)
- **Name Exclusion** - Skip items matching specific names (exact match)
- **Flexible Input** - Multi-line template ID input (paste as-is from Part 1)
- **Professional Output** - ListView display + console ID list

## How to Use

### Step 1: Open Sitecore PowerShell Console
Same as Part 1 - Sitecore PowerShell Extensions

### Step 2: Run the Script
Copy and paste `02_ExportItems.ps1` into the console and click **Run**.

### Step 3: Fill in the Dialog

```
┌─ Item Export - Filter by Templates ────┐
│                                         │
│ Root Item Path (e.g. /sitecore/...):   │
│ [/sitecore/content/HartmannDirect/ES/Home]
│                                         │
│ Template IDs to INCLUDE:                │
│ ┌─────────────────────────────────────┐ │
│ │{EA530DF2-DB04-4D08-9B66-F41CE0D9E30B}
│ │{4D0AE5EB-081F-4B14-8625-9DBC587D0C7B}
│ │... (paste all IDs)                  │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Template IDs to EXCLUDE + children:     │
│ ┌─────────────────────────────────────┐ │
│ │{8C58B2C2-DF3E-4802-9AE8-9A425A0EC544}
│ └─────────────────────────────────────┘ │
│                                         │
│ Item Names to EXCLUDE (exact match):    │
│ ┌─────────────────────────────────────┐ │
│ │*                                    │ │
│ └─────────────────────────────────────┘ │
│                                         │
│         [Export]  [Cancel]             │
└─────────────────────────────────────────┘
```

### Field 1: Root Item Path (Required)
- Starting location to scan for items
- Examples:
  - `/sitecore/content/HartmannDirect/ES/Home` (tenant specific)
  - `/sitecore/content/HartmannDirect/Global/Home` (global)
  - `/sitecore/content` (all content)

### Field 2: Template IDs to INCLUDE (Required)
- Paste Template IDs from Part 1
- One per line (as output from Discovery script)
- Only items with these templates will be exported
- Example:
  ```
  {EA530DF2-DB04-4D08-9B66-F41CE0D9E30B}
  {4D0AE5EB-081F-4B14-8625-9DBC587D0C7B}
  {C661A2D6-29DB-4116-BD14-290EB2D36052}
  ```

### Field 3: Template IDs to EXCLUDE + children (Optional)
- Exclude items with this template AND all their children
- Default: `{8C58B2C2-DF3E-4802-9AE8-9A425A0EC544}` (common folder to skip)
- Leave blank if you don't want exclusions
- Use for skipping entire subtrees

### Field 4: Item Names to EXCLUDE (Optional)
- Exclude items with exact matching name
- One per line
- Default: `*` (excludes items literally named "*")
- Examples:
  - `*` (skip asterisk-named items)
  - `__Standard Values` (skip standard values)
  - `__Renderings` (skip rendering assignments)

### Step 4: Review Output

The script displays:
1. **ListView** - Professional table of all matching items
2. **Console List** - Item IDs one per line for reference

### Output Example

```
Item ID,Item Name,Item Path,Template,Template ID,Children,Versions,Fields
{877ED844-30E5-4D7B-B7BF-D9222BB9F20F},Products,/sitecore/.../Products,HD Product Main,{7729CF78},1,1,45
{54389452-891C-48CA-8202-140B254D25D4},Incontinence,/sitecore/.../Incontinence,HD Product Category,{EEC15AE4},1,1,32
... (more items)
```

## Information Displayed

For each item exported:
- **Item ID** - The GUID (unique identifier)
- **Item Name** - Display name in Sitecore
- **Item Path** - Full path in content tree
- **Template** - Template name
- **Template ID** - Template GUID
- **Children** - Count of child items
- **Versions** - Number of versions
- **Fields** - Number of fields in the item

## Filtering Logic

Items are included if:
1. ✅ Template ID matches one in "INCLUDE" list
2. ✅ NOT excluded by template ID
3. ✅ NOT children of excluded items
4. ✅ Item name is NOT in exclusion list

## Best Practices

✅ **Start with narrow scope** - Begin with a specific node
✅ **Review the count** - Verify item count is expected
✅ **Use exclusions wisely** - Exclude system items (like `*`, `__*`)
✅ **Default exclusion works** - The default `{8C58B2C2...}` skips common folder
✅ **Copy the output** - Save the ListView to Excel for next step

## Troubleshooting

| Issue | Solution |
|-------|----------|
| 0 items found | Check root path exists, verify template IDs |
| Too many items | Use more specific templates or root path |
| Wrong items included | Verify template IDs are correct |
| Items not filtering | Check exclusion template ID spelling |

## Next Step
→ Use the exported items list in **Excel Mapper (Part 3)**

---

# Part 3: Excel Mapper Template

## Purpose
A 3-sheet Excel workbook that maps Region Page items to Global Page items, automatically calculating migration paths and item IDs. This is where business logic drives the mapping.

## When to Use
- After exporting both Region and Global items (Parts 1-2)
- To prepare for actual migration execution
- To plan which items go where (local vs. global)

## Structure

### Sheet 1: Global Page
**Purpose:** Reference data for global items
**Columns:** Item ID | Item Name | Item Path | Template | Template ID | Children | Versions | Fields
**How to populate:** Paste data from export of global items

### Sheet 2: Region Page
**Purpose:** Reference data for region items
**Columns:** Item ID | Item Name | Item Path | Template | Template ID | Children | Versions | Fields
**How to populate:** Paste data from export of region items

### Sheet 3: Mapper
**Purpose:** The mapping sheet where formulas do the work
**Columns:**

| Col | Name | Type | Input | Formula | Output |
|-----|------|------|-------|---------|--------|
| A | **Region Page** | Input | User enters region path | — | Source path |
| B | **Global Page** | Input | User enters global path | — | Target path |
| C | **Move to Local Folder** | Input | User enters "L" or blank | — | Local flag |
| D | **New Path** | Auto | — | `=IF(C="L", B&"/L", B)` | Final path |
| E | **New Path ID** | Auto | — | INDEX/MATCH lookup | Target Item ID |
| F | **Old Path ID** | Auto | — | INDEX/MATCH lookup | Source Item ID |

## How to Use

### Step 1: Open the Excel Template
File: `Mapping-Template.xlsx`
Location: `SitecoreMigration/Templates/`

### Step 2: Populate Sheet 1 (Global Page)
1. Export global items using Part 2 script
2. Copy columns: Item ID, Item Name, Item Path, Template, Template ID, Children, Versions, Fields
3. Paste into Sheet 1, starting at row 2

### Step 3: Populate Sheet 2 (Region Page)
1. Export region items using Part 2 script
2. Copy the same columns
3. Paste into Sheet 2, starting at row 2

### Step 4: Create Mappings in Sheet 3

For each item you want to migrate:

**Column A: Region Page** (You enter)
- Find the region item in Sheet 2
- Copy its Item Path
- Example: `/sitecore/content/HartmannDirect/ES/Home/Blog/Incontinencia/Mujeres`

**Column B: Global Page** (You enter)
- Find the matching global item in Sheet 1
- Copy its Item Path
- Should be the same logical item, but in global structure
- Example: `/sitecore/content/HartmannDirect/Global/Home/Knowledge/Incontinence/Women`

**Column C: Move to Local Folder** (You decide)
- `L` = This item will be moved to a local folder
- Leave blank = Keep in global
- Determines where item ends up
- Example: `L` for region-specific content, blank for shared content

### Step 5: Formulas Auto-Calculate

Once you fill columns A-C, columns D-F auto-calculate:

**Column D: New Path** (Automatic)
- Formula: `=IF(C="L", B&"/L", B)`
- If Move to Local = "L" → Appends "/L" to the Global Page path
- Otherwise → Uses Global Page path as-is
- Example outcomes:
  - If C="L": `/sitecore/.../Global/Home/Knowledge/Incontinence/Women/L`
  - If C="": `/sitecore/.../Global/Home/Knowledge/Incontinence/Women`

**Column E: New Path ID** (Automatic)
- Formula: INDEX/MATCH lookup
- Finds the New Path in Global Page sheet
- Returns the matching Item ID
- Example: Looks up the full path and returns `{B1EEA98D-7FB6-49CC-82E5-14A3FAF7472A}`

**Column F: Old Path ID** (Automatic)
- Formula: INDEX/MATCH lookup
- Finds the Region Page path in Region Page sheet
- Returns the matching Item ID
- Example: Returns `{D2183A81-5BB5-400C-8B21-727DF1103315}`

## Complete Example

**Input (User enters):**
```
A2: /sitecore/content/HartmannDirect/ES/Home/Blog/Incontinencia/Mujeres
B2: /sitecore/content/HartmannDirect/Global/Home/Knowledge/Incontinence/Women
C2: L
```

**Output (Formulas calculate):**
```
D2: /sitecore/content/HartmannDirect/Global/Home/Knowledge/Incontinence/Women/L
E2: {B1EEA98D-7FB6-49CC-82E5-14A3FAF7472A}  (from Global Page sheet)
F2: {D2183A81-5BB5-400C-8B21-727DF1103315}  (from Region Page sheet)
```

## Features

✅ **Smart Path Calculation** - Appends "/L" only when needed
✅ **Automatic ID Lookup** - Finds correct IDs from reference sheets
✅ **Error Handling** - Shows blank if no match found (safe)
✅ **Pre-populated Formulas** - Rows 2-200 ready to fill
✅ **Sample Data** - Example rows show expected format

## Best Practices

✅ **Match carefully** - Global path should be logically equivalent to region path
✅ **Use full paths** - Copy exact paths from Item Path column
✅ **Plan local items** - Decide in advance which items are local vs. global
✅ **Verify before using** - Check formulas found the correct IDs
✅ **Save after mapping** - Keep the completed mapping for audit trail

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Column E shows blank | Path in D doesn't exist in Global Page sheet |
| Column F shows blank | Path in A doesn't exist in Region Page sheet |
| Wrong ID found | Check that Item Path is exact match (case-sensitive in some cases) |
| Formula error | Ensure sheet names are exactly "Global Page" and "Region Page" |

---

# Complete Migration Workflow

## Overview
Three scripts + one Excel = complete migration preparation

```
Step 1: Discover Templates
  ↓ (get Template IDs)
  
Step 2: Export Items (Global)
  ↓ (populate Excel Sheet 1)
  
Step 3: Export Items (Region)
  ↓ (populate Excel Sheet 2)
  
Step 4: Map Items in Excel
  ↓ (prepare migration data)
  
Step 5: Use Mapping for Migration
  → 03_ExecuteMigration.ps1 (future step)
```

## Migration Checklist

- [ ] Run 01_DiscoverTemplates for source templates
- [ ] Run 01_DiscoverTemplates for target templates (optional but recommended)
- [ ] Run 02_ExportItems for Global items
- [ ] Run 02_ExportItems for Region items
- [ ] Open Mapping-Template.xlsx
- [ ] Populate Sheet 1 (Global Page export)
- [ ] Populate Sheet 2 (Region Page export)
- [ ] Create mappings in Sheet 3 (Column A & B)
- [ ] Verify formulas calculated correctly (Columns D, E, F)
- [ ] Save completed mapping file
- [ ] Ready for 03_ExecuteMigration.ps1

## Key Concepts

**Template ID (GUID)**
- Unique identifier for a template
- Example: `{EA530DF2-DB04-4D08-9B66-F41CE0D9E30B}`
- Used to filter which items to export

**Item ID (GUID)**
- Unique identifier for an item
- Used in migration to reference source and target items
- Looked up based on Item Path

**Item Path**
- Full path in Sitecore tree
- Example: `/sitecore/content/HartmannDirect/ES/Home/Blog/Incontinencia`
- User enters in mapping to define the relationship

**Local Folder ("L")**
- Items can be overridden locally
- Appends "/L" to path when marked
- Only for region-specific content

---

# Tips & Tricks

## Discovery
- Start with specific project folder, not `/templates`
- Discover both source and target in one run (optional)
- Copy all discovered IDs even if you don't need them

## Export
- Use "Move to Local Folder" exclusion to skip system folders
- Default exclusion `{8C58B2C2-DF3E-4802-9AE8-9A425A0EC544}` is safe
- Test with small scope first, then expand

## Mapping
- Match paths carefully - Global path should align with region path logically
- Use full Item Path from export, not just Item Name
- Don't modify formula columns - they auto-calculate
- Keep completed mapping as audit trail

---

# Support

For issues or questions:
1. Check Troubleshooting sections in each part
2. Verify paths match between sheets
3. Ensure Template IDs are correct
4. Check Item Path spelling (exact match required)

---

**Document Version:** 1.0
**Last Updated:** 2026-08-03
**Applicable to:** Sitecore Migration Toolkit v1.0
