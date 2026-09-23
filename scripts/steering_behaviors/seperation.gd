extends SteeringBehavior3D
class_name Seperation3D

## Afasta o animal de vizinhos muito próximos (evita empilhar/colidir),
## parte clássica do trio de comportamento de bando junto com Alignment e Cohesion.

@export var radius: float = 3.0

@onready var _vehicle: Vehicle3D = get_parent()
@onready var _vehicles: Array[Vehicle3D] = _get_all_vehicles()

func calculate() -> Vector3:
	var _neighbors: Array[Vehicle3D] = []
	for v in _vehicles:
		if radius >= _vehicle.global_position.distance_to(v.global_position):
			_neighbors.append(v)

	var _steering_force := Vector3.ZERO
	for n in _neighbors:
		var _to_agent: Vector3 = _vehicle.global_position - n.global_position
		if _to_agent.length() > 0: # evita divisão por zero se dois animais estiverem no mesmo ponto
			_steering_force += _to_agent.normalized() / _to_agent.length()

	return _steering_force

func _get_all_vehicles(node = get_tree().root, list_of_all_nodes_in_tree: Array[Vehicle3D] = []) -> Array[Vehicle3D]:
	if node is Vehicle3D and node != _vehicle:
		list_of_all_nodes_in_tree.append(node as Vehicle3D)
	for child_node in node.get_children():
		_get_all_vehicles(child_node, list_of_all_nodes_in_tree)
	return list_of_all_nodes_in_tree
