# RaidMarker Addon für WoW WotLK 3.3.5

Ein simples, kompaktes Addon zum Platzieren von Raid-Markern auf dem Boden und auf Zielen.

## Installation

1. Kopiere den gesamten Ordner in deinen WoW Addons-Ordner:
   ```
   World of Warcraft/Interface/AddOns/RaidMarker/
   ```

2. Die folgenden Dateien müssen im Ordner sein:
   - `RaidMarker.toc`
   - `RaidMarker.lua`
   - `RaidMarker_Options.lua`

3. Starte WoW neu oder lade die Addons mit `/reload` neu

## Verwendung

### Addon öffnen/schließen
```
/rm
```

### Marker platzieren
- **Linksklick** auf einen Marker: Platziert den Marker auf dem Boden (an deiner Cursorposition)
- **Rechtsklick** auf einen Marker: Setzt den Marker auf dein aktuelles Ziel
- **Shift + Klick**: Entfernt diesen spezifischen Marker

### Alle Marker entfernen
- **Rotes X - Linksklick**: Entfernt alle Boden-Marker
- **Rotes X - Rechtsklick**: Entfernt Marker vom Ziel

## Befehle

- `/rm` - Öffnet/Schließt das Marker-Fenster
- `/rm options` - Öffnet das Optionsmenü
- `/rm lock` - Sperrt die Position des Fensters
- `/rm unlock` - Entsperrt die Position des Fensters
- `/rm scale [0.5-2.0]` - Setzt die Größe des Fensters (z.B. `/rm scale 1.5`)
- `/rm reset` - Setzt Position und Größe zurück
- `/rm help` - Zeigt alle Befehle an

## Features

✅ **8 Raid-Marker**: Star, Circle, Diamond, Triangle, Moon, Square, Cross, Skull
✅ **Kompaktes Design**: Nur 200x120 Pixel, einfach zu verschieben
✅ **Boden-Marker**: Linksklick platziert Marker auf dem Boden
✅ **Ziel-Marker**: Rechtsklick setzt Marker auf dein Ziel
✅ **Skalierbar**: Größe von 50% bis 200% anpassbar
✅ **Sperrbar**: Frame kann gesperrt werden, damit es nicht versehentlich verschoben wird
✅ **Tooltips**: Zeigt Hinweise beim Überfahren mit der Maus
✅ **Slash-Command**: `/rm` zum schnellen Öffnen/Schließen

## Optionsmenü

Das Optionsmenü erreichst du mit `/rm options` und bietet:

- **Skalierungs-Slider**: Passe die Größe des Fensters an (0.5 - 2.0)
- **Frame Lock Checkbox**: Sperre/Entsperre die Position
- **Verwendungshinweise**: Zeigt alle Funktionen und Befehle
- **Reset-Button**: Setzt Position und Größe zurück

## Marker-Übersicht

| Marker | Index | Verwendung |
|--------|-------|-----------|
| ⭐ Star | 1 | Gelber Stern |
| 🟠 Circle | 2 | Oranger Kreis |
| 💎 Diamond | 3 | Lila Diamant |
| 🔺 Triangle | 4 | Grünes Dreieck |
| 🌙 Moon | 5 | Weißer Mond |
| 🟦 Square | 6 | Blaues Quadrat |
| ❌ Cross | 7 | Rotes Kreuz |
| 💀 Skull | 8 | Weißer Totenkopf |

## Tipps

- **Frame verschieben**: Ziehe das Fenster mit gedrückter linker Maustaste (wenn nicht gesperrt)
- **Schnell platzieren**: Benutze `/rm`, platziere Marker, schließe mit `/rm` wieder
- **Makros**: Du kannst auch Makros erstellen für schnelleren Zugriff
- **Raid-Leiter**: Nur Raid- oder Gruppenleiter können Boden-Marker platzieren
- **Ziel-Marker**: Jeder Gruppenmitglied kann Ziel-Marker setzen

## Systemanforderungen

- **WoW Version**: 3.3.5 (WotLK)
- **Rechte für Boden-Marker**: Raid-Leiter oder Gruppen-Leiter
- **Rechte für Ziel-Marker**: Alle Gruppenmitglieder

## Support & Anpassungen

Das Addon speichert alle Einstellungen automatisch in der `SavedVariables` Datei.

Falls du das Addon komplett zurücksetzen möchtest:
1. Schließe WoW
2. Lösche die Datei: `WTF/Account/[DEIN_ACCOUNT]/SavedVariables/RaidMarker.lua`
3. Starte WoW neu

## Version

**Version 1.0** - Erstveröffentlichung

Viel Spaß beim Raiden! 🎮
