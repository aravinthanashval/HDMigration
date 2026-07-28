# Mapping Guide: Region to Global Migration

Create mapping in a single Excel sheet with all data together.

---

## 📊 Mapping Excel Structure

### **Region Section (Source Data)**
| Column | Source | Description | Example |
|--------|--------|-------------|---------|
| Region Page ID | Region export | Item ID from region | `{877ED844-30E5-4D7B-B7BF-D9222BB9F20F}` |
| Region Page Name | Region export | Item name from region | `Products` |
| Region Page Path | Region export | Item path from region | `/sitecore/content/HartmannDirect/ES/Home/Products` |
| Region Template | Region export | Template name | `HD Product Main Listing Page` |
| Region Template ID | Region export | Template ID | `{7729CF78-C90F-4BDC-AB7D-2FBC9CCC4E96}` |

### **Global Section (Target Data)**
| Column | Source | Description | Example |
|--------|--------|-------------|---------|
| Global Page ID | ES_Global.xlsx | Item ID from global | `{54389452-891C-48CA-8202-140B254D25D4}` |
| Global Page Name | ES_Global.xlsx | Item name from global | `Products` |
| Global Page Path | ES_Global.xlsx | Item path from global | `/sitecore/content/HartmannDirect/Global/Home/Products` |
| Global Template | ES_Global.xlsx | Template name | `HD Product Main Listing Page` |
| Global Template ID | ES_Global.xlsx | Template ID | `{7729CF78-C90F-4BDC-AB7D-2FBC9CCC4E96}` |

### **Mapping Section (Decision & Output)**
| Column | Type | Description | Example |
|--------|------|-------------|---------|
| Move to Local | Manual | "L" = local, blank = global | `L` or `` |
| New Path | Formula | Final destination path | `/sitecore/content/HartmannDirect/Local/Products` |
| Old Path ID | Reference | = Region Page ID column | `{877ED844-30E5-4D7B-B7BF-D9222BB9F20F}` |
| New Path ID | Reference | = Global Page ID column | `{54389452-891C-48CA-8202-140B254D25D4}` |

---

## 🔧 How to Build This

### **Step 1: Create Base Excel Sheet**
Create columns in order:
```
Region Page ID | Region Page Name | Region Page Path | Region Template | Region Template ID |
Global Page ID | Global Page Name | Global Page Path | Global Template | Global Template ID |
Move to Local | New Path | Old Path ID | New Path ID
```

### **Step 2: Paste Region Data**
1. Run `02_ExportItems.ps1` for Region
   - Root: `/sitecore/content/HartmannDirect/ES/Home`
   - Get ES_Region.xlsx

2. Copy columns from ES_Region.xlsx:
   - Item ID → Region Page ID
   - Item Name → Region Page Name
   - Item Path → Region Page Path
   - Template → Region Template
   - Template ID → Region Template ID

### **Step 3: Paste Global Data**
1. Use ES_Global.xlsx (already have)

2. Copy columns from ES_Global.xlsx:
   - Item ID → Global Page ID
   - Item Name → Global Page Name
   - Item Path → Global Page Path
   - Template → Global Template
   - Template ID → Global Template ID

3. **Match by name/path** - Global items should be in same row as Region items with matching names

### **Step 4: Add Mapping Columns**
Add three new columns on the right:
- Move to Local
- New Path
- Old Path ID
- New Path ID

### **Step 5: Fill Formulas**

**Move to Local (Column M)** - Manual decision
```
L = item moves to local folder
blank = item stays in global
```

**New Path (Column N)** - Formula
```excel
=IF(M2="L",
    SUBSTITUTE(D2, "/ES/", "/Local/"),
    D2)
```
If Move to Local="L", replace /ES/ with /Local/, else keep region path

**Old Path ID (Column O)** - Reference
```excel
=A2
```
Just point to Region Page ID column

**New Path ID (Column P)** - Reference
```excel
=F2
```
Just point to Global Page ID column

---

## 📝 Real Example

```
Row 2:
Region Page ID:     {877ED844-30E5-4D7B-B7BF-D9222BB9F20F}
Region Page Name:   Products
Region Page Path:   /sitecore/content/HartmannDirect/ES/Home/Products
Region Template:    HD Product Main Listing Page
Region Template ID: {7729CF78-C90F-4BDC-AB7D-2FBC9CCC4E96}

Global Page ID:     {54389452-891C-48CA-8202-140B254D25D4}
Global Page Name:   Products
Global Page Path:   /sitecore/content/HartmannDirect/Global/Home/Products
Global Template:    HD Product Main Listing Page
Global Template ID: {7729CF78-C90F-4BDC-AB7D-2FBC9CCC4E96}

Move to Local: [blank - stays global]
New Path:      /sitecore/content/HartmannDirect/Global/Home/Products
Old Path ID:   {877ED844-30E5-4D7B-B7BF-D9222BB9F20F}
New Path ID:   {54389452-891C-48CA-8202-140B254D25D4}
```

---

## 🎯 Key Rules

✅ **Old Path ID** = Always = Region Page ID (column A)
✅ **New Path ID** = Always = Global Page ID (column F)
✅ **Move to Local** = Manual decision per row
✅ **New Path** = Depends on Move to Local decision

---

## ✨ Why This Works

- **All data in one place** - Easy to review
- **IDs directly from columns** - No lookup errors
- **Simple formulas** - Just references
- **Clear mapping** - Region → Global → Local

---

## 🚀 Step-by-Step Process

1. Create blank Excel with column headers
2. Export Region Pages → Copy to Region columns
3. Copy Global data from ES_Global.xlsx → Global columns
4. Match rows by item name
5. Add Move to Local decision ("L" or blank)
6. Add formulas for New Path, Old Path ID, New Path ID
7. Save as CSV
8. Use in `03_ExecuteMigration.ps1`

---

**Done!** One mapping file with everything you need! 📊
