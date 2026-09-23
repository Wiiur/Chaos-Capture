extends SteeringBehavior3D
class_name Seek3D

## Persegue um alvo (usado pra vocês perseguirem/encurralarem o animal,
## ou pro animal perseguir comida/fugir de perigo dependendo do contexto)

@export var target_node: Node3D

@onready var _vehicle = get_parent()

func calculate() -> Vector3:
	var _desired_velocity: Vector3 = _vehicle.global_position.direction_to(target_node.global_position) * _vehicle.max_speed
	_vehicle.desired_velocity += _desired_velocity
	return _desired_velocity - _vehicle.velocity
