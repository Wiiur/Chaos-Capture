extends SteeringBehavior3D
class_name Arrive3D

## Se aproxima de um alvo e desacelera suavemente ao chegar perto
## (em vez de bater e parar seco). Bom pra IA de animais "curiosos"
## que se aproximam de uma isca, por exemplo.

enum Deceleration {
	SLOW = 3,
	NORMAL = 2,
	FAST = 1,
}

@export var target_node: Node3D
@export var deceleration: Deceleration = Deceleration.NORMAL
@export var deceleration_tweeker: float = 0.3

@onready var _vehicle = get_parent()

func calculate() -> Vector3:
	var _to_target: Vector3 = target_node.global_position - _vehicle.global_position
	var _distance: float = _to_target.length()

	if _distance > 0:
		var _speed: float = _distance / (float(deceleration) * deceleration_tweeker)
		_speed = min(_speed, _vehicle.max_speed)

		var _desired_velocity: Vector3 = _to_target * _speed / _distance
		_vehicle.desired_velocity += _desired_velocity

		return _desired_velocity - _vehicle.velocity

	return Vector3.ZERO
