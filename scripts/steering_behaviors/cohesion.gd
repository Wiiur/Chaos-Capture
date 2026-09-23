extends SteeringBehavior3D
class_name Cohesion3D

## Puxa o animal em direção ao centro do grupo de vizinhos (mantém o bando unido).

@export var radius: float = 5.0

@onready var _vehicle: Vehicle3D = get_parent()
@onready var _vehicles: Array[Vehicle3D] = _get_all_vehicles()

func calculate() -> Vector3:
	var _neighbors: Array[Vehicle3D] = []
	for v in _vehicles:
		if radius >= _vehicle.global_position.distance_to(v.global_position):
			_neighbors.append(v)

	var _center_of_mass := Vector3.ZERO
	var _steering_force := Vector3.ZERO

	if _neighbors.size() > 0:
		for n in _neighbors:
			_center_of_mass += n.global_position
		_center_of_mass /= _neighbors.size()
		_steering_force = _seek(_center_of_mass)

	return _steering_force

func _get_all_vehicles(node = get_tree().root, list_of_all_nodes_in_tree: Array[Vehicle3D] = []) -> Array[Vehicle3D]:
	if node is Vehicle3D and node != _vehicle:
		list_of_all_nodes_in_tree.append(node as Vehicle3D)
	for child_node in node.get_children():
		_get_all_vehicles(child_node, list_of_all_nodes_in_tree)
	return list_of_all_nodes_in_tree

func _seek(target: Vector3) -> Vector3:
	var _desired_velocity: Vector3 = _vehicle.global_position.direction_to(target) * _vehicle.max_speed
	_vehicle.desired_velocity += _desired_velocity
	return _desired_velocity - _vehicle.velocity
