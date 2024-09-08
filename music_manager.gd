extends Node

##Base BPM of music
const BASE_BPM = 120.0
const MAX_BPM = 190.0 #240.0

@onready var hero : Hero:
	get():
		if get_tree().root.has_node("/root/World/Hero"):
			return $/root/World/Hero
		return null
@onready var music : AudioStreamPlayer:
	get():
		if get_tree().root.has_node("/root/World/Music"):
			return $/root/World/Music
		return null
@onready var pitch_shift := AudioServer.get_bus_effect(1, 0)

@export var bpm = BASE_BPM:
	set(value):
		bpm = value
		bpm = clampf(bpm, 0, MAX_BPM)
		
		GameManager.update_engine_speed()
		
		update_display_bpm()
		
		if hero:
			hero.update_next_attack1_time()
			hero.update_next_attack2_time()
		
		update_tempo()
		
		# See if we've reached critical BPM and won
		if bpm == MAX_BPM:
			GameManager.win()
	get():
		return bpm

func _ready() -> void:
	if get_tree().root.has_node("/root/World/Hero"):
		hero = $/root/World/Hero
	if get_tree().root.has_node("/root/World/Music"):
		music = $/root/World/Music
	
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
	if music:
		music.pitch_scale = (bpm / BASE_BPM)
		pitch_shift.pitch_scale = (BASE_BPM / bpm)

func update_display_bpm() -> void:
	if get_tree().root.has_node("/root/World/UI/Main/HBoxContainer/BPM Label"):
		$"/root/World/UI/Main/HBoxContainer/BPM Label".text = str(bpm, " BPM")


	
