---
name: simplify
description: Führt den /simplify-Schritt aus — verhaltensneutrale Vereinfachung eines frisch geschriebenen Diffs (Feature, Bugfix, PR-Branch) VOR Review und Merge. Nutze diese Skill IMMER, wenn der Nutzer „simplify", „/simplify", „räum das auf", „vereinfache den Diff/das PR/den Branch", „clean up my change", „make it simpler before I open the PR" sagt oder nach dem Implementieren vor dem Review eine Aufräum-Passage verlangt. Auch bei „der Code funktioniert, aber gefällt mir nicht" oder „mach den Change review-fertig". NICHT für Bestands-Audits (ganze Codebase, Tech-Debt — dafür gibt es Audit-Skills), nicht für Korrektheits-Reviews (Bugs, Security) und nicht für Refactoring mit gewollter Verhaltensänderung.
---

# simplify — diff-gescopete Vereinfachung vor dem Review

Vereinfacht einen frisch geschriebenen Diff **vor** Review und Merge, damit Gates und Reviewer die endgültige Form sehen — nicht eine, die sich danach noch ändert. Die Passage ist **verhaltensneutral**: kürzen, entduplizieren, auf die richtige Ebene rücken. Sie ändert nicht, was der Code tut.

**Nicht im Umfang:** reine Doku-/Config-/Prompt-Änderungen, Umbenennungen ohne Verhaltensbezug, Bestands-Audit, Korrektheits-Review. Ein echter Bug wird gemeldet (oder offen nach den Repo-Regeln behandelt) — nie heimlich unter dem Vereinfachungs-Label gefixt.

## Schritt 0 — Scope und Modus

1. **Diff feststellen:** Base = Ziel-Branch des Changes (aus Branch-Name, PR-Info oder Nachfrage: `origin/dev`, `origin/main` …). Dann `git merge-base <base> HEAD`, `git diff <mb>...HEAD --stat` plus geänderte Dateien mit Zeilenzahl. Commit-Bereich `A..B` geht genauso.
2. **Verdrahtung erkennen:** Gibt es ein Vertrags-/Manifest-Dokument (Spec, Auftrag)? Tragen Tests Szenario-Token oder Assertion-Texte, die ein Rot-Beweis aus der Git-Historie liest? Diese Texte sind **unantastbar**. Liefen Beweis-/Gate-Läufe bereits, sind sie nach angewandten Änderungen erneut zu fahren und zu dokumentieren.
3. **Modus:** ab rund 100 geänderten Code-Zeilen oder mehr als zwei Dateien → **Fan-out** (vier Linsen als parallele, gedächtnislose, read-only Subagenten — unabhängige Perspektiven finden mehr als eine gemischte). Darunter → **Inline** (dieselben vier Linsen in einem Durchgang; für einen Mini-Diff vier Agenten zu starten kostet mehr als es bringt).

Steht dir kein Subagenten-Werkzeug zur Verfügung: fahre die vier Linsen nacheinander in **getrennten Durchgängen** ab (je Linse Diff neu lesen) — der Fokus-Vorteil bleibt gegenüber einer gemischten Einzelpassage.

## Die vier Linsen

| Linse | Frage | Latte — wann ein Fund zählt |
|---|---|---|
| **Wiederverwendung** | Deckt der Bestand die Stelle schon (Helfer, Muster, Konstante)? Grep/glob nach ähnlichen Namen. | Austausch verhaltensgleich UND der Bestands-Helfer deckt die Stelle wirklich besser. Abstraktion für genau einen Aufrufer = Anti-Pattern, dann ist Eigenbau richtig. |
| **Vereinfachung** | Wird der Code kürzer oder klarer, ohne sein Verhalten zu ändern? | Messbarer Gewinn (Zeilen, Klarheit, eine statt zwei Wahrheitsquellen), kein Geschmacksurteil. **Toter Parameter:** kein Aufrufer übergibt einen Nicht-Default-Wert UND kein Test greift auf ihn zu → Entfernung ist verhaltensneutral, kein Feature-Eingriff. Assertion-Texte von Beweis-Tests unberührt lassen. |
| **Effizienz** | Macht der neue Code unnötige Arbeit? | Nennbarer Effekt mit Zähl- oder Messgröße; „könnte mikroeffizienter sein" ist kein Fund. Achtung Falle: Re-Query in Poll-Loops ist oft Korrektheit (eingefrorene Snapshots) — erst prüfen, dann melden. |
| **Flughöhe** | Liegt der Code auf der richtigen Ebene, sagen Kommentare die Wahrheit? | Der Bestand entscheidet die Konvention (Literal vs. geteilte Konstante — was macht die Umgebung?). Lügen-Kommentar ist ein Fund. |

## Rollenvertrag (je Prüfer, Linse einsetzen)

```
Du bist /simplify-Prüfer, Linse: <LINSE>. RESEARCH ONLY — du änderst keine Dateien.
Repo: <pfad> (Branch <name>, Base <base>)
Prüfling: git -C <repo> diff <mb>...HEAD — vollständig lesen, geänderte Dateien im Ganzen.
Auftrag: <Frage + Latte deiner Linse>
Regeln:
- Fund: datei:zeile + konkretes vorher→nachher + Ein-Satz-Begründung der Verhaltensgleichheit.
- Dateien außerhalb des Diffs nur als „gemeldet" markieren. Kein Fund ohne Latte, keine vagen Bedenken.
- Antwort: Funde-Liste, ein Fund pro Zeile — oder „keine Funde" plus einen Satz, was geprüft wurde. Kein Vorwort, kein Nachwort.
```

## Anwenden oder ablehnen

Der Orchestrator (nicht die Prüfer) entscheidet je Fund — ein Fund ist ein Angebot, kein Befehl. **Anwenden**, wenn er die Latte seiner Linse erfüllt und verhaltensneutral bleibt. **Ablehnen mit Begründung** (in den Rapport), wenn der Fund:

- Verhalten, Verträge, Szenario-Token oder Assertion-Texte berührt,
- eine Abstraktion für genau einen Aufrufer baut,
- Code außerhalb des eigenen Diffs anfasst (→ stattdessen melden),
- nur Geschmack ohne messbaren Gewinn ist,
- eine Sicherheits-Eigenschaft gegen Mikro-Vereinfachung tauscht (typisch: zentrales Budget/Timeout durch per-Stellen-Optionen ersetzen — eine vergessene Stelle fällt lautlos auf einen zu kleinen Default zurück).

## Anwenden und erneut verifizieren

1. Zentral anwenden (eine Runde; Re-Verify rot → gezielt fixen, höchstens zwei Runden, dann offen rapportieren).
2. Build und betroffene Tests erneut grün fahren — der Lauf ändert Code, früheres Grün ist kein Beleg mehr.
3. Beweis-/Gate-Läufe (Rot-Beweis, Coverage-Gate, Preflight) erneut fahren und die neue Ausgabe dokumentieren.
4. Funde in fremdem Code nie mitfixen — sie wandern in den Rapport.

## Rapport-Format

```
## /simplify — <Branch/Diff-Kennung>

Umgesetzt (je: datei:zeile, was, warum verhaltensneutral): …
Abgelehnt (je: Fund, Grund): …
Gemeldet, nicht umgesetzt (fremder Code, Folge-Arbeit): …
Verifikation: <gelaufene Kommandos + Ergebnis>
```

Rapport in den PR-Body oder als Chat-Zusammenfassung — wie die Umgebung es verlangt.
