class_name Grid
extends Resource

export var size := Vector2(20, 20)
export var cell_size := Vector2(64, 64)

var _half_cell_size = cell_size / 2


# get center of a tile in pixels to center units
func calculate_map_position(grid_position: Vector2) -> Vector2:
	return grid_position * cell_size + _half_cell_size

# get grid coords from map position
func calculate_grid_coordinates(map_position: Vector2) -> Vector2:
	return (map_position / cell_size).floor()

# keep cursor inside bounds
func is_within_bounds(cell_coordinates: Vector2) -> bool:
	var out_x := cell_coordinates.x >= 0 and cell_coordinates.x < size.x
	var out_y := cell_coordinates.y >= 0 and cell_coordinates.y < size.y
	return out_x and out_y

# Makes the `grid_position` fit within the grid's bounds.
# This is a clamp function designed specifically for our grid coordinates.
func clamp(grid_position: Vector2) -> Vector2:
	var out := grid_position
	out.x = clamp(out.x, 0, size.x - 1.0)
	out.y = clamp(out.y, 0, size.y - 1.0)
	return out

# Given Vector2 coordinates, calculates and returns the corresponding integer index. You can use
# this function to convert 2D coordinates to a 1D array's indices.
#
# There are two cases where you need to convert coordinates like so:
# 1. We'll need it for the AStar algorithm, which requires a unique index for each point on the
# graph it uses to find a path.
# 2. You can use it for performance. More on that below.
func as_index(cell: Vector2) -> int:
	return int(cell.x + size.x * cell.y)

#










