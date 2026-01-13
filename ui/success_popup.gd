extends Control

@onready var TITLE_SCENE := "res://ui/level_select.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect/BackButton.pressed.connect(_on_back_pressed)

func _on_back_pressed():
	get_tree().change_scene_to_file(TITLE_SCENE)
	self.queue_free()
