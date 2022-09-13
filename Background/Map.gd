class_name Map
extends TileMap

var grid = preload("res://Grid.tres")

var tile_dict: Dictionary = {}

func _ready():
	populate_tiles()


func populate_tiles():
	var all_placed:Array = self.get_used_cells()
	for coord in all_placed:
		# points are grid coords e.g. (0, 0)
		var index: int = self.get_tile_index_at_grid(coord)
		var tile = Tile.new(coord, index)
		tile_dict[coord] = tile


func get_tile_index_at_grid(pos: Vector2) -> int:
	var tile: Vector2 = grid.calculate_map_position(pos)
	return self.get_cellv(self.world_to_map(tile))



func get_tile_difficulty(pos: Vector2, movement_type: int) -> float:
	if pos in tile_dict:
		return tile_dict[pos].get_tile_difficulty(movement_type)
	else:
		return INF
