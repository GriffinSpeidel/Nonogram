extends Button

signal level_selected(level_file: String)

# referenced by other nodes to get the level that this button refers to
@export var level_file: String

func _ready():
	pressed.connect(_on_pressed)

# code snippets trimmed/adapted from ChatGPT response to "I want to create a vertically scrolling list of level names (taken from file names). When the player clicks on a level, it should then load the scene for that level"

func setup(file_name: String):
	level_file = file_name
	text = prettify_level_name(file_name)

func _on_pressed():
	level_selected.emit(level_file)

func prettify_level_name(file_name: String) -> String:
	var name := file_name.get_basename()
	name = name.replace("_", " ")
	return name.capitalize()
