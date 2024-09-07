class_name Hero extends CharacterBody2D

@onready var music := $/root/World/Music

@export var movement_speed := 80.0
@export var hearts := 3

@export_category("Recoil Settings")
@export var recoil_distance_base := 25.0
@export var recoil_time := 0.25

@export_category("Music Settings")
## Number of beats to wait before triggering an attack
@export var beat_count := 4

##Base BPM of music
const BASE_BPM = 120.0

@export_category("Game Scoped Data")
@onready var pitch_shift := AudioServer.get_bus_effect(1, 0)

@export var bpm = BASE_BPM:
	set(value):
		bpm = value
		$AttackTimer.wait_time = beat_count * 60.0/bpm
		
		# This trick involves the difference between pitch_scale for an audio
		# playback stream, and pitch_scale for an actual pitch shifting effect.
		# Pitch scale for a playback will affect time, but a pitch shift
		# effect's pitch scale will only affect pitch.
		#
		# Therefore, to speed up music without (overly) distorting its pitch,
		# we must adjust the pitch shift in the opposite direction of the
		# playback's pitch scale, by a proportionate (inverted) amount.
		#
		# This will change the absolute BPM, while avoiding distorting the
		# audio to match it.
		music.pitch_scale = 1.0 * (bpm / BASE_BPM)
		pitch_shift.pitch_scale = 1.0 * (BASE_BPM / bpm)
		print(pitch_shift)
	get():
		return bpm

func _ready() -> void:
	#Set up initial BPM
	bpm = 120.0

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
	hearts -= 1
	if hearts <= 0:
		queue_free()
	
	print("Ow!")
	recoil(-normal)

## Bounce the character backwards from the impact
func recoil(direction : Vector2) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(self, "position", global_position + direction * recoil_distance_base, recoil_time)

## Attack every elapsation of AttackTimer. Vary the lenght of AttackTimer so
## that it keeps up with the BPM.
func _on_attack_timer_timeout() -> void:
	print("Attack")
	var attack := preload("res://attack.tscn").instantiate()
	get_tree().root.add_child(attack)
	attack.global_position = self.global_position
