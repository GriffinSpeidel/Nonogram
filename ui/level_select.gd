extends Control

@onready var vbox := $ScrollContainer/VBoxContainer

const LEVEL_DIR := "res://boards"
const LEVEL_BUTTON_SCENE := preload("res://ui/level_button.tscn")

func _ready():
	populate_level_list()

# functions taken from ChatGPT response to "I want to create a vertically scrolling list of level names (taken from file names). When the player clicks on a level, it should then load the scene for that level"

func populate_level_list():
	for child in vbox.get_children():
		child.queue_free()
	
	# code adapted from ChatGPT with prompt "I exported an exe and it launches fine but is unable to read from the levels directory. That folder is in the same directory as the exe"
	var boards_dir = "res://boards" if OS.has_feature("editor") else OS.get_executable_path().get_base_dir() + "/boards"
	
	var dir := DirAccess.open(boards_dir)
	if dir == null:
		push_error("Could not open level directory")
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".non"):
			add_level_button(file_name)
		file_name = dir.get_next()

	dir.list_dir_end()

func add_level_button(file_name: String):
	var level_button := LEVEL_BUTTON_SCENE.instantiate()
	level_button.setup(file_name)
	level_button.level_selected.connect(_on_level_selected)
	vbox.add_child(level_button)

func _on_level_selected(board_file: String):
	var main_scene := preload("res://scenes/main.tscn").instantiate()
	get_tree().root.add_child(main_scene)
	main_scene.load_level("res://boards/%s" % board_file)
	get_tree().current_scene = main_scene
	self.queue_free()
