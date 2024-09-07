class_name Hero extends CharacterBody2D

@onready var ui := $/root/World/UI

@export var movement_speed := 80.0
@export var hearts := 3:
	set(value):
		hearts = value
		ui.update_hearts(value)

@export_category("Recoil Settings")
@export var recoil_distance_base := 25.0
@export var recoil_time := 0.25

@export_category("Music Settings")
## Number of beats to wait before triggering attack one
@export var attack1_beat_count := 4
## Same, but for attack two
@export var attack2_beat_count := 2

# We're having some trouble with using a timer here. Timers apparently can't
# be relied on for < 0.5 second intervals. So, consider keeping a record of
# the next attack, in seconds, and implementing it in _physics_process, which
# should be much more reliable.
var next_attack1 := 0.0
var last_attack1 := 0.0
var next_attack2 := 0.0
var last_attack2 := 0.0

func _ready() -> void:
	# A number of elements are best set here, to call their set/get
	# functionality with their initial value. It's a known but pretty minor
	# quirk of Godot.
	hearts = hearts
	
	##initial BPM is currently 120, but that's adjustable with this field.
	#bpm = bpm

func _process(_delta: float) -> void:
	## Get our velocity axis
	velocity = \
		Input.get_vector("left", "right", "up", "down") \
		.normalized() \
		* movement_speed
	
	move_and_slide()
	
	#Update sprite flip to movement direction
	if velocity:
		$Sprite2D.flip_h = (sign(velocity.x) == -1)

func _physics_process(_delta: float) -> void:
	var seconds := Time.get_ticks_msec()/1000.0
	
	if seconds > next_attack1:
		last_attack1 = seconds
		update_next_attack1_time()
		
		attack1()
	
	if seconds > next_attack2:
		last_attack2 = seconds
		update_next_attack2_time()
		
		attack2()

func update_next_attack1_time() -> void:
	next_attack1 = last_attack1 + attack1_beat_count * 60.0 / MusicManager.bpm

func update_next_attack2_time() -> void:
	next_attack2 = last_attack2 + attack2_beat_count * 60.0 / MusicManager.bpm
	
#Basic attack
func attack1():
	var attack := preload("res://attack.tscn").instantiate()
	get_tree().root.add_child(attack)
	attack.global_position = self.global_position

#Projectile attack
func attack2():
	var attack := preload("res://projectile.tscn").instantiate()
	
	#Projectile should seek out closest enemy
	#attack.velocity = Vector2.RIGHT * 20.0 + self.velocity
	
	attack.global_position = self.global_position
	get_tree().root.add_child(attack)

## Handle all behavior which relates to hero injury
func hurt(normal : Vector2) -> void:
	hearts -= 1
	if hearts <= 0:
		GameManager.hero_alive = false
		queue_free()
	else:
		recoil(-normal)

## Bounce the character backwards from the impact
func recoil(direction : Vector2) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(
		self,
		"position",
		global_position + direction * recoil_distance_base,
		recoil_time)
