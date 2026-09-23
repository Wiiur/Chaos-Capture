extends SteeringBehavior3D
class_name Evade3D

## Foge de um alvo PREVENDO a posição futura dele, baseado na velocidade
## atual — em vez de só fugir de onde ele está agora. Isso faz o animal
## "entender" pra onde o jogador está indo e se antecipar, dificultando
## que ele seja encurralado.
##
## Funciona com qualquer nó que tenha uma propriedade 'velocity' (nosso
## Vehicle3D tem, e o CharacterBody3D do jogador também tem nativamente
## — não precisa ser especificamente um Vehicle3D).
##
## NÃO tem mais 'panic_radius': quem decide QUANDO fugir é o Beehave
## (via PlayerNearCondition, com cheiro + visão). Aqui, se o nó está
## ativo, ele foge — sempre, com força total. Ter os dois critérios
## causava conflito (o Beehave mandava fugir mas o raio interno
## barrava, e o animal ficava só "desviando" em vez de correr).

@export var target_node: Node3D

@onready var _vehicle = get_parent()

func calculate() -> Vector3:
	if not target_node:
		return Vector3.ZERO

	var _target_velocity: Vector3 = target_node.velocity if "velocity" in target_node else Vector3.ZERO

	var _to_target: Vector3 = target_node.global_position - _vehicle.global_position
	var _look_ahead_time: float = _to_target.length() / (_vehicle.max_speed + _target_velocity.length())
	var _predicted_position: Vector3 = target_node.global_position + _target_velocity * _look_ahead_time

	return _flee(_predicted_position)

func _flee(target: Vector3) -> Vector3:
	var _to_target: Vector3 = _vehicle.global_position - target
	_to_target.y = 0.0

	if _to_target.length_squared() < 0.0001:
		return Vector3.ZERO

	var _desired_velocity: Vector3 = _to_target.normalized() * _vehicle.max_speed
	_vehicle.desired_velocity += _desired_velocity
	return _desired_velocity - _vehicle.velocity
