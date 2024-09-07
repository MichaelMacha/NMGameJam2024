class_name HealthPickup extends Area2D

func _on_body_entered(body: Node2D) -> void:
	print("Health Up")
	body.hearts += 1
	queue_free()
