extends SteeringBehavior3D
class_name WallAvoidance3D

## Desvia de paredes usando 3 "bigodes" (raycasts) — um pra frente, dois nas laterais.
##
## CORREÇÃO em relação ao original: os ângulos laterais usavam .rotated(-120)
## e .rotated(120) em RADIANOS (não graus) — em Godot, rotated() espera
## radianos, então -120/120 "radianos" dá voltas inteiras e sobra um ângulo
## bem diferente do pretendido (120 graus). Aqui uso deg_to_rad() pra garantir
## que o ângulo configurado realmente é em graus.

@export var feeler_length: float = 3.0
@export var feeler_angle_degrees: float = 45.0
@export_flags_3d_physics var wall_collision_mask: int = 1 # ajuste no Inspetor pra bater com a camada real das paredes

@onready var _vehicle = get_parent()

var _feeler_forward: RayCast3D = RayCast3D.new()
var _feeler_right: RayCast3D = RayCast3D.new()
var _feeler_left: RayCast3D = RayCast3D.new()

func _ready() -> void:
	_calculate_feelers()

	for feeler in [_feeler_forward, _feeler_right, _feeler_left]:
		feeler.collision_mask = wall_collision_mask
		add_child(feeler)

func calculate() -> Vector3:
	var _closest_feeler: RayCast3D = null
	var _closest_distance: float = INF

	for feeler in [_feeler_forward, _feeler_right, _feeler_left]:
		if feeler.is_colliding():
			var _collision_point: Vector3 = feeler.get_collision_point()
			var _distance: float = _collision_point.distance_to(_vehicle.global_position)
			if _distance < _closest_distance:
				_closest_feeler = feeler
				_closest_distance = _distance

	if _closest_feeler:
		var _collision_depth: float = (_closest_feeler.target_position - to_local(_closest_feeler.get_collision_point())).length()
		return _closest_feeler.get_collision_normal() * _collision_depth

	return Vector3.ZERO

func _calculate_feelers() -> void:
	var _forward: Vector3 = Vector3(0, 0, -1) * feeler_length # -Z é "frente" em Godot 3D
	_feeler_forward.target_position = _forward
	_feeler_right.target_position = _forward.rotated(Vector3.UP, deg_to_rad(-feeler_angle_degrees)) * 0.5
	_feeler_left.target_position = _forward.rotated(Vector3.UP, deg_to_rad(feeler_angle_degrees)) * 0.5
