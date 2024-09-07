extends Node

@export var hero_alive := true

func update_engine_speed() -> void:
	Engine.time_scale = lerp(
		1.0,
		3.0,
		float(MusicManager.bpm - MusicManager.BASE_BPM)/(MusicManager.MAX_BPM - MusicManager.BASE_BPM))

func win() -> void:
	$"/root/World/UI/Main/You Win".visible = true
	$"/root/World/UI/Main/You Win/PressAnyKeyTimer".start()
	if $/root/World/Hero:
		$/root/World/Hero.queue_free()
	$/root/World/Music.stop()
	print("You Win")
