# Item Mapping Guide

This guide explains how to map items from the source site to the target site for migration.

---

## 🎯 The Process

### **Step 1: Discover Templates**
Run `01_DiscoverTemplates.ps1` to get Template IDs you want to migrate.

**Output:** List of Template IDs
```
{GUID-123}
{GUID-456}
{GUID-789}
```

---

### **Step 2: Export Items by Template**
Run `02_ExportItems.ps1` with:
- **Root Item Path**: Where to find source items
  - Example: `/sitecore/content/HartmannDirect/Global/Home`
- **Template IDs**: Copy from Step 1 (comma-separated)
  - Example: `{GUID-123},{GUID-456},{GUID-789}`

---

## 📋 What the Mapper Does

The script:
1. ✅ Finds all items under the root path
2. ✅ Filters by the template IDs you specified
3. ✅ Creates a mapping structure with:
   - **Source columns** (old item details)
   - **Target columns** (for you to fill in)
   - **Status** column (Pending → Ready)

---

## 📊 Mapping Structure

The mapping shows:

| Source | → | Target |
|--------|---|--------|
| Source Item ID | → | Target Item ID |
| Source Item Name | → | Target Item Name |
| Source Item Path | → | Target Item Path |
| Source Template | → | Target Template |
| Source Template ID | → | Target Template ID |
| (auto-filled) | | (you fill these in) |

---

## 🔄 How to Fill In the Mapping

### **1. Note the Source Items**
```
Source Item IDs shown in console:
{ITEM-111}  ← Home
{ITEM-222}  ← Products
{ITEM-333}  ← Categories
```

### **2. Find Target Items**
Navigate to the TARGET location in Sitecore and find matching items:
- Same name or similar structure
- Or items created in the target location

### **3. Fill in Target Columns**
For each source item, enter:
- **Target Item ID**: GUID of the target item
- **Target Item Name**: Name in target location
- **Target Item Path**: Path in target location
- **Target Template**: Template name in target
- **Target Template ID**: Template GUID in target

### **4. Set Status**
Change Status from "Pending" to "Ready" for items you want to migrate

---

## 📝 Example Mapping

```
Source Item ID: {ITEM-111}
Source Name: Home
Source Path: /sitecore/content/HartmannDirect/Global/Home
Source Template: Global Home
Source Template ID: {TEMPLATE-HOME}

↓ (mapping arrow)

Target Item ID: {NEW-ITEM-111}
Target Name: Home
Target Path: /sitecore/content/HartmannDirectGlobal/Home
Target Template: Global Home
Target Template ID: {TEMPLATE-HOME}
Status: Ready
```

---

## 🎨 ListView View

The mapping is shown in a professional ListView:
```
┌─────────────────────────────────────────────────────────┐
│ Source Item ID │ Source Name │ ... │ Target Item ID │...│
├─────────────────────────────────────────────────────────┤
│ {GUID-111}     │ Home        │ ... │ {GUID-AAA}    │...│
│ {GUID-222}     │ Products    │ ... │ {GUID-BBB}    │...│
└─────────────────────────────────────────────────────────┘
```

You can:
- **Copy data** from ListView
- **View all columns** by scrolling
- **Export to Excel** for filling in target details

---

## 💾 Exporting the Mapping

### **To Excel:**
1. In ListView, select all (Ctrl+A)
2. Copy (Ctrl+C)
3. Paste into Excel
4. Fill in the Target columns
5. Save as CSV

### **For Migration:**
Once all target details are filled in:
1. Export mapping as CSV
2. Use with `03_ExecuteMigration.ps1`
3. Script uses mapping to perform the migration

---

## ⚡ Quick Workflow

```
1. Run 01_DiscoverTemplates.ps1
   ↓ Copy Template IDs

2. Run 02_ExportItems.ps1
   ↓ Paste Template IDs + Root Path
   ↓ Get Source Item List

3. Open Sitecore Content Editor
   ↓ Find Target Items
   ↓ Note Target Details

4. Fill in Mapping in Excel
   ↓ Enter Target columns

5. Export Mapping CSV
   ↓ Use in 03_ExecuteMigration.ps1

6. Run Migration
   ↓ Items move from source to target
```

---

## 🆘 Common Issues

| Problem | Solution |
|---------|----------|
| No items found | Check template IDs are correct |
| Wrong items in list | Verify template IDs match your templates |
| Can't find target items | Search in target location in Content Editor |
| Unclear target structure | Document target structure before mapping |

---

## 📌 Tips

- **Start small**: Test with 1-2 items first
- **Keep a backup**: Document original structure
- **Use consistent naming**: Map similar names where possible
- **Verify targets exist**: Ensure target items are created before migration
- **Save mapping**: Keep CSV for audit trail

---

**Ready?** Run `02_ExportItems.ps1` with your Template IDs! 🚀
