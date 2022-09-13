class_name UnitPath
extends TileMap

export var grid: Resource

var _pathfinder: Pathfinder

var current_path := PoolVector2Array()

func initialize(walkable_cells: Array, movement_type:int, map_tiles:Map=null):
	if map_tiles:
		_pathfinder = Pathfinder.new(grid, walkable_cells, movement_type, map_tiles)
	else:
		_pathfinder = Pathfinder.new(grid, walkable_cells, movement_type)
	

func draw(cell_start: Vector2, cell_end: Vector2) -> void:
	clear()
	current_path = _pathfinder.calculate_point_path(cell_start, cell_end)

	for cell in current_path:
		set_cellv(cell, 0)
	
	update_bitmask_region()

# stop drawing, clear
func stop() -> void:
	_pathfinder = null
	clear()
