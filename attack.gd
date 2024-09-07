extends Area2D

## On entrance of a body into the shape
func _on_body_entered(body: Node2D) -> void:
	print("Body collided: ", body)
	
	# We know that it's an enemy on the basis of the collision layer, so no
	# need to double check.
	var enemy : Enemy = body
	
	enemy.hurt((self.global_position - body.global_position).normalized())


## On fade timer elapse, remove from scene
func _on_timer_timeout() -> void:
	queue_free()
	pass # Replace with function body.
