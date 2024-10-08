extends MarginContainer
@onready var animPlayer = $AnimationPlayer

var default_window_mode : int
var default_window_size : Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	default_window_mode = DisplayServer.window_get_mode()
	default_window_size = DisplayServer.window_get_size()
	
	animPlayer.play("options-pulse");


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0,linear_to_db(value/100));

func _on_mute_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0,toggled_on);


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn");


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)# if toggled_on else DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);
	else:
		DisplayServer.window_set_mode(default_window_mode)
		DisplayServer.window_set_size(default_window_size)
