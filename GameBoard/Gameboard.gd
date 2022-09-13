class_name Gameboard
extends Node2D

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

export(NodePath) var map_tiles_path
var map_tiles: Map

export var grid: Resource = preload("res://Grid.tres")
onready var _unit_overlay: UnitOverlay = $UnitOverlay

var _units := {}

var _active_unit: Unit
var _walkable_cells := []

onready var _unit_path: UnitPath = $UnitPath

func _ready():
	map_tiles = get_node(map_tiles_path)
	_reinitialize()

func is_occupied(cell: Vector2) -> bool:
	return true if _units.has(cell) else false

func _reinitialize() -> void:
	_units.clear()

	for child in get_children():
		var unit := child as Unit
		if not unit:
			continue
		_units[unit.cell] = unit

# Get walkable cells within selected unit's move range
func get_walkable_cells(unit: Unit) -> Array:
	var wc = _flood_fill(unit.cell, unit.move_range, unit.movement_type)
	return wc


func _flood_fill(cell: Vector2, max_distance: int, movement_type: int) -> Array:
	var array := []
	var visited_weights := {}
	### Take given cell and fill from there
	# get current tile in tilemap at this position

	var wt = max(map_tiles.get_tile_difficulty(cell, movement_type), 1)
	var current_distance := 0

	var stack := [ [cell, 0, current_distance] ]

	# Start flood filling
	while not stack.empty():
		var c = stack.pop_back()
		var current = c[0] 		# cell pos
		var cell_weight = c[1] 	# cell weight
		var cell_dist = c[2]	# distance from starting pos


		# # Get Manhattan distance of the current cell from the initial
		# var _difference: Vector2 = (current - cell).abs()
		# var _diff := int(_difference.x + _difference.y + cell_weight)
		# var distance := min(_diff, int(cell_dist + cell_weight))
		var distance := int(cell_dist + cell_weight)
		
		# If can walk on it
		
		# OR if its out of the grid, don't put it on
		if not grid.is_within_bounds(current):
			continue
		# OR if its already on the stack, don't put it on again
		if current in array:
			if visited_weights[str(current)] < distance:
				continue

		# if the current cell is more than or equal to `max_distance` away, move on from it 
		if distance > max_distance:
			# print("discarding " + str(current) + " for its distance of " + str(distance))
			continue
		# Since it's within our range, put it on the final array
		if not current in array:
			array.append(current)
		
		# Then flood fill in each adjacent direction 
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			# check if a unit is there
			if is_occupied(coordinates):
				continue
			# OR if it's out of bounds
			if not grid.is_within_bounds(coordinates):
				continue

			# get current tile in tilemap at this position and its index
			wt = map_tiles.get_tile_difficulty(coordinates, movement_type)
			var _tile = [ coordinates, wt, distance ]
			
			# if already visited and saved distance,
			if visited_weights.has(str(coordinates)):
				# if the distance we would put on is bigger, skip it
				if visited_weights[str(coordinates)] < distance:
					continue
				# else the distance is smaller, so put it on
				else:
					# print(str(c) + " is putting on " + str(_tile) )
					stack.append(_tile)
			# else we have not visited, so set distance
			else:
				visited_weights[str(coordinates)] = distance
				# print(str(c) + " is putting on " + str(_tile) )
				stack.append(_tile)
	
	visited_weights.clear()
	# Finally, return our array of cells within range
	return array

func _select_unit(cell: Vector2) -> void:
	if not _units.has(cell):
		return
	
	var temp_unit: Unit = _units[cell]
	
	# if not an allied controllable unit
	if not temp_unit.is_player:
		return
	
	# set active_unit and it as selected
	_active_unit = temp_unit 
	_active_unit.is_selected = true
	# get and draw the walkable cells
	_walkable_cells = get_walkable_cells(_active_unit)
	_unit_overlay.draw(_walkable_cells)
	_unit_path.initialize(_walkable_cells, _active_unit.movement_type, map_tiles)

# 
func _deselect_active_unit() -> void:
	_active_unit.is_selected = false
	_unit_overlay.clear()
	_unit_path.stop()

# Clear out the active unit
func _clear_active_unit() -> void:
	_active_unit = null
	_walkable_cells.clear()

# Move Unit from its current cell to its new_cell
func _move_active_unit(new_cell: Vector2) -> void:
	# if cell is occupied OR it's out of range, don't move
	if is_occupied(new_cell) or not new_cell in _walkable_cells:
		return
	# In our cell list, remove old unit's position, then set its position to the new one 
	_units.erase(_active_unit.cell)
	_units[new_cell] = _active_unit
	# set the unit as not selected after it's moved
	_deselect_active_unit()
	# start walking it along its path UNTIL it emits its signal
	_active_unit.walk_along(_unit_path.current_path)
	yield(_active_unit, "walk_finished")
	
	_clear_active_unit()
	pass


#
func _on_Cursor_moved(new_cell: Vector2) -> void:
	if _active_unit and _active_unit.is_selected:
		_unit_path.draw(_active_unit.cell, new_cell)

#
func _on_Cursor_accept_pressed(cell: Vector2) -> void:
	if not _active_unit:
		_select_unit(cell)
	elif _active_unit.is_selected:
		_move_active_unit(cell)

#
func _unhandled_input(event: InputEvent) -> void:
	if _active_unit and event.is_action_pressed("ui_cancel"):
		_deselect_active_unit()
		_clear_active_unit()
