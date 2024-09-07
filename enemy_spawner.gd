class_name EnemySpawner extends Node

# Since we're committing to 640 x 360, we can just keep these as constants.
const WIDTH = 640
const HEIGHT = 360

@onready var camera := $/root/World/Camera2D
@onready var viewport = get_viewport()
@onready var screen_transform := \
	(viewport.get_screen_transform() * 
	viewport.get_canvas_transform()).affine_inverse()

@export var beat_count := 8
@export var spawn_quantity := 5
@export var enemy_scene : PackedScene

var next_spawn := 0.0
var last_spawn := 0.0

func update_next_spawn() -> void:
	next_spawn = last_spawn + beat_count * 60.0 / MusicManager.bpm

func _physics_process(_delta: float) -> void:
	#Don't spawn in an enemy if it doesn't have a hero to chase.
	if not GameManager.hero_alive:
		return
		
	var seconds = Time.get_ticks_msec()/1000.0
	
	if seconds > next_spawn:
		last_spawn = seconds
		update_next_spawn()
		
		#Spawn in new enemies
		for i in spawn_quantity:
			var enemy = enemy_scene.instantiate()
			$/root/World/Enemies.add_child(enemy)
			#get_tree().root.add_child(enemy)
			
			# The best way to distribute the spawn point, to keep things even,
			# would be to double the width and height, add them together, and
			# choose a random integer from within that. Then, do a match on it
			# for which edge to spawn from. However, this may take time and
			# conceptual explanation which we don't have for a 48-hour jam.
			# (Consider coming back to it.)
			
			# Instead, let's go with something simple and just pick a random
			# side.
			match(randi() % 4):
				0:
					enemy.global_position = \
						random_point_top()
				1:
					enemy.global_position = \
						random_point_bottom()
				2:
					enemy.global_position = \
						random_point_left()
				3:
					enemy.global_position = \
						random_point_right()

@warning_ignore("integer_division")
func random_point_top() -> Vector2:
	return camera.global_position + Vector2(randi() % WIDTH, -20) - Vector2(WIDTH/2, HEIGHT/2)

@warning_ignore("integer_division")
func random_point_bottom() -> Vector2:
	return camera.global_position + Vector2(randi() % WIDTH, HEIGHT + 20) - Vector2(WIDTH/2, HEIGHT/2)

@warning_ignore("integer_division")
func random_point_left() -> Vector2:
	return camera.global_position + Vector2(-20, randi() % HEIGHT) - Vector2(WIDTH/2, HEIGHT/2)

@warning_ignore("integer_division")
func random_point_right() -> Vector2:
	return camera.global_position + Vector2(WIDTH + 20, randi() % HEIGHT) - Vector2(WIDTH/2, HEIGHT/2)
