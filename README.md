# Adrenaline Bubbles Manager

**Create and organize direct Adrenaline bubbles for PSP/PSX content on PS Vita.**

**Current version: 6.21**

Compatible with:

- [TheOfficialFloW / Adrenaline v7](https://github.com/TheOfficialFloW/Adrenaline)
- [isage / Adrenaline 8.0.2](https://github.com/isage/Adrenaline)

---

## Description

Adrenaline Bubbles Manager (ABM) builds personalized Vita bubbles (icon, title, LiveArea) for PSP ISO/CSO/PBP and PSX content, using AdrBubbleBooter so games launch straight into Adrenaline.

ABM does **not** change the global PSP CPU speed of Adrenaline; per-bubble CPU options are written into each bubble’s boot config when you edit them.

---

## Important

1. Install **TheOfficialFloW Adrenaline v7** or **isage Adrenaline 8.0.2** and open Adrenaline at least once so it works.
2. Recommended `ur0:tai/config.txt` (under `*KERNEL`):

```
*KERNEL
ux0:app/PSPEMUCFW/sce_module/adrenaline_kernel.skprx
```

3. Then install this ABM VPK and use it to create or edit bubbles.

### NoPspEmuDrm

For downloaded PSP content you typically need the usual Adrenaline-side plugins (e.g. npdrm_free mod / np loader mod) installed inside Adrenaline.

---

## What’s new in 6.21 (official)

This release merges the community work from **shoui520** and restores official ABM features:

### From shoui520 (integrated)

- Support for **isage Adrenaline 8.0.2** and the ISAGECOMPAT AdrBubbleBooter stack
- Exact **CRC module detection** for TheOfficialFloW v7, isage 8.0.2, and known AdrBubbleBooter builds
- **Family-safe install/restore**: only known module sets are modified; unknown or mixed sets are left untouched
- **INFERNO / MARCH33 / NP9660** driver mapping fix (menu labels matched the wrong driver upstream)
- **In-place repair** of existing bubbles so they use the real INFERNO driver when selected
- **UTF-8** LiveArea title handling (no blank labels from multi-byte truncation)
- Faster bubble image preprocessing (temporary higher clocks during convert, then restored)
- Updated AdrBubbleBooter (menu-label fix) and optional direct-IFTU 2× scaling module builds

### Official ABM

- **ABM Update** re-enabled (startup check + Extra Settings toggle)
- Clearer **module layout** in the package (install vs restore, v7 vs 8.0.2)

---

## Module layout (package)

| Path | Role |
|------|------|
| `modules/sce_module_abm_v7/` | Modules ABM installs for **Adrenaline v7** (TheOfficialFloW) |
| `modules/sce_module_abm_8.0.2/` | Modules ABM installs for **Adrenaline 8.0.2** (isage) |
| `bubbles/restore_adrenaline_v7/sce_module/` | Original modules to **restore** v7 |
| `bubbles/restore_adrenaline_8.0.2/sce_module/` | Original modules to **restore** 8.0.2 |

ABM only replaces files under `ux0:app/PSPEMUCFW/sce_module/` when fingerprints match a supported family.

---

## First launch after update

1. Install the latest ABM `.vpk` with VitaShell.
2. Open ABM once — if Check Adrenaline is enabled, it may update modules (reboot may be required).
3. After reboot, open Adrenaline once, exit, then use ABM as usual.

---

## Changelog

### 6.21

- Merged shoui520 Adrenaline 8.0.2 / isage support, CRC detection, and family-safe install/restore
- Merged INFERNO driver mapping fix and in-place bubble repair
- Merged UTF-8 title handling and bubble creation performance improvements
- Restored **ABM Update** (startup + Extra Settings)
- Reorganized install/restore module folders for clarity

### 6.20 (upstream)

- Correct support for adrenaline bubbles with `boot.bin`

### 6.19 – 6.15 (upstream)

- Language download option; online resources / JSON previews
- OSK CR fix; bubble template styles (PSPEMU, PS1EMU, PSMOBILE, A5)
- Restore Adrenaline option; editable bubble titles
- Various scan and image fixes

---

## Controls (summary)

ABM respects the console’s accept/cancel button region.

**Content selection**

| Control | Action |
|---------|--------|
| **X** | Create bubble(s) |
| **O** | Edit / manage bubbles |
| **Triangle** | Batch install (non-installed) |
| **Square** | Multi-select |
| **L** | Icon style (original / stretched) |
| **R** | SetPack (PSP/PSX / Default) |
| **SELECT** | Sort list |
| **Left/Right** | Bubble background color |
| **START** | Extra Settings |
| **Right analog up + Up** | Template style for selection |

**Extra Settings** includes defaults (bubble ID, 8-bit convert, sort, color, name, template, language), **Check Adrenaline**, **ABM Update**, language download, and **Restore Adrenaline** (v7 or 8.0.2 according to detection).

**Bubble edit (Triangle)** — driver, execute bin, customized, PS button mode, suspend, plugins, NonpDRM, high memory, CPU speed; path and title can be edited when needed.

---

## Credits

- **Gdljjrod** & **DevDavisNunez** — original Adrenaline Bubbles Manager (ONELua)
- **shoui520** — AdrBubbleBooter-oss, driver/label fixes, isage 8.0.2 support, UTF-8 titles, performance work, module fingerprints, and related improvements integrated into this release
- **TheOfficialFloW** — Adrenaline
- **isage** — Adrenaline 8.x
- **LMAN** — original AdrBubbleBooter

---

## License

See repository `LICENSE` (project files retain their existing license headers).
