extends SteeringBehavior3D
class_name PathFollow3D

## Segue uma sequência de pontos (filhos de um Node3D "path") em ordem.
## Ótimo pra rota de patrulha de um animal ou trajeto fixo de um NPC.

enum Deceleration {
	SLOW = 3,
	NORMAL = 2,
	FAST = 1,
}

@export var path: Node3D
@export var loop: bool = false
@export var distance_to_complete: float = 2.0
@export var deceleration: Deceleration = Deceleration.FAST
@export var deceleration_tweeker: float = 0.3

@onready var _vehicle = get_parent()

var _points: Array[Vector3] = []
var _current: Vector3
var _index: int = 0

func _ready() -> void:
	for p in path.get_children():
		_points.append(p.global_position)

	_current = _points[_index]

func _process(_delta: float) -> void:
	if (_current - _vehicle.global_position).length() < distance_to_complete:
		_index += 1
		if _index < _points.size():
			_current = _points[_index]
		elif _index == _points.size() and loop:
			_index = 0
			_current = _points[_index]

func calculate() -> Vector3:
	if _current == _points[_points.size() - 1] and not loop:
		return _arrive(_current)

	return _seek(_current)

func _seek(target: Vector3) -> Vector3:
	var _desired_velocity: Vector3 = _vehicle.global_position.direction_to(target) * _vehicle.max_speed
	_vehicle.desired_velocity += _desired_velocity
	return _desired_velocity - _vehicle.velocity

func _arrive(target_pos: Vector3) -> Vector3:
	var _to_target: Vector3 = target_pos - _vehicle.global_position
	var _distance: float = _to_target.length()

	if _distance > 0:
		var _speed: float = _distance / (float(deceleration) * deceleration_tweeker)
		_speed = min(_speed, _vehicle.max_speed)

		var _desired_velocity: Vector3 = _to_target * _speed / _distance
		_vehicle.desired_velocity += _desired_velocity

		return _desired_velocity - _vehicle.velocity

	return Vector3.ZERO
