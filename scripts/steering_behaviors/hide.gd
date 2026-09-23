extends SteeringBehavior3D
class_name Hide3D

## Esconde o animal atrás do obstáculo mais próximo, na direção oposta
## a uma ameaça (ex: o jogador se aproximando).
##
## MUDANÇA em relação ao original: em vez do caminho fixo $"../../Obstacles"
## (frágil, depende da estrutura exata da cena), busca obstáculos pelo grupo
## "steering_obstacles" — todo Obstacle3D já se registra nesse grupo sozinho.

@export var target: Node3D
@export var distance_from_boundary: float = 3.0
@export var deceleration_tweeker: float = 0.3

@onready var _vehicle = get_parent()

var _hiding_spots: Array[Vector3] = []

func calculate() -> Vector3:
	_hiding_spots.clear()

	for o in get_tree().get_nodes_in_group(&"steering_obstacles"):
		if not (o is Obstacle3D):
			continue
		var _direction: Vector3 = (o.global_position - target.global_position).normalized()
		_hiding_spots.append(o.global_position + _direction * (o.radius + distance_from_boundary))

	var _closest_distance: float = INF
	var _closest_hiding_spot: Vector3 = Vector3.ZERO
	var _found: bool = false

	for h in _hiding_spots:
		var _distance: float = (h - _vehicle.global_position).length()
		if _distance < _closest_distance:
			_closest_distance = _distance
			_closest_hiding_spot = h
			_found = true

	if _found:
		return _arrive(_closest_hiding_spot)

	return Vector3.ZERO

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
