@tool
extends EditorScript

var path = []
var once : bool
var times : float
@export var mesh_rotation_degrees : float = 90
@export var distance_between_planks = 5.0:
	set(value):
		distance_between_planks = value
		is_dirty = true
	
var is_dirty = false


func _run():
	if not once:
		print("ejecutando una vez")
		for n in get_scene().get_children(true):
			if n is Path3D:
				print("iteración número ", times)
				path.append(n)
				print("array path")
				times += 1 
				is_dirty = false
		_update_multimesh()
		path[times if path.size()<2 else 0].connect("curve_changed", _on_curve_changed)
	if is_dirty:
		_update_multimesh()

func _update_multimesh():
	print("_update_multimesh")
	var path_length: float = path[times if path.size()<2 else 0].curve.get_baked_length()
	var count = floor(path_length / distance_between_planks)

	var mm: MultiMesh = path[times if path.size()<2 else 0].get_node("MultiMeshInstance3D").multimesh
	mm.instance_count = count
	var offset = distance_between_planks/2.0

	for i in range(0, count):
		print("setting mesh ", i)
		var curve_distance = offset + distance_between_planks * i
		var position = path[times if path.size()<2 else 0].curve.sample_baked(curve_distance, true)

		var basis = Basis()
		
		var up = path[times if path.size()<2 else 0].curve.sample_baked_up_vector(curve_distance, true)
		var forward = position.direction_to(path[times if path.size()<2 else 0].curve.sample_baked(curve_distance + 0.1, true))

		basis.y = up
		basis.x = forward.cross(up).normalized()
		basis.z = -forward#+Vector3(0,deg_to_rad(mesh_rotation_degrees),0)
		
		var transform = Transform3D(basis, position)
		mm.set_instance_transform(i, transform)


func _on_curve_changed():
	is_dirty = true
