tool
class_name Unit
extends Path2D

signal walk_finished

export var grid: Resource = preload("res://Grid.tres")

# If unit can be controlled
export var is_player: bool = true
export(int, "Infantry", "Armor", "Flier", "Cavalry") var movement_type

export var move_range = 6
export var skin: Texture setget set_skin
export var skin_offset := Vector2.ZERO setget set_skin_offset
export var move_speed := 600.0

var cell := Vector2.ZERO setget set_cell
var is_selected := false setget set_is_selected
var _is_walking := false setget _set_is_walking

onready var _sprite: Sprite = $PathFollow2D/Sprite
onready var _anim_player: AnimationPlayer = $AnimationPlayer
onready var _path_follow: PathFollow2D = $PathFollow2D



# set cell for Grid
func set_cell(value: Vector2) -> void:
	cell = grid.clamp(value)

# set is_selected by cursor
func set_is_selected(value: bool) -> void:
	is_selected = value
	if is_selected:
		_anim_player.play("selected")
	else:
		_anim_player.play("idle")

# set the sprite
func set_skin(value: Texture) -> void:
	skin = value
	if not _sprite:
		yield(self, "ready")
	_sprite.texture = value
	# automatically position the sprite
	_sprite.position.y = -1*floor((_sprite.texture.get_height() * _sprite.scale.y) / 2)

# set the offset, if necessary
func set_skin_offset(value: Vector2) -> void:
	skin_offset = value
	if not _sprite:
		yield(self, "ready")
	_sprite.position = value

# set is_walking for processing and path movement
func _set_is_walking(value:bool) -> void:
	_is_walking = value
	set_process(_is_walking)

###
func _ready():
	# don't start doing line stuff til needed
	set_process(false)

	self.cell = grid.calculate_grid_coordinates(position)
	position = grid.calculate_map_position(cell)

	# change direction for enemies
	if not self.is_player:
		_sprite.scale.x *= -1

	if not Engine.editor_hint:
		curve = Curve2D.new()
		pass
		


### move along path if processing
func _process(delta):
	_path_follow.offset += move_speed * delta

	if _path_follow.unit_offset >= 1.0:
		self._is_walking = false
		_path_follow.offset = 0.0 
		position = grid.calculate_map_position(cell)
		curve.clear_points()

		emit_signal("walk_finished")

# walk along the path points
func walk_along(path: PoolVector2Array) -> void:
	if path.empty():
		return
	curve.add_point(Vector2.ZERO)
	for point in path:
		curve.add_point(grid.calculate_map_position(point) - position)
	
	cell = path[-1]
	self._is_walking = true
