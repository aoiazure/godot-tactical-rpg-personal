class_name Tile 
extends Node2D

enum TILE_TYPE { Normal, Path, Water }
enum MOVE_TYPE { Infantry, Armor, Flier, Cavalry }


var grid = preload("res://Grid.gd")


# Holds grid_position of self
var grid_position: Vector2

var tile_type: int

const MAX_VALUE = 999999

func _init(pos:Vector2=Vector2.ZERO, index:int=0):
	self.grid_position = pos
	self.tile_type = match_index_to_type(index)

func match_index_to_type(index:int) -> int:
	var t: int
	match index:
		0:
			t = TILE_TYPE.Normal
		1:
			t = TILE_TYPE.Path
		2:
			t = TILE_TYPE.Water
		_:
			t = TILE_TYPE.Normal
	return t

func get_tile_difficulty(movement_type:int=0):
	match tile_type:
		TILE_TYPE.Normal:
			if movement_type == MOVE_TYPE.Flier:
				return 1
			else: 
				return 2
		TILE_TYPE.Path:
			if movement_type == MOVE_TYPE.Flier:
				return 1
			else:
				return 1
		TILE_TYPE.Water:
			if movement_type == MOVE_TYPE.Flier:
				return 1
			else:
				return MAX_VALUE
		_: 
			return MAX_VALUE
