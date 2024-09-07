class_name UI extends CanvasLayer

var heart_scene := preload("res://scenes/heart.tscn")

func update_hearts(hearts : int) -> void:
	var hearts_box := $Main/Hearts
	
	for child in hearts_box.get_children():
		child.queue_free()
	
	for h in hearts:
		var heart := heart_scene.instantiate()
		hearts_box.add_child(heart)
