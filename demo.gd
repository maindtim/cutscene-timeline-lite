extends Control
## Lite demo: a hero and a guide walk toward each other and talk, driven by one CutsceneTimeline.
## Space = pause/resume, R = restart, left/right arrows = scrub.

var tl := CutsceneTimeline.new()
var t := 0.0
var prev := -0.0001
var playing := true
var log_lines: Array = []

const HERO_FROM := Vector2(120, 430)
const GUIDE_FROM := Vector2(1030, 430)


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	tl.append("move", "hero", 2.5, {"to": Vector2(470, 430), "ease": "in_out"})
	tl.append("say", "hero", 2.0, {"text": "Is this the way out?"})
	tl.append("wait", "guide", 1.0)
	tl.append("move", "guide", 2.0, {"to": Vector2(680, 430), "ease": "out"})
	tl.append("say", "guide", 2.5, {"text": "Follow the lights."})
	tl.append("event", "guide", 0.0, {"name": "lights_on"})
	tl.append("move", "hero", 1.5, {"to": Vector2(900, 330), "ease": "in"})


func _process(delta: float) -> void:
	if playing:
		prev = t
		t = minf(t + delta, tl.total_duration())
		for e in tl.events_between(prev, t):
			log_lines.append("event: %s @ %.2fs" % [e, t])
	queue_redraw()


func _unhandled_key_input(ev: InputEvent) -> void:
	if not ev.pressed:
		return
	match ev.keycode:
		KEY_SPACE: playing = not playing
		KEY_R:
			t = 0.0
			prev = -0.0001
			log_lines.clear()
			playing = true
		KEY_RIGHT:
			playing = false
			t = minf(t + 0.25, tl.total_duration())
		KEY_LEFT:
			playing = false
			t = maxf(t - 0.25, 0.0)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("1b2233"))
	draw_rect(Rect2(0, 470, size.x, size.y - 470), Color("2c3a52"))
	_actor("hero", HERO_FROM, Color("ffcf5c"))
	_actor("guide", GUIDE_FROM, Color("6ad1c4"))
	var f := ThemeDB.fallback_font
	draw_string(f, Vector2(24, 36), "t = %.2f / %.2f s   [Space] pause  [R] restart  [<-/->] scrub" % [t, tl.total_duration()], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
	for i in mini(log_lines.size(), 4):
		draw_string(f, Vector2(24, 64 + i * 22), log_lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("9fb3d1"))


func _actor(track: String, from: Vector2, col: Color) -> void:
	var p := tl.position_at(track, t, from)
	draw_circle(p, 26.0, col)
	var s := tl.text_at(track, t)
	if s != "":
		var f := ThemeDB.fallback_font
		var w := f.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x + 24.0
		draw_rect(Rect2(p + Vector2(-w * 0.5, -86), Vector2(w, 34)), Color.WHITE)
		draw_string(f, p + Vector2(-w * 0.5 + 12, -63), s, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("1b2233"))
