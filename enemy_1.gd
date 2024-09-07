class_name Enemy extends CharacterBody2D

@export var hearts := 3
@export var movement_speed := 40.0

@onready var hero = $/root/World/Hero

@export_category("Recoil Settings")
@export var recoil_distance_base := 25.0
@export var recoil_time := 0.25

func _physics_process(_delta: float) -> void:
	if is_instance_valid(hero):
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
	var hero_ : Hero = body
	hero_.hurt((self.global_position - body.global_position).normalized())

#TODO: hurt and recoil seem almost identical. If they stay identical, then they
#should go into a base class inherited by both Hero and Enemy.

func hurt(normal : Vector2) -> void:
	hearts -= 1
	if hearts <= 0:
		queue_free()
	else:
		recoil(-normal)

func recoil(direction : Vector2) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(self, "position", global_position + direction * recoil_distance_base, recoil_time)
