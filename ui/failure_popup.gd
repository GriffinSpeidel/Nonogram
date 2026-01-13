extends Control

@onready var TITLE_SCENE := "res://ui/level_select.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect/RetryButton.pressed.connect(_on_retry_pressed)

func _on_retry_pressed():
	self.queue_free()
