extends Node

enum CellState { EMPTY, FILLED, BLOCKED }

@onready var board := $NonogramBoard
@onready var back_button := $BackButton
@onready var board_panel := $NonogramBoard/Panel
@onready var aspect := board_panel.get_node("MarginContainer/AspectRatioContainer")
@onready var TITLE_SCENE := "res://ui/level_select.tscn"
@onready var grid_container := $NonogramBoard/Panel/MarginContainer/AspectRatioContainer/GridContainer

var cell_scene := preload("res://ui/nonogram_cell.tscn")

var solution : Array = []  # stores rows as arrays of ints
var grid_size : int = 0 # assumes square grids

func _ready():
	back_button.pressed.connect(_on_back_pressed)

func _on_back_pressed():
	get_tree().change_scene_to_file(TITLE_SCENE)

func load_level(file_path: String):
	var file := FileAccess.open(file_path, FileAccess.ModeFlags.READ)
	if file == null:
		push_error("Could not open level file: %s" % file_path)
		return

	var text := file.get_as_text()
	file.close()

	# Split by lines and convert each line to an array of ints
	solution.clear()
	for line in text.split("\n", false):
		line = line.strip_edges()
		if line == "":
			continue
		var row := []
		for c in line:
			row.append(int(c))
		solution.append(row)

	grid_size = solution.size()
	
	# draw grid after the layout is finalized so the aspect ratio container has a size
	call_deferred("_draw_grid")

func _draw_grid():
	var line_container = aspect.get_node("LineContainer")
	
	for child in line_container.get_children():
		child.queue_free()

	var cell_size := 1.0 / grid_size # the fraction of the total square for each cell

	for i in range(1, grid_size):
		# vertical line
		var line_v := Line2D.new()
		line_v.width = 1
		line_v.default_color = Color("#40156d")
		line_v.add_point(Vector2(i * cell_size, 0) * aspect.size)
		line_v.add_point(Vector2(i * cell_size, 1) * aspect.size)
		line_container.add_child(line_v)

		# horizontal line
		var line_h := Line2D.new()
		line_h.width = 1
		line_h.default_color = Color("#40156d")
		line_h.add_point(Vector2(0, i * cell_size) * aspect.size)
		line_h.add_point(Vector2(1, i * cell_size) * aspect.size)
		line_container.add_child(line_h)
	
	build_grid()

func build_grid():
	# Clear old cells
	for child in grid_container.get_children():
		child.queue_free()

	grid_container.columns = grid_size

	for y in range(grid_size):
		for x in range(grid_size):
			var cell = cell_scene.instantiate()
			cell.set_state(CellState.EMPTY)
			
			# make the cell fill the space allocated by the GridContainer
			cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			cell.size_flags_vertical = Control.SIZE_EXPAND_FILL
			grid_container.add_child(cell)

func draw_hints():
	grid_size = solution.size()
	var cell_size = 1.0 / grid_size
	
	for i in range(grid_size):
		# create the ith column
		var col = VBoxContainer.new()
		col.position = Vector2(i * cell_size * board.size(), 0)
		
		# make the column expand upwards
		# col.set_grow_vertical(GROW_DIRECTION_BEGIN)
