extends SteeringBehavior3D
class_name Wander3D

## Movimento aleatório "orgânico" — ótimo pra bichos do Tier 1/2 
## que ficam vagando até perceberem o jogador (aí trocam pra Flee).

@export var wander_radius: float = 2.0
@export var wander_distance: float = 4.0
@export var wander_jitter: float = 1.0

@onready var _vehicle = get_parent()

var wander_target: Vector3 = Vector3.ZERO

func calculate() -> Vector3:
	# Mexe o alvo de vagar aleatoriamente no plano X/Z (chão)
	wander_target += Vector3(
		randf_range(-1, 1) * wander_jitter,
		0,
		randf_range(-1, 1) * wander_jitter
	)
	wander_target = wander_target.normalized() * wander_radius

	# Empurra o alvo pra frente do animal.
	# Em Godot 3D, "frente" por convenção é o eixo -Z local do nó.
	wander_target += Vector3(0, 0, -1) * wander_distance

	# Converte de espaço local (relativo ao animal) pra posição global
	return _vehicle.to_global(wander_target) - _vehicle.global_position
