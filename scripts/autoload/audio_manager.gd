extends Node
## Gerenciador procedural de efeitos sonoros (PCM 16-bit mono 22050Hz em memória).
## Compatível com Desktop, Web HTML5 single-threaded e modo --headless sem assets externos.

signal mute_changed(is_muted: bool)

const SAMPLE_RATE: int = 22050
const POOL_SIZE: int = 6

var muted: bool = false

var _streams: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _next_player_idx: int = 0


func _ready() -> void:
	_init_player_pool()
	_synthesize_all_sfx()


func _exit_tree() -> void:
	for player in _players:
		if is_instance_valid(player):
			player.stop()
			player.stream = null
	_players.clear()
	_streams.clear()


func _init_player_pool() -> void:
	for i in range(POOL_SIZE):
		var player := AudioStreamPlayer.new()
		player.name = "SFXPlayer_%d" % i
		add_child(player)
		_players.append(player)


func _synthesize_all_sfx() -> void:
	_streams["hoe"] = _make_hoe_sfx()
	_streams["water"] = _make_water_sfx()
	_streams["plant"] = _make_plant_sfx()
	_streams["harvest"] = _make_harvest_sfx()
	_streams["coin"] = _make_coin_sfx()
	_streams["error"] = _make_error_sfx()
	_streams["click"] = _make_click_sfx()
	_streams["sleep"] = _make_sleep_sfx()
	_streams["chicken"] = _make_chicken_sfx()
	_streams["cow"] = _make_cow_sfx()


func toggle_mute() -> bool:
	muted = not muted
	if muted:
		for player in _players:
			if is_instance_valid(player):
				player.stop()
	mute_changed.emit(muted)
	if not muted:
		play_click()
	return muted


func is_muted() -> bool:
	return muted


func play_hoe() -> void:
	_play_sfx("hoe", -5.0)


func play_water() -> void:
	_play_sfx("water", -6.0)


func play_plant() -> void:
	_play_sfx("plant", -6.0)


func play_harvest() -> void:
	_play_sfx("harvest", -5.0)


func play_coin() -> void:
	_play_sfx("coin", -5.0)


func play_error() -> void:
	_play_sfx("error", -7.0)


func play_click() -> void:
	_play_sfx("click", -8.0)


func play_sleep() -> void:
	_play_sfx("sleep", -5.0)


func play_animal(animal_type: String) -> void:
	if animal_type == "cow":
		_play_sfx("cow", -5.0)
	else:
		_play_sfx("chicken", -5.0)


func _play_sfx(key: String, volume_db: float = -6.0) -> void:
	if muted or not is_inside_tree():
		return
	if not _streams.has(key) or _players.is_empty():
		return
	var stream: AudioStreamWAV = _streams[key]
	if stream == null:
		return

	var chosen: AudioStreamPlayer = null
	for player in _players:
		if is_instance_valid(player) and player.is_inside_tree() and not player.playing:
			chosen = player
			break
	if chosen == null:
		var candidate := _players[_next_player_idx % _players.size()]
		_next_player_idx = (_next_player_idx + 1) % _players.size()
		if is_instance_valid(candidate) and candidate.is_inside_tree():
			chosen = candidate
	if chosen == null:
		return

	chosen.stream = stream
	chosen.volume_db = volume_db
	chosen.play()


func _build_wav(samples: PackedFloat32Array) -> AudioStreamWAV:
	var count: int = samples.size()
	var buf := PackedByteArray()
	buf.resize(count * 2)
	for i in range(count):
		var clamped: float = clampf(samples[i], -1.0, 1.0)
		var pcm16: int = int(round(clamped * 32767.0))
		buf.encode_s16(i * 2, pcm16)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = buf
	return wav


func _triangle(phase: float) -> float:
	var frac: float = phase - floor(phase)
	return 4.0 * absf(frac - 0.5) - 1.0


func _make_hoe_sfx() -> AudioStreamWAV:
	var duration: float = 0.11
	var count: int = int(duration * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var rng := RandomNumberGenerator.new()
	rng.seed = 101
	var phase: float = 0.0
	var prev_noise: float = 0.0
	for i in range(count):
		var t: float = float(i) / float(SAMPLE_RATE)
		var u: float = float(i) / float(count)
		var freq: float = lerpf(190.0, 62.0, u)
		phase += freq / float(SAMPLE_RATE)
		var raw_noise: float = rng.randf_range(-1.0, 1.0)
		prev_noise = lerpf(prev_noise, raw_noise, 0.25)
		var env: float = minf(1.0, t / 0.008) * exp(-u * 5.2)
		samples[i] = (0.65 * _triangle(phase) + 0.35 * prev_noise) * env * 0.75
	return _build_wav(samples)


func _make_water_sfx() -> AudioStreamWAV:
	var duration: float = 0.19
	var count: int = int(duration * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var rng := RandomNumberGenerator.new()
	rng.seed = 202
	var bubble_phase: float = 0.0
	var lp_noise: float = 0.0
	for i in range(count):
		var t: float = float(i) / float(SAMPLE_RATE)
		var u: float = float(i) / float(count)
		var bubble_freq: float = lerpf(420.0, 820.0, u) + 90.0 * sin(t * 55.0)
		bubble_phase += bubble_freq / float(SAMPLE_RATE)
		var raw_noise: float = rng.randf_range(-1.0, 1.0)
		lp_noise = lerpf(lp_noise, raw_noise, 0.35)
		var env: float = sin(PI * minf(1.0, u)) * exp(-u * 1.4)
		samples[i] = (0.45 * lp_noise + 0.35 * sin(TAU * bubble_phase)) * env * 0.65
	return _build_wav(samples)


func _make_plant_sfx() -> AudioStreamWAV:
	var duration: float = 0.095
	var count: int = int(duration * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var phase: float = 0.0
	for i in range(count):
		var t: float = float(i) / float(SAMPLE_RATE)
		var u: float = float(i) / float(count)
		var freq: float = lerpf(310.0, 560.0, pow(u, 0.7))
		phase += freq / float(SAMPLE_RATE)
		var env: float = minf(1.0, t / 0.006) * exp(-u * 4.5)
		samples[i] = (0.75 * sin(TAU * phase) + 0.25 * _triangle(phase)) * env * 0.65
	return _build_wav(samples)


func _make_harvest_sfx() -> AudioStreamWAV:
	var notes: Array[float] = [523.25, 659.25, 783.99]
	var note_dur: float = 0.065
	var note_samples: int = int(note_dur * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(note_samples * notes.size())
	var idx: int = 0
	for n in notes:
		for j in range(note_samples):
			var u: float = float(j) / float(note_samples)
			var t: float = float(j) / float(SAMPLE_RATE)
			var env: float = minf(1.0, t / 0.006) * exp(-u * 3.0)
			var val: float = 0.7 * sin(TAU * n * t) + 0.3 * _triangle(n * t)
			samples[idx] = val * env * 0.6
			idx += 1
	return _build_wav(samples)


func _make_coin_sfx() -> AudioStreamWAV:
	var dur1: int = int(0.06 * SAMPLE_RATE)
	var dur2: int = int(0.16 * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(dur1 + dur2)
	for i in range(dur1):
		var t: float = float(i) / float(SAMPLE_RATE)
		var u: float = float(i) / float(dur1)
		var env: float = minf(1.0, t / 0.004) * exp(-u * 2.5)
		samples[i] = (0.8 * sin(TAU * 987.77 * t) + 0.2 * sin(TAU * 1975.53 * t)) * env * 0.6
	for j in range(dur2):
		var t: float = float(j) / float(SAMPLE_RATE)
		var u: float = float(j) / float(dur2)
		var env: float = minf(1.0, t / 0.004) * exp(-u * 4.5)
		samples[dur1 + j] = (0.8 * sin(TAU * 1318.51 * t) + 0.2 * sin(TAU * 2637.02 * t)) * env * 0.6
	return _build_wav(samples)


func _make_error_sfx() -> AudioStreamWAV:
	var duration: float = 0.17
	var count: int = int(duration * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var phase: float = 0.0
	for i in range(count):
		var t: float = float(i) / float(SAMPLE_RATE)
		var u: float = float(i) / float(count)
		var freq: float = 215.0 if u < 0.48 else 160.0
		phase += freq / float(SAMPLE_RATE)
		var env: float = minf(1.0, t / 0.008) * (1.0 - u)
		samples[i] = (0.6 * _triangle(phase) + 0.4 * sin(TAU * phase)) * env * 0.55
	return _build_wav(samples)


func _make_click_sfx() -> AudioStreamWAV:
	var duration: float = 0.036
	var count: int = int(duration * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var phase: float = 0.0
	for i in range(count):
		var t: float = float(i) / float(SAMPLE_RATE)
		var u: float = float(i) / float(count)
		var freq: float = lerpf(780.0, 440.0, u)
		phase += freq / float(SAMPLE_RATE)
		var env: float = minf(1.0, t / 0.003) * exp(-u * 5.5)
		samples[i] = sin(TAU * phase) * env * 0.55
	return _build_wav(samples)


func _make_sleep_sfx() -> AudioStreamWAV:
	var notes: Array[float] = [329.63, 392.00, 523.25]
	var note_samples: int = int(0.14 * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(note_samples * notes.size())
	var idx: int = 0
	for n in notes:
		for j in range(note_samples):
			var t: float = float(j) / float(SAMPLE_RATE)
			var u: float = float(j) / float(note_samples)
			var env: float = minf(1.0, t / 0.015) * exp(-u * 2.8)
			samples[idx] = (0.85 * sin(TAU * n * t) + 0.15 * sin(TAU * n * 2.0 * t)) * env * 0.55
			idx += 1
	return _build_wav(samples)


func _make_chicken_sfx() -> AudioStreamWAV:
	var duration: float = 0.22
	var count: int = int(duration * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var phase: float = 0.0
	for i in range(count):
		var u: float = float(i) / float(count)
		var active: bool = (u < 0.36) or (u > 0.50 and u < 0.92)
		var local_u: float = (u / 0.36) if u < 0.36 else ((u - 0.50) / 0.42)
		var freq: float = 640.0 + 260.0 * sin(PI * clampf(local_u, 0.0, 1.0))
		phase += freq / float(SAMPLE_RATE)
		if active:
			var env: float = sin(PI * clampf(local_u, 0.0, 1.0))
			samples[i] = (0.65 * _triangle(phase) + 0.35 * sin(TAU * phase)) * env * 0.58
		else:
			samples[i] = 0.0
	return _build_wav(samples)


func _make_cow_sfx() -> AudioStreamWAV:
	var duration: float = 0.38
	var count: int = int(duration * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var phase: float = 0.0
	var smooth: float = 0.0
	for i in range(count):
		var t: float = float(i) / float(SAMPLE_RATE)
		var u: float = float(i) / float(count)
		var freq: float = lerpf(150.0, 122.0, u) + 18.0 * sin(PI * u)
		phase += freq / float(SAMPLE_RATE)
		var raw: float = 0.55 * _triangle(phase) + 0.45 * sin(TAU * phase)
		smooth = lerpf(smooth, raw, 0.32)
		var env: float = minf(1.0, t / 0.045) * minf(1.0, (duration - t) / 0.08)
		samples[i] = smooth * env * 0.65
	return _build_wav(samples)
