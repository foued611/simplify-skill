# simplify — /simplify-Skill

Verhaltensneutrale Vereinfachung eines frisch geschriebenen Diffs **vor** Review und PR — damit Reviewer und Gates die endgültige Form sehen, nicht eine, die sich danach noch ändert.

## Was die Skill tut

- **Vier Linsen** prüfen den Diff unabhängig voneinander:
  - **Wiederverwendung** — deckt der Bestand die Stelle schon (Helfer, Muster, Konstante)?
  - **Vereinfachung** — kürzer/klarer ohne Verhaltensänderung (inkl. tote Parameter)?
  - **Effizienz** — unnötige Arbeit mit nennenswertem Effekt?
  - **Flughöhe** — richtige Ebene, wahrheitstreue Kommentare?
- **Modus nach Aufwand:** ab ~100 geänderten Code-Zeilen oder >2 Dateien Fan-out über parallele, gedächtnislose, read-only Subagenten; darunter inline; ohne Subagenten-Werkzeug Fallback in getrennten Durchgängen.
- **Harte Grenzen:** verhaltensneutral — Tests, Assertion-Texte und Szenario-Token (Rot-Beweis) bleiben unangetastet; echte Bugs werden gemeldet, nie heimlich mitgefixt; fremder Code wird gemeldet, nie angefasst; nach dem Anwenden laufen Build und betroffene Tests erneut.

## Installation (Claude Code)

```bash
git clone git@github.com:foued611/simplify-skill.git
mkdir -p ~/.claude/skills
cp -R simplify-skill ~/.claude/skills/simplify   # SKILL.md ist Pflicht, evals/ optional
```

Danach per „mach einen simplify-Lauf über den Diff" / `/simplify` auslösen. Andere Agenten, die SKILL.md-Dateien lesen, funktionieren genauso.

## Evals

Drei Fälle unter `evals/`, jeder mit `prompt.md` (User-Anfrage), `case.yaml` (Erwartung), `graders/` (Assertionen) und `fixture.bundle` (Git-Bundle mit `main` + Feature-Branch).

Fixture materialisieren und Tests prüfen:

```bash
mkdir work && cd work
bash <repo>/evals/<fall>/place-files.sh     # klont das Bundle, checkt den Feature-Branch aus
node --test src/*.test.js                   # Basislinie: giftcard 6/0, reminder 3/1 (eingebauter Bug), card-sync 5/0
```

Ein Lauf = Agent mit `prompt.md` einmal **mit** SKILL.md und einmal **ohne**; danach die Assertionen aus `graders/` bewerten. `reminder-inline` trägt absichtlich einen Bug (Test erwartet `faellig(25*STD,0)` = true, das Default-Fenster ist 24 h) — prüft, ob der Lauf ihn meldet statt still zu fixen. `card-sync-decline` trägt eine Fallgrube (Re-Query in der Poll-Loop ist Korrektheit wegen eingefrorener Snapshots — Hoisten wäre der Fehler).

## Benchmark

| Konfiguration | Pass-Rate |
|---|---|
| Mit Skill | **18/18 (100 %)** |
| Ohne Skill | 15/18 (84 %) |

Ohne Skill wurden stillschweigend Tests gelöscht bzw. ein Test umgeschrieben, um einen eingebauten Bug grün zu bekommen — genau die Verletzungen, gegen die die Skill schützt. Zwei Iterationen (v2 = token-optimiert, 70 Zeilen Skill-Text, „ein Fund pro Zeile"); Laufzeit-/Token-Messung in der verwendeten Harness nicht verfügbar.
