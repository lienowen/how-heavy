class_name GameAudioDirector
extends Node

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var sounds := {}

func _ready() -> void:
	sounds.trade_light = make_tone([330.0, 495.0, 660.0], 0.24, 0.34)
	sounds.trade_heavy = make_tone([180.0, 135.0, 90.0], 0.34, 0.5)
	sounds.checkpoint = make_tone([440.0, 554.0, 660.0], 0.32, 0.28)
	sounds.break_floor = make_noise_hit(0.42, 0.65)
	sounds.complete = make_tone([294.0, 392.0, 494.0, 587.0], 0.75, 0.3)
	sounds.failure = make_tone([220.0, 165.0, 110.0], 0.4, 0.28)
	for index in range(6):
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		sfx_players.append(player)
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	music_player.stream = make_ambient_loop()
	music_player.volume_db = -13.0
	add_child(music_player)
	music_player.play()

func _exit_tree() -> void:
	if is_instance_valid(music_player):
		music_player.stop()
		music_player.stream = null
	for player in sfx_players:
		if is_instance_valid(player):
			player.stop()
			player.stream = null
	sfx_players.clear()
	sounds.clear()

func play_named(sound_name: StringName) -> void:
	if not sounds.has(sound_name): return
	for player in sfx_players:
		if not player.playing:
			player.stream = sounds[sound_name]
			player.play()
			return
	sfx_players[0].stream = sounds[sound_name]
	sfx_players[0].play()

func make_tone(notes: Array, duration: float, gain: float) -> AudioStreamWAV:
	var rate := 22050
	var frames := int(duration * rate)
	var bytes := PackedByteArray()
	bytes.resize(frames * 2)
	for i in range(frames):
		var t := float(i) / rate
		var envelope := minf(1.0, t * 35.0) * pow(maxf(0.0, 1.0 - t / duration), 2.0)
		var segment := mini(int(t / duration * notes.size()), notes.size() - 1)
		var frequency: float = notes[segment]
		var sample := sin(TAU * frequency * t) + 0.28 * sin(TAU * frequency * 2.01 * t)
		bytes.encode_s16(i * 2, int(clampf(sample * envelope * gain, -1.0, 1.0) * 32767.0))
	return wav(bytes, rate, false)

func make_noise_hit(duration: float, gain: float) -> AudioStreamWAV:
	var rate := 22050
	var frames := int(duration * rate)
	var bytes := PackedByteArray()
	bytes.resize(frames * 2)
	var state := 18457
	for i in range(frames):
		state = int((state * 1103515245 + 12345) & 0x7fffffff)
		var noise := (float(state % 65536) / 32768.0) - 1.0
		var t := float(i) / rate
		var body := sin(TAU * 62.0 * t) * 0.7
		var envelope := pow(maxf(0.0, 1.0 - t / duration), 3.0)
		bytes.encode_s16(i * 2, int(clampf((noise * 0.35 + body) * envelope * gain, -1.0, 1.0) * 32767.0))
	return wav(bytes, rate, false)

func make_ambient_loop() -> AudioStreamWAV:
	var rate := 22050
	var duration := 6.0
	var frames := int(duration * rate)
	var bytes := PackedByteArray()
	bytes.resize(frames * 2)
	for i in range(frames):
		var t := float(i) / rate
		var breath := 0.62 + 0.38 * sin(TAU * t / duration)
		var sample := sin(TAU * 55.0 * t) * 0.22 + sin(TAU * 82.5 * t) * 0.1 + sin(TAU * 110.0 * t) * 0.05
		bytes.encode_s16(i * 2, int(sample * breath * 32767.0))
	return wav(bytes, rate, true)

func wav(bytes: PackedByteArray, rate: int, looped: bool) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.stereo = false
	stream.data = bytes
	if looped:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = bytes.size() / 2
	return stream
