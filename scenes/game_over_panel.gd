class_name GameOverPanel extends MarginContainer

var press_any_key := false

func reveal() -> void:
	self.visible = true
	$PressAnyKeyTimer.start()

func _on_press_any_key_timer_timeout() -> void:
	$"PanelContainer/VBoxContainer/Press Any Key".visible = true
	press_any_key = true
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventJoypadButton:
		#Half-assed, do something better if you come back to this.
		if press_any_key:
			get_tree().change_scene_to_file("res://main_menu.tscn")
			#get_tree().change_scene_to_file("res://world.tscn")
