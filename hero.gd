class_name Hero extends CharacterBody2D

@onready var ui : UI 
@onready var invulnerability: Timer = $Invulnerability

@export var movement_speed := 80.0
@export var max_hearts := 4
@export var hearts := 3:
	set(value):
		hearts = value
		
		#Ensure we don't go below zero or above our maximum
		hearts = clampi(hearts, 0, max_hearts - 1)
		
		#BUG: This seems to occasionally reach 5, shouldn't go above 4
		if ui:
			ui.update_hearts(value)

@export_category("Weapon Stuff")
@export var maximum_projectiles := 4

## Our hero's attack power level. As this goes up, new attacks are unlocked.
@export var power_level := 0:
	set(value):
		power_level = value
		
		for i in $/root/World/Music.stream.stream_count:
			var stream : AudioStream = $/root/World/Music.stream.get_sync_stream(i)
			if stream:
				if i <= power_level:
					$/root/World/Music.stream.set_sync_stream_volume(i, 0)
				else:
					$/root/World/Music.stream.set_sync_stream_volume(i, -60)
			
		
		# Throwing this into a setter is a little sloppy, but lacking time for
		# variability, it should cover all cases here.
		if value >= 2:
			$Rotary.visible = true
			$Rotary.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			$Rotary.visible = false
			$Rotary.process_mode = Node.PROCESS_MODE_DISABLED

@export_category("Recoil Settings")
@export var recoil_distance_base := 25.0
@export var recoil_time := 0.25

@export_category("Music Settings")
## Number of beats to wait before triggering attack one
@export var attack1_beat_count := 4
## Same, but for attack two
@export var attack2_beat_count := 2

@export var vulnerable := true

# We're having some trouble with using a timer here. Timers apparently can't
# be relied on for < 0.5 second intervals. So, consider keeping a record of
# the next attack, in seconds, and implementing it in _physics_process, which
# should be much more reliable.
var next_attack1 := 0.0
var last_attack1 := 0.0
var next_attack2 := 0.0
var last_attack2 := 0.0

func _ready() -> void:
	ui = $/root/World/UI
	
	# A number of elements are best set here, to call their set/get
	# functionality with their initial value. It's a known but pretty minor
	# quirk of Godot.
	hearts = hearts
	power_level = power_level

func _process(_delta: float) -> void:
	## Get our velocity axis
	velocity = \
		Input.get_vector("left", "right", "up", "down") \
		.normalized() \
		* movement_speed
	
	move_and_slide()
	
	#Update sprite flip to movement direction
	#if velocity:
		#$Sprite2D.flip_h = (sign(velocity.x) == -1)

func _physics_process(_delta: float) -> void:
	var seconds := Time.get_ticks_msec()/1000.0
	
	#NOTE: These conditionals could be simplified into a function...
	if seconds > next_attack1:
		last_attack1 = seconds
		update_next_attack1_time()
		
		# Just here for consistency...
		if power_level >= 0:
			attack1()
	
	if seconds > next_attack2:
		last_attack2 = seconds
		update_next_attack2_time()
		
		if power_level >= 1:
			attack2()
		
		#From level 3, increase number of projectiles up to max_projectiles
		if power_level >= 3:
			for i in range(3, min(power_level, maximum_projectiles + 3)):
				attack2()
	
	# Ugly, but 48-hour functional
	if velocity:
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x > 0.1:
				$AnimationPlayer.play(&"walk right")
			elif velocity.x < -0.1:
				$AnimationPlayer.play(&"walk left")
			#$AnimationPlayer.play(&"walk horiz")
		else:
			if velocity.y < -0.1:
				$AnimationPlayer.play(&"walk up")
			else:
				$AnimationPlayer.play(&"walk down")

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
	if vulnerable:
		hearts -= 1
		MusicManager.bpm -= 5
		
		make_invulnerable()
		
		if hearts <= 0:
			GameManager.hero_alive = false
			die()
		else:
			recoil(-normal)

func make_invulnerable() -> void:
	vulnerable = false
	invulnerability.start()

func die() -> void:
	MusicManager.bpm = MusicManager.BASE_BPM
	ui.get_node("Main/Game Over").reveal()
	ui.get_node("Main/HBoxContainer/Heart Beat/Control/Heart").visible = false
	queue_free()

## Bounce the character backwards from the impact
func recoil(direction : Vector2) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(
		self,
		"position",
		global_position + direction * recoil_distance_base,
		recoil_time)

# Increase our power. Keep this simple for now.
func powerup() -> void:
	print("Power Up")
	power_level += 1

func _on_invulnerability_timeout() -> void:
	vulnerable = true
