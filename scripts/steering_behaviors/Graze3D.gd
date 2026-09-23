extends SteeringBehavior3D
class_name Graze3D

## Modo tranquilo: escolhe um ponto aleatório perto, caminha até ele,
## para por um tempo (se alimentando/farejando), escolhe outro ponto,
## e assim por diante.
##
## Diferente do Wander (que vagueia sem destino, sem nunca parar),
## aqui existe um DESTINO concreto de cada vez — o movimento fica
## mais natural e o animal realmente para entre um trecho e outro.

@export_category("Área de Perambulação")
## Distância máxima de cada novo ponto escolhido
@export var roam_radius: float = 12.0
## Distância pra considerar que "chegou" no ponto
@export var arrival_distance: float = 1.0
## Desaceleração ao se aproximar do ponto (menor = freia mais cedo)
@export var deceleration_tweeker: float = 0.6

@export_category("Tempo de Pausa")
@export var pause_duration_min: float = 1.5
@export var pause_duration_max: float = 4.0
## Tempo máximo tentando chegar num ponto antes de desistir e escolher outro
## (evita travar se o ponto cair dentro de uma parede)
@export var max_travel_time: float = 8.0

@onready var _vehicle = get_parent()

var _target_point: Vector3 = Vector3.ZERO
var _is_paused: bool = true
var _timer: float = 0.0

func _ready() -> void:
	_start_pause()

func _process(delta: float) -> void:
	_timer -= delta

	if _is_paused:
		if _timer <= 0.0:
			_pick_new_point()
		return

	# Chegou no ponto, ou demorou demais tentando
	var _distance := 10
	if _distance <= arrival_distance or _timer <= 0.0:
		_start_pause()

func _start_pause() -> void:
	_is_paused = true
	_timer = randf_range(pause_duration_min, pause_duration_max)

func _pick_new_point() -> void:
	var _angle := randf_range(0.0, TAU)
	var _distance := randf_range(roam_radius * 0.3, roam_radius)
	var _offset := Vector3(cos(_angle) * _distance, 0.0, sin(_angle) * _distance)

	_target_point = _vehicle.global_position + _offset
	_is_paused = false
	_timer = max_travel_time

func calculate() -> Vector3:
	if _is_paused:
		return Vector3.ZERO

	# Arrive: vai até o ponto desacelerando ao chegar perto
	var _to_target: Vector3 = _target_point - _vehicle.global_position
	_to_target.y = 0.0
	var _distance: float = _to_target.length()

	if _distance > 0.01:
		var _speed: float = min(_distance / deceleration_tweeker, _vehicle.max_speed)
		var _desired_velocity: Vector3 = _to_target / _distance * _speed
		_vehicle.desired_velocity += _desired_velocity
		return _desired_velocity - _vehicle.velocity

	return Vector3.ZERO
