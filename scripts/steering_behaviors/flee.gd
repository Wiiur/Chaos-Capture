extends SteeringBehavior3D
class_name Flee3D

## Comportamento de fuga (Flee) adaptado pra 3D.
## Encaixe este nó como FILHO do seu animal (o "veículo").
## O animal (nó pai) precisa ter um script com as propriedades:
## max_speed: float, velocity: Vector3, desired_velocity: Vector3

@export var target_node: Node3D       # de quem o animal foge (ex: o jogador)
@export var panic_radius: float = 10.0 # distância a partir da qual entra em pânico

@onready var _vehicle = get_parent()

func calculate() -> Vector3:
	if not target_node:
		return Vector3.ZERO

	var _to_target: Vector3 = _vehicle.global_position - target_node.global_position
	var _distance: float = _to_target.length()

	if _distance < panic_radius or panic_radius < 0:
		var _desired_velocity: Vector3 = _to_target.normalized() * _vehicle.max_speed
		_vehicle.desired_velocity += _desired_velocity
		return _desired_velocity - _vehicle.velocity

	return Vector3.ZERO
