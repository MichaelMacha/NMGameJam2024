class_name Rotary extends Node2D

@export var beats_per_cycle := 8

func _physics_process(delta: float) -> void:
	$Origin.rotation += delta * 2.0 * PI / (beats_per_cycle * (60.0 / MusicManager.bpm))

func _on_shield_body_entered(body: Node2D) -> void:
	# We can assume that the body is an Enemy on the basis of the collision
	# mask.
	
	body.hurt((self.global_position - body.global_position).normalized())
