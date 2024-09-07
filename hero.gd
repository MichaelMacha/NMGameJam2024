class_name Hero extends CharacterBody2D

@export var movement_speed := 80.0

@export_category("Recoil Settings")
@export var recoil_distance_base := 25.0
@export var recoil_time := 0.25

func _process(delta: float) -> void:
	## Get our velocity axis
	velocity = \
		Input.get_vector("left", "right", "up", "down") \
		.normalized() \
		* movement_speed
	
	move_and_slide()
	
	#Update sprite flip to movement direction
	if velocity:
		$Sprite2D.flip_h = (sign(velocity.x) == -1)

## Handle all behavior which relates to hero injury
func hurt(normal : Vector2) -> void:
	print("Ow!")
	recoil(-normal)

## Bounce the character backwards from the impact
func recoil(direction : Vector2) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(self, "position", global_position + direction * recoil_distance_base, recoil_time)
