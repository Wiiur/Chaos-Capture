extends SteeringBehavior3D
class_name OffsetPursuit3D

## Persegue um "líder" mantendo um deslocamento fixo em relação a ele
## (formação de bando, ou filhote seguindo os pais a uma distância).

@export var leader: Node3D
@export var offset: Vector3 = Vector3(2, 0, 2) # deslocamento em espaço local do líder
@export var deceleration_tweeker: float = 0.3

@onready var _vehicle = get_parent()

func calculate() -> Vector3:
	var _offset_global: Vector3 = leader.to_global(offset)
	var _to_offset: Vector3 = _offset_global - _vehicle.global_position

	var _leader_max_speed: float = leader.max_speed if leader is Vehicle3D else _vehicle.max_speed
	var _leader_velocity: Vector3 = leader.velocity if leader is Vehicle3D else Vector3.ZERO
	var _look_ahead_time: float = _to_offset.length() / (_vehicle.max_speed + _leader_max_speed)

	return _arrive(_offset_global + _leader_velocity * _look_ahead_time)

func _arrive(target_pos: Vector3) -> Vector3:
	var _to_target: Vector3 = target_pos - _vehicle.global_position
	var _distance: float = _to_target.length()

	if _distance > 0:
		var _speed: float = _distance / deceleration_tweeker
		_speed = min(_speed, _vehicle.max_speed)

		var _desired_velocity: Vector3 = _to_target * _speed / _distance
		_vehicle.desired_velocity += _desired_velocity

		return _desired_velocity - _vehicle.velocity

	return Vector3.ZERO
