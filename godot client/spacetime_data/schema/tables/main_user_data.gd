#Do not edit this file, it is generated automatically.
class_name MainUserData extends _ModuleTable

const table_names: Array[String] = ['user_data']

@export var identity: PackedByteArray
@export var online: bool
@export var name: String
@export var lobby_id: int
@export var color: Color
@export var test_vec: Array[String]
@export var test_bytes_array: Array[int]
@export var last_position: Vector3
@export var direction: Vector2
@export var player_speed: float
@export var last_update: int

func _init():
	set_meta('primary_key', 'identity')
	set_meta('bsatn_type_identity', &'identity')
	set_meta('bsatn_type_online', &'bool')
	set_meta('bsatn_type_name', &'string')
	set_meta('bsatn_type_lobby_id', &'u64')
	set_meta('bsatn_type_test_vec', &'string')
	set_meta('bsatn_type_test_bytes_array', &'u8')
	set_meta('bsatn_type_player_speed', &'f32')
	set_meta('bsatn_type_last_update', &'i64')

static func create(_identity: PackedByteArray, _online: bool, _name: String, _lobby_id: int, _color: Color, _test_vec: Array[String], _test_bytes_array: Array[int], _last_position: Vector3, _direction: Vector2, _player_speed: float, _last_update: int) -> MainUserData:
	var result = MainUserData.new()
	result.identity = _identity
	result.online = _online
	result.name = _name
	result.lobby_id = _lobby_id
	result.color = _color
	result.test_vec = _test_vec
	result.test_bytes_array = _test_bytes_array
	result.last_position = _last_position
	result.direction = _direction
	result.player_speed = _player_speed
	result.last_update = _last_update
	return result
