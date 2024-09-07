class_name Enemy extends CharacterBody2D

enum State {
	IDLE,
	WALK_DOWN,
	WALK_UP
}
var state : State:
	set(value):
		if state != value:
			state = value
			
			if value == State.WALK_DOWN:
				$AnimationPlayer.play(&"walk down")
			elif value == State.WALK_UP:
				$AnimationPlayer.play(&"walk up")
		

@export var hearts := 3
@export var movement_speed := 30.0

@onready var hero : Hero:
	get():
		return get_tree().root.get_node("/root/World/Hero")

@export_range(0.0, 1.0) var powerup_threshold = 0.2

## Amount to change the BPM by when enemy is killed
@export var bpm_change := 1.0

@export_category("Recoil Settings")
@export var recoil_distance_base := 25.0
@export var recoil_time := 0.25

var attacking := false

func _physics_process(_delta: float) -> void:
	if is_instance_valid(hero):
		var direction = (hero.global_position - global_position).normalized()
		
		velocity = direction * movement_speed
		move_and_slide()
	
	#Update sprite orientation and animation
	if velocity:
		#$Sprite2D.flip_h = (sign(velocity.x) == -1)
		
		if not attacking:
			if velocity.y < -0.1:
				state = State.WALK_UP
			elif velocity.y > 0.1:
				state = State.WALK_DOWN


func _on_hurt_box_body_entered(body: Node2D) -> void:
	print("COLLISION with ", body)
	
	#We know body is a hero on the basis of the collision layer, so there should
	#be no need to check.
	var hero_ : Hero = body
	hero_.hurt((self.global_position - body.global_position).normalized())
	
	#Update animation to play attack
	$AnimationPlayer.play(&"attack")
	attacking = true
	
	await get_tree().create_timer(0.5).timeout
	attacking = false

#TODO: hurt and recoil seem almost identical. If they stay identical, then they
#should go into a base class inherited by both Hero and Enemy.

func hurt(normal : Vector2) -> void:
	hearts -= 1
	if hearts <= 0:
		die()
	else:
		recoil(-normal)

func die() -> void:
	if randf() < powerup_threshold:
		var powerup : Node2D
		
		match randi() % 2:
			0:
				powerup = preload("res://powerup.tscn").instantiate()
			1:
				powerup = preload("res://health_pickup.tscn").instantiate()
		
		# Adding a child node needs to be deferred, and binding it to the powerup
		# determines what is added.
		$/root/World/Powerups.add_child.bind(powerup).call_deferred()
		
		powerup.global_position = self.global_position
	
	MusicManager.bpm += bpm_change
	
	queue_free()	

func recoil(direction : Vector2) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(self, "position", global_position + direction * recoil_distance_base, recoil_time)
