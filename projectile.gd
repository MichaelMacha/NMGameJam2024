extends CharacterBody2D

@export var speed := 60.0

func _ready():
	var enemies := $/root/World/Enemies
	
	# Don't try to set anything if we don't have any enemies to target
	if enemies.get_children().is_empty():
		return
	
	#Reduce from all enemies to closest enemy
	var target = $/root/World/Enemies.get_children().reduce(
		func(accum, child):
			var dist_squared = child.global_position.distance_squared_to(self.global_position)
			var accum_squared = accum.global_position.distance_squared_to(self.global_position)
			if dist_squared < accum_squared:
				return child
			else:
				return accum
	).global_position
	
	# Randomize an angle of at most PI/6.0 degrees, and skew our projectile by that.
	var d_angle := randf() * PI/3.0 - PI/6.0
	var direction : Vector2 = (target - global_position).normalized()
	direction = direction.rotated(d_angle)
	
	#Set our velocity to be our speed in the direction of the closest enemy
	velocity = speed * direction

# Just proceed along vector; can be overridden for derived projectiles to do
# something more complicated
func _physics_process(_delta: float) -> void:
	move_and_slide()

# Cause injury on impact, and clear out of object queue
func _on_harm_area_body_entered(body: Node2D) -> void:
	print("Harming: ", body.name)
	body.hurt((self.global_position - body.global_position).normalized())
	queue_free()

# Don't leave a projectile flying off forever. (Probably not a big deal either
# way, though.)
func _on_lifetime_timeout() -> void:
	queue_free()
