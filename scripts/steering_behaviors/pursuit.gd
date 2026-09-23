extends SteeringBehavior3D
class_name Pursuit3D

## Persegue um alvo em movimento prevendo pra onde ele vai
## (em vez de correr atrás da posição atual, que sempre fica pra trás).
## Ótimo pro predador oportunista perseguindo um jogador correndo,
## ou pra um bicho fugitivo mais esperto se desviando de vocês.

@export var target_node: Node3D

@onready var _vehicle = get_parent()
@onready var _predicted_position: Vector3 = target_node.global_position

func calculate() -> Vector3:
	# Se o alvo não é outro "Vehicle3D" (ex: é uma isca parada), só persegue normal
	if not (target_node is Vehicle3D):
		return _seek(target_node.global_position)

	var _to_target: Vector3 = target_node.global_position - _vehicle.global_position
	var _relative_heading: float = _vehicle.heading.dot(target_node.heading)

	# Se o alvo está vindo de frente pra você, não precisa prever — vai direto
	if _to_target.dot(_vehicle.heading) > 0 and _relative_heading < -0.95:
		return _seek(target_node.global_position)

	# Prevê onde o alvo vai estar, baseado na velocidade dele
	var _look_ahead_time: float = _to_target.length() / (_vehicle.max_speed + target_node.velocity.length())
	_predicted_position = target_node.global_position + target_node.velocity * _look_ahead_time

	return _seek(_predicted_position)

func _seek(target: Vector3) -> Vector3:
	var _desired_velocity: Vector3 = _vehicle.global_position.direction_to(target) * _vehicle.max_speed
	_vehicle.desired_velocity += _desired_velocity
	return _desired_velocity - _vehicle.velocity
