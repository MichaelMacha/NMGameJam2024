extends Node

##Base BPM of music
const BASE_BPM = 120.0

@onready var hero := $/root/World/Hero
@onready var music := $/root/World/Music
@onready var pitch_shift := AudioServer.get_bus_effect(1, 0)

@export var bpm = BASE_BPM:
	set(value):
		bpm = value
		hero.update_next_attack_time()
		update_tempo()
	get():
		return bpm

func _ready() -> void:
	#initial BPM is currently 120, but that's adjustable with this field.
	bpm = bpm

func update_tempo() -> void:
	# This trick involves the difference between pitch_scale for an audio
	# playback stream, and pitch_scale for an actual pitch shifting effect.
	# Pitch scale for a playback will affect time, but a pitch shift
	# effect's pitch scale will only affect pitch.
	#
	# Therefore, to speed up music without (overly) distorting its sound,
	# we must adjust the pitch shift in the opposite direction of the
	# playback's pitch scale, by a proportionate (inverted) amount.
	#
	# This will change the absolute tempo, while avoiding distorting the
	# audio to match it.
	music.pitch_scale = (bpm / BASE_BPM)
	pitch_shift.pitch_scale = (BASE_BPM / bpm)
