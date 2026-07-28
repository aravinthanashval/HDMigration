# Mapping Guide: Region Page to Global Page

This guide explains how to create the mapping between Region Pages and Global Pages.

---

## 📊 Mapping Structure

| Column | Source | Description | Example |
|--------|--------|-------------|---------|
| **Region Page** | Region Export | URL/Path of item in region | `/Products/Incontinence` |
| **Region Page ID** | Region Export | Item ID from Region export | `{877ED844-30E5-4D7B-B7BF-D9222BB9F20F}` |
| **Global Page** | ES_Global.xlsx | URL/Path of matching item in global | `/Global/Products/Incontinence` |
| **Global Page ID** | ES_Global.xlsx | Item ID from Global export | `{54389452-891C-48CA-8202-140B254D25D4}` |
| **Move to Local Folder** | Manual | "L" if item moves to local, blank if stays global | `L` or `` |
| **New Path** | Formula | New destination path (Global or Local) | `/Global/Products/Incontinence` or `/Local/Products/Incontinence` |
| **Old Path ID** | Lookup | Region Page Item ID (from Region export data) | `{877ED844-30E5-4D7B-B7BF-D9222BB9F20F}` |
| **New Path ID** | Lookup | Global Page Item ID (from ES_Global.xlsx) | `{54389452-891C-48CA-8202-140B254D25D4}` |

---

## 📝 How to Fill In Each Column

### **1. Region Page** (Manual - from Region export)
- Copy the Item Path from your Region Page export
- Example: `/sitecore/content/HartmannDirect/ES/Home/Products/Incontinence`

### **2. Region Page ID** (Lookup - from Region export)
- Find matching item in Region export
- Copy the Item ID GUID
- Example: `{877ED844-30E5-4D7B-B7BF-D9222BB9F20F}`

### **3. Global Page** (Lookup - from ES_Global.xlsx)
- Find matching item in Global Page export
- Same name/structure as Region Page
- Copy the Item Path
- Example: `/sitecore/content/HartmannDirect/Global/Home/Products/Incontinence`

### **4. Global Page ID** (Lookup - from ES_Global.xlsx)
- Find matching Global Page item
- Copy the Item ID GUID
- Example: `{54389452-891C-48CA-8202-140B254D25D4}`

### **5. Move to Local Folder** (Manual Decision)
- "L" = Item will move to local folder
- Blank = Item stays in global folder
- Decision based on:
  - Is it region-specific content?
  - Should it be overridden locally?
  - Example: "L" for local overrides, blank for shared global

### **6. New Path** (Formula/Concatenation)
- IF Move to Local = "L" THEN `/Local/[path]` ELSE Global Page path
- Examples:
  - Moving to local: `/sitecore/content/HartmannDirect/Local/Products/Incontinence`
  - Staying global: `/sitecore/content/HartmannDirect/Global/Home/Products/Incontinence`

### **7. Old Path ID** (Lookup - Region Page ID)
- Same as "Region Page ID" column
- The Item ID being migrated FROM
- Used for tracking source
- Example: `{877ED844-30E5-4D7B-B7BF-D9222BB9F20F}`

### **8. New Path ID** (Lookup - Global Page ID)
- Same as "Global Page ID" column
- The Item ID being migrated TO
- Used for mapping in migration script
- Example: `{54389452-891C-48CA-8202-140B254D25D4}`

---

## 🔄 Step-by-Step Workflow

### **Step 1: Export Region Pages**
```
Run 02_ExportItems.ps1
- Root Path: /sitecore/content/HartmannDirect/ES/Home
- Template IDs: [your region templates]
- Exclude: [same as before]
```
Result: `ES_Region.xlsx` with all region items

### **Step 2: Have Both Exports Ready**
- `ES_Region.xlsx` (Region Page items)
- `ES_Global.xlsx` (Global Page items) ← Already have this

### **Step 3: Create Mapping**
Open Excel and create columns:
```
| Region Page | Region Page ID | Global Page | Global Page ID | Move to Local | New Path | Old Path ID | New Path ID |
|-------------|---|---|---|---|---|---|---|
| /Products/Incontinence | {877...} | /Global/Products/Incontinence | {543...} | | /Global/Products/Incontinence | {877...} | {543...} |
| /Products/Incontinence-Pads | {BA4...} | /Global/Products/Incontinence-Pads | {0112...} | L | /Local/Products/Incontinence-Pads | {BA4...} | {0112...} |
```

### **Step 4: Fill In Mappings**
For each Region item:
1. Find matching Global item (usually same name/structure)
2. Copy IDs from both exports
3. Decide: Local ("L") or Global (blank)
4. Formulas auto-fill New Path & IDs

### **Step 5: Use for Migration**
- Export mapping as CSV
- Use in `03_ExecuteMigration.ps1`
- Script uses Old Path ID → New Path ID mapping

---

## 📐 Excel Formula Examples

### **New Path (Column F)**
```excel
=IF(E2="L", 
    SUBSTITUTE(D2, "/Global/", "/Local/"),
    D2)
```
If Move to Local = "L", replace /Global/ with /Local/, else keep Global path

### **Old Path ID (Column G)**
```excel
=C2
```
Just reference the Region Page ID column

### **New Path ID (Column H)**
```excel
=D2
```
Just reference the Global Page ID column

---

## 🎯 Key Rules

✅ **Region Page = Item from Region export**
✅ **Global Page = Item from Global export** (usually same name)
✅ **Move to Local = "L" or blank (decide per item)**
✅ **New Path = Depends on Move to Local decision**
✅ **Old Path ID = Region Page ID (where it comes from)**
✅ **New Path ID = Global Page ID (where it goes to)**

---

## 💡 Real Example

```
Region Item: Products/Incontinence/Female-Incontinence
Global Item: Global/Products/Incontinence/Female-Incontinence

Mapping Row:
Region Page: /Products/Incontinence/Female-Incontinence
Region Page ID: {92A9D3F0-9EFC-42F9-A896-8B65A8ED5309}
Global Page: /Global/Products/Incontinence/Female-Incontinence
Global Page ID: {A38B2E2D-7D22-4C89-8996-995B43504D5B}
Move to Local: L (yes, localize this)
New Path: /Local/Products/Incontinence/Female-Incontinence
Old Path ID: {92A9D3F0-9EFC-42F9-A896-8B65A8ED5309}
New Path ID: {A38B2E2D-7D22-4C89-8996-995B43504D5B}
```

---

## 🆘 Troubleshooting

| Issue | Solution |
|-------|----------|
| Can't find Global match | Check naming, path structure, template type |
| IDs don't align | Verify you copied from correct export files |
| New Path formula broken | Check IF syntax, column references |
| Multiple Global matches | Choose closest match, note in comments |

---

**Ready?** Export Region Pages, then create this mapping! 📊
