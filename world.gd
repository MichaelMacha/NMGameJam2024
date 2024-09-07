extends Node2D

func _ready() -> void:
	#Ensure that when we reload, we get acceptable enemy spawning behavior
	GameManager.hero_alive = true
	MusicManager.bpm = MusicManager.BASE_BPM
