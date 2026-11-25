class_name CutsceneTimeline
extends RefCounted
## Cutscene timeline (Lite): tracks of timed clips, evaluated by time (deterministic, seekable).
## Clip kinds: "move" (to: Vector2, ease), "say" (text), "wait", "event" (name).
## Each clip: {kind, track, start, duration, ...params}. Tracks are independent (parallel).

var clips: Array = []


static func make_clip(kind: String, track: String, start: float, duration: float, params: Dictionary = {}) -> Dictionary:
	var c := {"kind": kind, "track": track, "start": maxf(start, 0.0), "duration": maxf(duration, 0.0)}
	c.merge(params)
	return c


func add_clip(c: Dictionary) -> void:
	clips.append(c)
	clips.sort_custom(func(a, b): return a.start < b.start)


## Appends a clip right after the last clip of that track.
func append(kind: String, track: String, duration: float, params: Dictionary = {}) -> Dictionary:
	var t := 0.0
	for c in clips:
		if c.track == track:
			t = maxf(t, c.start + c.duration)
	var clip := make_clip(kind, track, t, duration, params)
	add_clip(clip)
	return clip


func total_duration() -> float:
	var t := 0.0
	for c in clips:
		t = maxf(t, c.start + c.duration)
	return t


static func ease_value(t: float, mode: String) -> float:
	t = clampf(t, 0.0, 1.0)
	match mode:
		"in": return t * t
		"out": return 1.0 - (1.0 - t) * (1.0 - t)
		"in_out": return t * t * (3.0 - 2.0 * t)
		_: return t


## Progress 0..1 of a clip at time t (instant clips: 0 before start, 1 from start).
static func progress(c: Dictionary, t: float) -> float:
	if t < c.start:
		return 0.0
	if c.duration <= 0.0:
		return 1.0
	return clampf((t - c.start) / c.duration, 0.0, 1.0)


## Position of a track's actor at time t. `from` is the position before any clip.
func position_at(track: String, t: float, from: Vector2) -> Vector2:
	var pos := from
	for c in clips:
		if c.track != track or c.kind != "move" or t < c.start:
			continue
		var k := ease_value(progress(c, t), c.get("ease", "linear"))
		pos = pos.lerp(c.to, k)
	return pos


## Text being said on a track at time t ("" if none).
func text_at(track: String, t: float) -> String:
	for c in clips:
		if c.track == track and c.kind == "say" and t >= c.start and t < c.start + c.duration:
			return c.text
	return ""


## Events whose start falls in (t0, t1]. Use for playback; seeking does not re-fire.
func events_between(t0: float, t1: float) -> Array:
	var out: Array = []
	for c in clips:
		if c.kind == "event" and c.start > t0 and c.start <= t1:
			out.append(c.name)
	return out
