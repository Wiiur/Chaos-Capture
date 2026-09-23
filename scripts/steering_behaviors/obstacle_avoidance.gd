extends SteeringBehavior3D
class_name ObstacleAvoidance3D

## Detecta obstáculos à frente do animal (árvores, rochas) numa "caixa"
## que cresce com a velocidade, e desvia lateralmente do mais próximo.
##
## CORREÇÕES em relação ao script original (2D):
## 1. O original retornava uma posição (_vehicle.to_global) em vez de uma
##    velocidade — inconsistente com os outros comportamentos. Corrigido
##    pra devolver uma direção/força, igual aos outros.
## 2. O original calculava a posição do obstáculo em espaço global, sem
##    considerar pra onde o animal está virado — só funcionava se o
##    personagem nunca girasse. Agora usa to_local(), que funciona com
##    qualquer rotação.

@export var min_detection_box_length: float = 3.0
@export var show_visuals: bool = false

@onready var _vehicle = get_parent()

var _detection_box_length: float
var _area3d: Area3D
var _collision_shape3d: CollisionShape3D
var _box_shape3d: BoxShape3D
var _obstacles: Array[Obstacle3D] = []

func _ready() -> void:
	_box_shape3d = BoxShape3D.new()
	_collision_shape3d = CollisionShape3D.new()
	_collision_shape3d.shape = _box_shape3d
	_area3d = Area3D.new()
	_area3d.area_entered.connect(_obstacle_entered)
	_area3d.area_exited.connect(_obstacle_exited)

	add_child(_area3d)
	_area3d.add_child(_collision_shape3d)

func calculate() -> Vector3:
	_detection_box_length = min_detection_box_length + (_vehicle.velocity.length() / _vehicle.max_speed) * min_detection_box_length

	# Caixa de detecção à frente do animal (largura x altura baixa x comprimento)
	_box_shape3d.size = Vector3(_vehicle.width * 2, 1.0, _detection_box_length)
	# Local -Z é "frente" em Godot 3D — posiciona a caixa nessa direção
	_area3d.position = Vector3(0, 0, -_detection_box_length / 2)

	var _dist_to_closest_ip: float = INF
	var _closest_obstacle: Obstacle3D = null
	var _forward_dist_obstacle: float = 0.0
	var _lateral_pos_obstacle: float = 0.0

	for o in _obstacles:
		# to_local() já aplica a rotação do animal corretamente
		var _local_position: Vector3 = _vehicle.to_local(o.global_position)
		var _forward_dist: float = -_local_position.z # distância à frente (local -Z)
		var _lateral_pos: float = _local_position.x   # posição lateral (esquerda/direita)

		if _forward_dist >= 0:
			var _expanded_radius: float = o.radius + _vehicle.width

			if abs(_lateral_pos) < _expanded_radius:
				var _sqrt_term: float = sqrt(_expanded_radius * _expanded_radius - _lateral_pos * _lateral_pos)

				var _ip: float = _forward_dist - _sqrt_term
				if _ip <= 0:
					_ip = _forward_dist + _sqrt_term

				if _ip < _dist_to_closest_ip:
					_dist_to_closest_ip = _ip
					_closest_obstacle = o
					_forward_dist_obstacle = _forward_dist
					_lateral_pos_obstacle = _lateral_pos

	if _closest_obstacle:
		var _steering_force: Vector3 = Vector3.ZERO
		var multiplier: float = 1.0 + (_detection_box_length - _forward_dist_obstacle) / _detection_box_length
		_steering_force.x = (_closest_obstacle.radius - _lateral_pos_obstacle) * multiplier

		var _breaking_weight: float = 0.2
		_steering_force.z = (_closest_obstacle.radius - _forward_dist_obstacle) * _breaking_weight

		# Converte a força de espaço local pra direção global (corrige o bug original)
		return (_vehicle.global_transform.basis * _steering_force)

	return Vector3.ZERO

func _obstacle_entered(area: Area3D) -> void:
	if area.get_parent() is Obstacle3D:
		_obstacles.append(area.get_parent())

func _obstacle_exited(area: Area3D) -> void:
	if area.get_parent() is Obstacle3D:
		_obstacles.remove_at(_obstacles.find(area.get_parent()))
