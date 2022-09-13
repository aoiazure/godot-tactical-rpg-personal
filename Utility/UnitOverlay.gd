class_name UnitOverlay
extends TileMap

var debug = false

func draw(cells: Array) -> void:
	clear()
	for cell in cells:
		set_cellv(cell, 0)
		
		if debug:
			var tile_pos = map_to_world(cell) + cell_size/2	
			var l = Label.new()
			l.name = str(cell)
			l.text = str(cell)
			get_tree().current_scene.get_node("Control").add_child(l)
			l.set_position(tile_pos)
