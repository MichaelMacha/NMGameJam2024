class_name PowerUp extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# We know that the node is a hero on the basis of the collision mask
	body.powerup()
	queue_free()
