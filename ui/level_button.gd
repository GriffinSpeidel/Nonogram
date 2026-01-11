extends Button

signal level_selected(level_file: String)

@export var level_file: String

func _ready():
	pressed.connect(_on_pressed)

func setup(file_name: String):
	level_file = file_name
	text = prettify_level_name(file_name)

func _on_pressed():
	level_selected.emit(level_file)

func prettify_level_name(file_name: String) -> String:
	var name := file_name.get_basename()
	name = name.replace("_", " ")
	return name.capitalize()
