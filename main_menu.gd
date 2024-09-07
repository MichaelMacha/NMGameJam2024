extends MarginContainer
@onready var animPlayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animPlayer.play("main-pulse");


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://world.tscn");
	pass;


func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://options_menu.tscn");
	pass;

func _on_exit_button_pressed() -> void:
	get_tree().quit();
