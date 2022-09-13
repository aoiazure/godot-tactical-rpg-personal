tool
class_name Cursor
extends Node2D


signal accept_pressed(cell)
signal moved(new_cell)

export var grid: Resource = preload("res://Grid.tres")

export var ui_cooldown := 0.1

var cell := Vector2.ZERO setget set_cell

onready var _timer: Timer = $Timer

func set_cell(value: Vector2) -> void:
	var new_cell: Vector2 = grid.clamp(value)
	if new_cell.is_equal_approx(cell):
		return
	cell = new_cell

	position = grid.calculate_map_position(cell)
	emit_signal("moved", cell)
	_timer.start()


func _ready():
	_timer.wait_time = ui_cooldown

func _unhandled_input(event: InputEvent) -> void:
	# If the user moves the mouse, we capture that input and update the node's cell in priority.
	if event is InputEventMouseMotion:
		self.cell = grid.calculate_grid_coordinates(event.position)
	# Try to interact while over a cell
	elif event.is_action_pressed("click") or event.is_action_pressed("ui_accept"):
		#  Emit a signal to let GameBoard handle it
		emit_signal("accept_pressed", cell)
		get_tree().set_input_as_handled()

	# The code below is for the cursor's movement.
	# The following lines make some preliminary checks to see whether the cursor should move or not
	# if the user presses an arrow key.
	var should_move := event.is_pressed()
	# If the player is pressing the key in this frame, we allow the cursor to move. If they keep the
	# keypress down, we only want to move after the cooldown timer stops.
	if event.is_echo():
		should_move = should_move and _timer.is_stopped()

	# And if the cursor shouldn't move, we prevent it from doing so.
	if not should_move:
		return

	# Here, we update the cursor's current cell based on the input direction.
	if event.is_action("ui_right"):
		self.cell += Vector2.RIGHT
	elif event.is_action("ui_up"):
		self.cell += Vector2.UP
	elif event.is_action("ui_left"):
		self.cell += Vector2.LEFT
	elif event.is_action("ui_down"):
		self.cell += Vector2.DOWN


# We use the draw callback to a rectangular outline the size of a grid cell, with a width of two
# pixels.
func _draw() -> void:
	# Rect2 is built from the position of the rectangle's top-left corner and its size. To draw the
	# square around the cell, the start position needs to be `-grid.cell_size / 2`.
	draw_rect(Rect2(-grid.cell_size / 2, grid.cell_size), Color.aliceblue, false, 2.0)
