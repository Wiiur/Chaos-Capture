extends ConditionLeaf
class_name PlayerNearCondition

## Condição do Beehave: retorna SUCCESS se ALGUM jogador for percebido,
## combinando dois "sentidos":
##
## 1. CHEIRO/PASSOS (smell_radius): detecta em QUALQUER direção — na
##    frente, do lado, atrás — mas só a curta distância. Simula o animal
##    sentindo o cheiro ou ouvindo passos próximos.
## 2. VISÃO (vision_range + vision_angle_degrees): detecta só dentro de
##    um cone à frente do animal, mas alcança bem mais longe.
##
## O jogador é percebido se caber em QUALQUER um dos dois sentidos.
##
## IMPORTANTE: o personagem do jogador precisa estar no grupo "player".

@export_category("Cheiro / Audição (qualquer direção)")
@export var smell_radius: float = 6.0

@export_category("Visão (cone à frente)")
@export var vision_range: float = 15.0
@export_range(0.0, 180.0, 1.0) var vision_angle_degrees: float = 90.0

func tick(actor, blackboard) -> int:
	var _closest_player = _get_closest_player(actor.global_position)
	if not _closest_player:
		return FAILURE

	var _distance: float = actor.global_position.distance_to(_closest_player.global_position)

	# Sentido 1: cheiro/passos — funciona em qualquer direção, perto
	var _smelled: bool = _distance <= smell_radius

	# Sentido 2: visão — só dentro do cone à frente, mais longe
	var _seen: bool = false
	if _distance <= vision_range:
		var _direction_to_player: Vector3 = (_closest_player.global_position - actor.global_position).normalized()
		var _heading: Vector3 = actor.heading if "heading" in actor else -actor.global_transform.basis.z
		var _angle_to_player: float = rad_to_deg(_heading.angle_to(_direction_to_player))
		_seen = _angle_to_player <= vision_angle_degrees * 0.5

	if _smelled or _seen:
		blackboard.set_value("threat", _closest_player)
		return SUCCESS

	return FAILURE

func _get_closest_player(from_position: Vector3) -> Node3D:
	var _closest: Node3D = null
	var _closest_distance: float = INF

	for _player in get_tree().get_nodes_in_group(&"player"):
		var _distance: float = from_position.distance_to(_player.global_position)
		if _distance < _closest_distance:
			_closest_distance = _distance
			_closest = _player

	return _closest
