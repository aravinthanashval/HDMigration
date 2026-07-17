# Sitecore Paths Reference Guide

Use this guide when the scripts ask you for template and item paths.

---

## 🔍 Common Sitecore Path Formats

### Template Paths
```
/sitecore/templates/                           (all templates)
/sitecore/templates/Project/                   (all project templates)
/sitecore/templates/Project/HartmannDirectES/  (specific project)
/sitecore/templates/Project/HartmannDirectES/Pages
/sitecore/templates/Project/HartmannDirectES/Components
/sitecore/templates/User Defined/              (custom templates)
```

### Content/Item Paths
```
/sitecore/content/                             (all content)
/sitecore/content/Tenant/                      (all tenant content)
/sitecore/content/Tenant/Node1/
/sitecore/content/Tenant/HartmannDirectES/
/Global/                                       (global content)
/Global/Home
/Global/Products
```

---

## 📋 Hartmann-Specific Paths

### For Templates Discovery
**Step 1 - Source Templates:**
```
/sitecore/templates/Project/HartmannDirectES
```

**Step 1 - Target Templates (Optional):**
```
/sitecore/templates/Project/HartmannDirectGlobal
or
/sitecore/templates/Project/Global
```

### For Item Export
**Step 2 - Source Items:**
```
/Tenant/HartmannDirectES
or
/Tenant/HartmannDirectES/Home
or
/Tenant  (if migrating entire tenant)
```

---

## 📌 Path Structure Explanation

Sitecore paths follow this pattern:
```
/sitecore/                      - Root
  ├─ templates/                 - Where template definitions live
  ├─ content/                   - Where actual content items live
  └─ media library/
```

### Templates vs Content
- **Templates** = Definition of what fields an item has
  - Located under: `/sitecore/templates/`
  - Example: `/sitecore/templates/Project/HartmannDirectES/Pages/ES Home`

- **Content** = Actual items using those templates
  - Located under: `/sitecore/content/` or similar
  - Example: `/Tenant/HartmannDirectES/Home`

---

## 🔗 How to Find Paths

### In Sitecore Admin UI:
1. Go to **Sitecore → Content Editor**
2. Look at the breadcrumb at the top or the item path
3. Example: `sitecore > content > Tenant > Node1 > Home`
4. Path to use: `/Tenant/Node1/Home`

### In Content Tree:
1. Open **Content Editor**
2. Expand folders and right-click on an item
3. Look for "Path" or copy the URL

---

## ✅ Path Validation Tips

Before running scripts, verify:

| Scenario | Example Path | Notes |
|----------|--------------|-------|
| Template root | `/sitecore/templates/Project/HartmannDirectES` | Should exist in Sitecore |
| Tenant items | `/Tenant/HartmannDirectES` | Must be your actual tenant structure |
| Global target | `/Global` or `/Global/Content` | Create if doesn't exist |
| Specific node | `/Tenant/Node1/Home` | Include full path to item |

---

## 🚀 Quick Path Lookup

**I need to find my:**

### 1. Source Template Path
1. Content Editor → `/sitecore/templates/`
2. Find your project folder (e.g., `HartmannDirectES`)
3. Example: `/sitecore/templates/Project/HartmannDirectES`

### 2. Target Template Path
1. Content Editor → `/sitecore/templates/`
2. Find your global folder (e.g., `HartmannDirectGlobal`)
3. Example: `/sitecore/templates/Project/HartmannDirectGlobal`

### 3. Source Item Path
1. Content Editor → `/sitecore/content/`
2. Find your tenant (usually `/Tenant/` or similar)
3. Example: `/Tenant/HartmannDirectES` or `/Tenant/Node1`

### 4. Target Location
1. Content Editor → Find or create `/Global`
2. Example: `/Global` or `/Global/Content/Products`

---

## 🆘 If Path Doesn't Exist

| Problem | Solution |
|---------|----------|
| Template path not found | Check spelling, try parent folder `/sitecore/templates/Project/` |
| Item path not found | Verify it's not under `/sitecore/content/`, just use `/Tenant/...` |
| Global path doesn't exist | Create it first: `New-Item -Parent /sitecore/content -Name Global -ItemType "Folder"` |
| Not sure of exact path | Use broader path like `/Tenant` instead of `/Tenant/Node1` |

---

## 💾 Remember

- Paths are **case-sensitive** in some cases
- Don't include query strings or parameters
- Use forward slashes `/`, not backslashes `\`
- Trailing slashes don't matter: `/Tenant` = `/Tenant/`

---

**Need help?** When scripts ask for a path, start typing and PowerShell might auto-complete it.
