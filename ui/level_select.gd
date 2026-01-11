extends Control

@onready var vbox := $ScrollContainer/VBoxContainer

const LEVEL_DIR := "res://boards"
const LEVEL_BUTTON_SCENE := preload("res://ui/level_button.tscn")

func _ready():
	populate_level_list()

func populate_level_list():
	for child in vbox.get_children():
		child.queue_free()

	var dir := DirAccess.open(LEVEL_DIR)
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

func _on_level_selected(level_file: String):
	print("Selected level:", level_file)
	# Future:
	# load_level(level_file)
