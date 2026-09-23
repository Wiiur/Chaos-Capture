extends SteeringBehavior3D
class_name Alignment3D

## Alinha a direção do animal com a dos vizinhos próximos (efeito de bando).

@export var radius: float = 5.0

@onready var _vehicle: Vehicle3D = get_parent()
@onready var _vehicles: Array[Vehicle3D] = _get_all_vehicles()

func calculate() -> Vector3:
	var _neighbors: Array[Vehicle3D] = []
	for v in _vehicles:
		if radius >= _vehicle.global_position.distance_to(v.global_position):
			_neighbors.append(v)

	var _average_heading := Vector3.ZERO
	for n in _neighbors:
		_average_heading += n.heading

	if _neighbors.size() > 0:
		_average_heading /= _neighbors.size()
		_average_heading -= _vehicle.heading

	return _average_heading

# não é o jeito mais performático, mas funciona (igual ao original)
func _get_all_vehicles(node = get_tree().root, list_of_all_nodes_in_tree: Array[Vehicle3D] = []) -> Array[Vehicle3D]:
	if node is Vehicle3D and node != _vehicle:
		list_of_all_nodes_in_tree.append(node as Vehicle3D)
	for child_node in node.get_children():
		_get_all_vehicles(child_node, list_of_all_nodes_in_tree)
	return list_of_all_nodes_in_tree
