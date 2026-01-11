extends Control

@onready var play_button := $PlayButton

const LEVEL_SELECT_SCENE := "res://ui/level_select.tscn"

func _ready():
	play_button.pressed.connect(_on_play_pressed)

func _on_play_pressed():
	get_tree().change_scene_to_file(LEVEL_SELECT_SCENE)
