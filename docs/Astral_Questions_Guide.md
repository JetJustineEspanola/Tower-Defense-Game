# Astral questions

## Try it

Open scenes/ui/lan_lobby.tscn in Godot and press F6. Choose **Host**, then **Astral questions / Edit deck**.

The Web Development starter deck contains 12 questions: four multiple choice, four identification, and four short code fixes. Each correct answer gives 25 gold by default.

1. Select a question on the left.
2. Change the question and its answer in the middle.
3. Select **Preview question**, try an answer, and choose **Check answer**.
4. Choose **Use this deck** to save and select it for matches.

Run maps/main_map.tscn or scenes/attacker/attacker_match.tscn with F6 to try the selected deck. Lobby networking and starting a shared match are still separate future work.

## Make your own

Choose **New deck**, enter a name, and add questions. The current valid deck is saved before creating or loading another. **Save** keeps changes without changing the selected match deck. **Close** retains the draft while the lobby stays open; save before leaving the lobby or quitting.

Tick the question types you want included in matches. At least one card must match an enabled type.

- **Multiple choice:** enter four different options and choose the correct one.
- **Identification:** enter accepted answers. Capitalization and repeated spaces, tabs, and line breaks are ignored.
- **Code fix:** give a short broken snippet and clearly state which part the player must replace. Accepted solutions preserve case, spaces, and indentation; one final newline is ignored. The game compares approved text and never executes submitted code.

For alternate typed answers, put three hyphens on a line between them:

```text
flexbox
---
flexible box
---
flexible box layout
```

Gold defaults to 25 and can be changed per question (1–1000). Keep rewards consistent while balancing the game. Add a short explanation to teach the answer after submission. The host is responsible for reviewing answer correctness; validation checks the format, not the meaning.

## Use notes

Attach a PDF, DOCX, or TXT file under 20 MB. Select it and choose **Open** to read it in your installed document app while writing questions. The game keeps a local copy. **Detach** removes its link from the deck.

Notes are reference documents. Automatic question generation from notes is not implemented. **Import deck** accepts formatted JSON, not ordinary notes. Use resources/questions/web_starter.json as the example format. Imported decks are validated before loading.

## Match rules

The selected deck is copied when the question sidebar starts. Each question session shuffles its own order. A card is presented once per cycle; skipping consumes its place in the cycle too.

Each appearance allows one submission. A wrong answer gives no gold and cannot be retried until its next cycle. A correct answer awards its configured gold once. After all eligible cards are consumed, the deck reshuffles and rewards become available again. Next/skip costs 10 mana; the initial card is free. With multiple cards, the same card is not repeated immediately across a cycle boundary.

Changing the selected deck in the host lobby clears both displayed ready states. Current matches keep their existing deck snapshot.

This version works locally. Sending the same deck to both PCs, enforcing host-only edits over LAN, and validating rewards on the host must be connected when networking is implemented.

## Editable project files

- scenes/questions/deck_editor.tscn: editor controls, labels, buttons, and layout.
- scripts/questions/deck_editor.gd: editor actions.
- scripts/questions/deck_store.gd: validation, storage, and answer comparison.
- scripts/questions/question_run.gd: per-player shuffle, cycle, and submission state.
- resources/questions/web_starter.tres: default deck as a Godot Resource.
- resources/questions/web_starter.json: importable version of the example deck.
- scenes/Arcane_question/arcane_question_test.tscn: shared gameplay sidebar, including typed answer input.

Saved decks use Godot's user data folder: user://astral_decks. The selected deck is user://astral_selected.json. Reference copies are user://astral_notes. In Godot, use **Project > Open User Data Folder** to find these files. Keep the JSON and Resource examples synchronized if editing the starter outside the editor.

## Learning references

The examples cover stable introductory web concepts. Further reading:

- [MDN: JavaScript basics](https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Scripting/What_is_JavaScript)
- [MDN: querySelector](https://developer.mozilla.org/en-US/docs/Web/API/Document/querySelector)
- [MDN: Document Object Model](https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model)
- [MDN: addEventListener](https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/addEventListener)
