## [2.0.6] - 2026-07-29

### Added
- Tooltip on hover - Hides in combat but shows if you hover over it when entering combat.

---

## [2.0.5] - 2026-07-23

### Added
- Support for patch 12.1.0
- Added Ruby Whelp Shell to default blacklist

---

## [2.0.4] - 2026-07-08

### Changed
- Rebuilt the Options panel properly
- Moved glow panel and blacklist to new files

---

## [2.0.3] - 2026-06-13

### Added
- Support for patch 12.0.7

### Changed
- Options panel color
- Edit Mode container size

---

## [2.0.2] - 2026-05-05

### Fixed
- Glow size not following trinket size correctly

---

## [2.0.1] - 2026-05-02

### Fixed
- Glow hide timer accidentally removed in 2.0.0

---

## [2.0.0] - 2026-05-02

### Added
- Glow options panel
- Tab structure to the options panel

### Changed
- Reworked options panel to feel more standalone

---

## [1.9.1] - 2026-04-29

### Fixed
- Gap feature edge cases missed during testing

---

## [1.9.0] - 2026-04-28

### Added
- Slider to control gap between icons
- Glow on cooldown expiry, lasting 3 seconds

---

## [1.8.1] - 2026-04-19

### Changed
- TOC updated for patch 12.0.5
- Default blacklist updated to current expansion trinkets

### Removed
- SavedVariablesPerCharacter

---

## [1.8.0] - 2026-04-05

### Added
- Global function/name table for structure and future-proofing
- So'leah's Secret Technique re-added to default blacklist
- Default blacklist now force-updates on every reload

### Changed
- DB structure no longer uses `_initialized` block to avoid blacklist resets

### Removed
- Redundant code and structural debt

---

## [1.7.0] - 2026-04-04

### Added
- Drum of Renewed Bonds added to default blacklist

### Fixed
- Cooldown swipe and numbers broken by the 1.6.0 size fix

### Removed
- So'leah's Secret Technique removed from default blacklist

---

## [1.6.0] - 2026-04-03

### Fixed
- Trinket size not persisting correctly after reload or relog

---

## [1.5.0] - 2026-03-15

### Added
- Masque support
- Adjusted size slider range to work better with Masque

### Removed
- Bloated code
