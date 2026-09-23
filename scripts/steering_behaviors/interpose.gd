extends SteeringBehavior3D
class_name Interpose3D

## Se posiciona no meio do caminho entre dois alvos.
##
## CORREÇÃO em relação ao original: o script calculava "_time_to_mid"
## mas nunca usava esse valor na previsão de posição (a velocidade do
## alvo era somada sem multiplicar pelo tempo). Aqui a previsão usa o
## tempo corretamente, ficando mais precisa.

@export var target1: Node3D
@export var target2: Node3D
@export var deceleration_tweeker: float = 0.3

@onready var _vehicle: Vehicle3D = get_parent()

var _mid_point: Vector3
var _prediction1: Vector3
var _prediction2: Vector3

func calculate() -> Vector3:
	_mid_point = (target1.global_position + target2.global_position) / 2.0
	var _distance_to_mid: float = _vehicle.global_position.distance_to(_mid_point)
	var _time_to_mid: float = _distance_to_mid / _vehicle.max_speed

	_prediction1 = target1.global_position
	if target1 is Vehicle3D:
		_prediction1 = target1.global_position + target1.velocity * _time_to_mid

	_prediction2 = target2.global_position
	if target2 is Vehicle3D:
		_prediction2 = target2.global_position + target2.velocity * _time_to_mid

	_mid_point = (_prediction1 + _prediction2) / 2.0

	return _arrive(_mid_point)

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
