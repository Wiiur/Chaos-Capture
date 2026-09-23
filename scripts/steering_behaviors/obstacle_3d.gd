extends Node3D
class_name Obstacle3D

## Anexe este script em qualquer objeto que os animais devem desviar
## (árvore, rocha, tronco caído). Ele cria automaticamente uma área
## de detecção esférica ao redor do objeto.

@export var radius: float = 1.0

@onready var _area3d: Area3D = Area3D.new()
@onready var _collision_shape3d: CollisionShape3D = CollisionShape3D.new()
@onready var _sphere_shape3d: SphereShape3D = SphereShape3D.new()

func _ready() -> void:
	_sphere_shape3d.radius = radius
	_collision_shape3d.shape = _sphere_shape3d
	_area3d.add_child(_collision_shape3d)
	add_child(_area3d)
	add_to_group(&"steering_obstacles") # usado pelo Hide3D pra encontrar obstáculos
