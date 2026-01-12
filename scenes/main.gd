extends Control

enum CellState { EMPTY, FILLED, BLOCKED }

@onready var board := $NonogramBoard
@onready var col_clues := $NonogramBoard/ColumnClueArea/HBoxContainer
@onready var row_clues := $NonogramBoard/RowClueArea/VBoxContainer
@onready var back_button := $BackButton
@onready var check_button := $CheckButton
@onready var board_panel := $NonogramBoard/Panel
@onready var aspect := board_panel.get_node("MarginContainer/AspectRatioContainer")
@onready var TITLE_SCENE := "res://ui/level_select.tscn"
@onready var grid_container := $NonogramBoard/Panel/MarginContainer/AspectRatioContainer/GridContainer

var cell_scene := preload("res://ui/nonogram_cell.tscn")
var success_scene := preload("res://ui/success_popup.tscn")
var failure_scene := preload("res://ui/failure_popup.tscn")

var solution : Array = []  # stores rows as arrays of ints
var grid_size : int = 0 # assumes square grids

func _ready():
	back_button.pressed.connect(_on_back_pressed)
	check_button.pressed.connect(_on_check_pressed)

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
	call_deferred("_build_grid")
	call_deferred("_draw_hints")

func _build_grid():
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

func _draw_hints():
	# clear old hints
	for child in col_clues.get_children():
		child.queue_free()

	for child in row_clues.get_children():
		child.queue_free()

	grid_size = solution.size()
	var cell_size = aspect.size.x / grid_size * 0.75
	
	for i in range(grid_size):
		# create the ith column
		var col = VBoxContainer.new()
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col.size_flags_vertical = Control.SIZE_FILL
		col.alignment = BoxContainer.ALIGNMENT_END
		
		# add clues from the solution
		var empty_clue = true
		var region_size = 0
		# look down the ith column in the solution grid
		for k in range(grid_size):
			var soln_value = solution[k][i]
			if soln_value == 1:
				empty_clue = false
				region_size += 1
			else:
				if region_size > 0:
					# add the appropriate clue
					add_hint(col, region_size, cell_size)
					region_size = 0
		# if it reached the end and still has a nonzero region size pending, add that clue
		if region_size > 0:
			add_hint(col, region_size, cell_size)
		# if no cell is filled, set the clue to 0
		if empty_clue:
			add_hint(col, 0, cell_size)
		
		# add the column to the HBoxContainer for ColumnClueArea
		col_clues.add_child(col)
		
		# create the ith row
		var row = HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_FILL
		row.size_flags_vertical = Control.SIZE_EXPAND_FILL
		
		empty_clue = true
		region_size = 0
		
		for k in range(grid_size):
			var soln_value = solution[i][k]
			if soln_value == 1:
				empty_clue = false
				region_size += 1
			else:
				if region_size > 0:
					# add the appropriate clue
					add_hint(row, region_size, cell_size)
					region_size = 0
		# if it reached the end and still has a nonzero region size pending, add that clue
		if region_size > 0:
			add_hint(row, region_size, cell_size)
		# if no cell is filled, set the clue to 0
		if empty_clue:
			add_hint(row, 0, cell_size)
		
		row_clues.add_child(row)

func add_hint(container: Container, value: int, size: int):
	var label = Label.new()
	label.text = str(value)
	label.add_theme_color_override("font_color", Color("#40156d"))
	label.add_theme_font_size_override("font_size", size)
	
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	label.clip_text = true
	
	container.add_child(label)

func _on_check_pressed():
	# set variables that will track iteration through solution matrix
	var x = 0
	var y = 0
	
	# initialized to true, set to false if a mismatch is found
	var correct = true
	
	for cell in grid_container.get_children():
		if cell is NonogramCell:
			if solution[y][x] != cell.get_state():
				correct = false
				break
			else:
				# increment x and y, wrapping around rows if necessary
				x += 1
				if x >= grid_size:
					y += 1
					x = 0
	
	var popup = success_scene.instantiate() if correct else failure_scene.instantiate()
	popup.position = Vector2(57, 217)
	add_child(popup)
