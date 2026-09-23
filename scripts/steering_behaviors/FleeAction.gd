extends ActionLeaf
class_name FleeAction

## Ação do Beehave: modo FUGA.
## Ativa o "Flee" (apontando pro jogador mais próximo, guardado no
## blackboard pelo PlayerNearCondition), desativa o "Wander" e troca
## pra velocidade de corrida.
##
## O peso do Flee é aumentado enquanto ativo, pra ele DOMINAR sobre o
## WallAvoidance — assim o animal prioriza fugir pro lado oposto do
## jogador, e o desvio de parede só age no mínimo indispensável.
## O WanderAction devolve esse peso ao normal quando a fuga acaba.

const FLEE_PRIORITY_WEIGHT := 4.0

func tick(actor, blackboard) -> int:
	var _threat = blackboard.get_value("threat")
	var _flee_node = actor.get_node_or_null("Flee")

	if _flee_node and _threat:
		_flee_node.target_node = _threat
		_flee_node.weight = FLEE_PRIORITY_WEIGHT

	_set_active(actor, "Wander", false)
	_set_active(actor, "Flee", true)

	if actor.has_method("set_run_mode"):
		actor.set_run_mode()

	return RUNNING

func _set_active(actor, node_name: String, value: bool) -> void:
	var _node = actor.get_node_or_null(node_name)
	if _node:
		_node.active = value
