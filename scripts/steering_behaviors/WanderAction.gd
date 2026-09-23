extends ActionLeaf
class_name WanderAction

## Ação do Beehave: modo TRANQUILO.
## Ativa o "Wander" (que agora roda o Graze3D — anda até um ponto, para,
## escolhe outro), desativa o "Flee", volta pra velocidade de caminhada
## e devolve o peso do Flee ao normal.

const FLEE_IDLE_WEIGHT := 1.0

func tick(actor, _blackboard) -> int:
	_set_active(actor, "Wander", true)
	_set_active(actor, "Flee", false)

	# Devolve o peso do Flee ao normal — sem isso ele fica com peso de
	# prioridade máxima pra sempre, bagunçando o equilíbrio das forças
	var _flee_node = actor.get_node_or_null("Flee")
	if _flee_node:
		_flee_node.weight = FLEE_IDLE_WEIGHT

	if actor.has_method("set_walk_mode"):
		actor.set_walk_mode()

	return RUNNING

func _set_active(actor, node_name: String, value: bool) -> void:
	var _node = actor.get_node_or_null(node_name)
	if _node:
		_node.active = value
