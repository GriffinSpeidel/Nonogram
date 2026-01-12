class_name NonogramCell extends Control

# States
enum CellState { EMPTY, FILLED, BLOCKED }

var state = CellState.FILLED

# Colors
var empty_color: Color = Color(1,1,1,0)
var filled_color: Color = Color("#294acf")
var blocked_color: Color = Color(1,1,1,0)
var blocked_line_color: Color = Color("#960f38")
var blocked_line_width: float = 2.0
var grid_color: Color = Color("#40156d")

func _ready():
	# Enable mouse button events
	mouse_filter = Control.MouseFilter.MOUSE_FILTER_STOP

func set_state(new_state: CellState) -> void:
	state = new_state
	queue_redraw()

func get_state() -> int:
	if state == CellState.FILLED:
		return 1
	else:
		return 0

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if state != CellState.BLOCKED:
				# toggle empty/filled
				set_state(CellState.FILLED if state == CellState.EMPTY else CellState.EMPTY)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			# toggle block/unblock
			if state == CellState.BLOCKED:
				set_state(CellState.EMPTY)
			elif state == CellState.EMPTY:
				set_state(CellState.BLOCKED)

func _draw():
	# Draw fill color
	match state:
		CellState.EMPTY:
			draw_rect(Rect2(Vector2.ZERO, size), empty_color)
		CellState.FILLED:
			draw_rect(Rect2(Vector2.ZERO, size), filled_color)
		CellState.BLOCKED:
			draw_rect(Rect2(Vector2.ZERO, size), blocked_color)
			# Draw X
			draw_line(Vector2(0,0), Vector2(size.x, size.y), blocked_line_color, blocked_line_width)
			draw_line(Vector2(0,size.y), Vector2(size.x,0), blocked_line_color, blocked_line_width)
	
	# draw the cell border
	draw_rect(Rect2(Vector2.ZERO, size), grid_color, false, 2)
