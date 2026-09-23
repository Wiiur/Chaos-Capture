extends CharacterBody3D
class_name Vehicle3D

## Script base pro animal/personagem, usado pelos nós de comportamento
## (Flee, Seek, etc.) que ficam como filhos deste nó.
## Adaptado fielmente do "Vehicle" original 2D, com estas mudanças pro 3D:
## - Sem _wrap_around() (não faz sentido em mundo 3D aberto, isso era pra
##   tela 2D que "enrola" nas bordas)
## - Sem _draw() manual (em 3D o visual vem do modelo/mesh do animal, não
##   de um triângulo desenhado)
## - Rotação feita com look_at() no plano horizontal, em vez da fórmula de
##   ângulo 2D
## - Usa move_and_slide() do CharacterBody3D em vez de mexer em "position"
##   direto, pra já vir com colisão física

@export_group("Simulação")
@export var mass: float = 1.0
@export var max_force: float = 10.0
@export var width: float = 0.5 # usado pelo ObstacleAvoidance3D

@export_group("Velocidades")
## Velocidade no modo tranquilo (pastando/passeando)
@export var walk_speed: float = 2.0
## Velocidade no modo fuga (disparado)
@export var run_speed: float = 7.0
## Quanto a velocidade decai por segundo quando não há força de steering
## (é o "freio" — sem isso o animal desliza sem parar depois de correr)
@export var friction: float = 8.0

@export_group("Comportamentos de Steering")
@export var _get_automatically: bool = true
@export var _steering_behaviors: Array[SteeringBehavior3D] = []

## Velocidade máxima atual — os comportamentos leem isso.
## Trocada em tempo real pelas ações do Beehave (andar x correr).
var max_speed: float = 2.0

var desired_velocity: Vector3 = Vector3.ZERO  # usado só pros comportamentos acumularem (ex: debug futuro)
var heading: Vector3 = Vector3(0, 0, -1)      # frente do animal (local -Z é a convenção 3D)
var side: Vector3 = Vector3(1, 0, 0)          # lateral do animal

func _ready() -> void:
	max_speed = walk_speed
	if _get_automatically:
		for _child in get_children():
			if _child is SteeringBehavior3D:
				_steering_behaviors.append(_child)

## Chamado pelas ações do Beehave pra alternar entre os modos
func set_walk_mode() -> void:
	max_speed = walk_speed

func set_run_mode() -> void:
	max_speed = run_speed

func _physics_process(delta: float) -> void:
	var _steering_force: Vector3 = _calculate_steering_force()

	if _steering_force.length_squared() > 0.0001:
		var _acceleration: Vector3 = _steering_force / mass
		velocity += _acceleration
	else:
		# Sem força nenhuma (ex: pausa do pastar) — freia até parar
		velocity = velocity.move_toward(Vector3.ZERO, friction * delta)

	velocity = velocity.limit_length(max_speed)

	move_and_slide()

	if velocity.length_squared() > 0.01:
		heading = velocity.normalized()
		side = heading.cross(Vector3.UP).normalized()

		# Vira o corpo do animal pra direção que está indo (só no plano horizontal)
		var _flat_heading := Vector3(heading.x, 0, heading.z)
		if _flat_heading.length_squared() > 0.0001:
			look_at(global_position + _flat_heading, Vector3.UP)

func _calculate_steering_force() -> Vector3:
	var _steering_force: Vector3 = Vector3.ZERO

	for _steering_behavior in _steering_behaviors:
		if _steering_behavior.active:
			_steering_force += _steering_behavior.calculate() * _steering_behavior.weight

	_steering_force = _steering_force.limit_length(max_force)

	return _steering_force
