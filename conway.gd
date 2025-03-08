extends Node3D
class_name DualTruncateModifier

var mesh_instance: MeshInstance3D
var mesh_data_tool: MeshDataTool

func _ready():
	# Create a CubeMesh (a type of PrimitiveMesh)
	var cube_mesh = BoxMesh.new()
	cube_mesh.size = Vector3(1, 1, 1)

	# Convert the CubeMesh to an ArrayMesh
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, cube_mesh.get_mesh_arrays())

	# Assign the ArrayMesh to the MeshInstance3D
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = array_mesh
	add_child(mesh_instance)

	# Initialize MeshDataTool
	mesh_data_tool = MeshDataTool.new()
	var result = mesh_data_tool.create_from_surface(array_mesh, 0)
	if result != OK:
		print("Failed to create MeshDataTool from surface: ", result)
		return

	# Apply dual and truncate operators
	dual_operator()
	truncate_operator()

	# Update the mesh instance
	update_mesh()

func dual_operator():
	var face_centroids = []
	for f in range(mesh_data_tool.get_face_count()):
		var centroid = Vector3.ZERO
		var vertex_count = 0
		for v in range(3):  # Assuming triangular faces
			var vertex_id = mesh_data_tool.get_face_vertex(f, v)
			centroid += mesh_data_tool.get_vertex(vertex_id)
			vertex_count += 1
		centroid /= vertex_count
		face_centroids.append(centroid)
	var vertex_to_faces := {}
	for f in range(mesh_data_tool.get_face_count()):
		var count: int = mesh_data_tool.get_face_vertex_count(f)
		for i in range(count):
			var vid := mesh_data_tool.get_face_vertex(f, i)
			if not vertex_to_faces.has(vid):
				vertex_to_faces[vid] = []
			vertex_to_faces[vid].append(f)

	var new_faces := []
	for vid in vertex_to_faces.keys():
		new_faces.append(vertex_to_faces[vid])

	var new_vertices := PackedVector3Array(face_centroids)
	var new_indices := PackedInt32Array()
	for face in new_faces:
		if face.size() < 3:
			continue
		var first_index = face[0]
		for i in range(1, face.size() - 1):
			new_indices.append(first_index)
			new_indices.append(face[i])
			new_indices.append(face[i + 1])

	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = new_vertices
	arrays[Mesh.ARRAY_INDEX] = new_indices

	var dual_mesh = ArrayMesh.new()
	dual_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	mesh_instance.mesh = dual_mesh
	mesh_data_tool.clear()
	mesh_data_tool.create_from_surface(dual_mesh, 0)


func truncate_operator():
	var t: float = 0.5
	var edge_midpoints := {}
	for e in range(mesh_data_tool.get_edge_count()):
		var v0 = mesh_data_tool.get_vertex(mesh_data_tool.get_edge_vertex(e, 0))
		var v1 = mesh_data_tool.get_vertex(mesh_data_tool.get_edge_vertex(e, 1))
		edge_midpoints[e] = v0.lerp(v1, t)

	var new_face_points := []
	for f in range(mesh_data_tool.get_face_count()):
		var face_pts := []
		var count: int = mesh_data_tool.get_face_vertex_count(f)
		for i in range(count):
			var vid0 = mesh_data_tool.get_face_vertex(f, i)
			var vid1 = mesh_data_tool.get_face_vertex(f, (i + 1) % count)
			var edge_index = _find_edge_between(vid0, vid1)
			if edge_index == -1:
				continue
			face_pts.append(edge_midpoints[edge_index])
		new_face_points.append(face_pts)

	var vertex_to_points := {}
	for e in range(mesh_data_tool.get_edge_count()):
		for i in range(2):
			var vid = mesh_data_tool.get_edge_vertex(e, i)
			if not vertex_to_points.has(vid):
				vertex_to_points[vid] = []
			vertex_to_points[vid].append(edge_midpoints[e])

	var truncated_faces = new_face_points.duplicate()
	for vid in vertex_to_points.keys():
		truncated_faces.append(vertex_to_points[vid])

	var final_vertices := []
	var final_indices := PackedInt32Array()
	var vertex_counter: int = 0
	for face in truncated_faces:
		if face.size() < 3:
			continue
		var start_index = vertex_counter
		for pt in face:
			final_vertices.append(pt)
			vertex_counter += 1
		for i in range(1, face.size() - 1):
			final_indices.append(start_index)
			final_indices.append(start_index + i)
			final_indices.append(start_index + i + 1)

	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array(final_vertices)
	arrays[Mesh.ARRAY_INDEX] = final_indices

	var truncated_mesh = ArrayMesh.new()
	truncated_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	mesh_instance.mesh = truncated_mesh
	mesh_data_tool.clear()
	mesh_data_tool.create_from_surface(truncated_mesh, 0)


func _find_edge_between(vid0: int, vid1: int) -> int:
	for e in range(mesh_data_tool.get_edge_count()):
		var a = mesh_data_tool.get_edge_vertex(e, 0)
		var b = mesh_data_tool.get_edge_vertex(e, 1)
		if (a == vid0 and b == vid1) or (a == vid1 and b == vid0):
			return e
	return -1


func update_mesh():
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	var new_vertices = PackedVector3Array()
	var new_normals = PackedVector3Array()
	var new_indices = PackedInt32Array()

	for i in range(mesh_data_tool.get_vertex_count()):
		new_vertices.append(mesh_data_tool.get_vertex(i))
		new_normals.append(mesh_data_tool.get_vertex_normal(i))

	for f in range(mesh_data_tool.get_face_count()):
		var count: int = mesh_data_tool.get_face_vertex_count(f)
		var first = mesh_data_tool.get_face_vertex(f, 0)
		for i in range(1, count - 1):
			new_indices.append(first)
			new_indices.append(mesh_data_tool.get_face_vertex(f, i))
			new_indices.append(mesh_data_tool.get_face_vertex(f, i + 1))

	arrays[Mesh.ARRAY_VERTEX] = new_vertices
	arrays[Mesh.ARRAY_NORMAL] = new_normals
	arrays[Mesh.ARRAY_INDEX] = new_indices

	var new_mesh = ArrayMesh.new()
	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh_instance.mesh = new_mesh

	mesh_data_tool.clear()
	mesh_data_tool.create_from_surface(new_mesh, 0)
