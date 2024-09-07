extends MarginContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0,value);
	
	


func _on_mute_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0,toggled_on);


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn");
