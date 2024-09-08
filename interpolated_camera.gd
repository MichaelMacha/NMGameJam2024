extends Camera2D


@onready var track := $/root/World/Hero/CameraTrack
@export var max_speed := 5.0
@export var distance_strength := 500.0


func _process(_delta: float) -> void:
	if is_instance_valid(track):
		var d : Vector2 = track.global_position - self.global_position
		var speed : float = \
			lerp(0.0, max_speed, clampf(d.length()/distance_strength, 0.0, 1.0))
		self.position += d.normalized() * speed
		
		
