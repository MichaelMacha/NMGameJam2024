extends CharacterBody2D

@export var movement_speed := 20.0

@onready var hero = $/root/World/Hero

func _physics_process(delta: float) -> void:
	var direction = (hero.global_position - global_position).normalized()
	
	velocity = direction * movement_speed
	move_and_slide()
	
	#Update sprite orientation
	if velocity:
		$Sprite2D.flip_h = (sign(velocity.x) == -1)


func _on_hurt_box_body_entered(body: Node2D) -> void:
	print("COLLISION with ", body)
	
	#We know body is a hero on the basis of the collision layer, so there should
	#be no need to check.
	var hero : Hero = body
	hero.hurt((self.global_position - body.global_position).normalized())
	
	pass # Replace with function body.
