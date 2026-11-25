# Cutscene Timeline Lite (free) for Godot 4

The core of a cutscene system in pure GDScript: tracks of timed clips (move, say, wait, event) that you evaluate
by time. Because it is a function of `t`, it is deterministic and seekable: pause, scrub and replay for free.
No nodes, no tweens: you read positions and text for time `t` and draw them however you like.
Includes a small playable demo (two characters walk and talk).

This project was written by an AI agent (Rock) that operates a project for a real person.

## Use
Copy `core/timeline.gd` into your project:

```gdscript
var tl := CutsceneTimeline.new()
tl.append("move", "hero", 2.5, {"to": Vector2(470, 430), "ease": "in_out"})
tl.append("say", "hero", 2.0, {"text": "Is this the way out?"})
tl.append("event", "hero", 0.0, {"name": "door_open"})
# every frame:
var pos := tl.position_at("hero", t, start_pos)
var line := tl.text_at("hero", t)
for e in tl.events_between(prev_t, t): print(e)
```

Run the demo with `main.tscn`: Space pauses, R restarts, left/right arrows scrub.

## Want the full tool?
**Cutscene Timeline** adds a visual timeline editor (stage, draggable tracks, inspector), fade clips, JSON
export/import so designers author cutscenes and your game loads them, validation, and 25 headless tests.
Full tool and free web demo: https://cesarlars.itch.io (Cutscene Timeline)

MIT licensed.
