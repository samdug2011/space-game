extends Node
var vertices:PackedVector3Array = []
var faces = []

func generate_icosphere():
	var t = (1.0 + sqrt(5.0)) / 2
	
	vertices.push_back(Vector3(-1, t, 0).normalized())
	vertices.push_back(Vector3(1, t, 0).normalized())
	vertices.push_back(Vector3(-1, -t, 0).normalized())
	vertices.push_back(Vector3(1, -t, 0).normalized())
	vertices.push_back(Vector3(0, -1, t).normalized())
	vertices.push_back(Vector3(0, 1, t).normalized())
	vertices.push_back(Vector3(0, -1, -t).normalized())
	vertices.push_back(Vector3(0, 1, -t).normalized())
	vertices.push_back(Vector3(t, 0, -1).normalized())
	vertices.push_back(Vector3(t, 0, 1).normalized())
	vertices.push_back(Vector3(-t, 0, -1).normalized())
	vertices.push_back(Vector3(-t, 0, 1).normalized())
	
	faces.push_back(PackedInt32Array([0, 11, 5]))
	faces.push_back(PackedInt32Array([0, 5, 1]))
	faces.push_back(PackedInt32Array([0, 1, 7]))
	faces.push_back(PackedInt32Array([0, 7, 10]))
	faces.push_back(PackedInt32Array([0, 10, 11]))
	faces.push_back(PackedInt32Array([1, 5, 9]))
	faces.push_back(PackedInt32Array([5, 11, 4]))
	faces.push_back(PackedInt32Array([11, 10, 2]))
	faces.push_back(PackedInt32Array([10, 7, 6]))
	faces.push_back(PackedInt32Array([7, 1, 8]))
	faces.push_back(PackedInt32Array([3, 9, 4]))
	faces.push_back(PackedInt32Array([3, 4, 2]))
	faces.push_back(PackedInt32Array([3, 2, 6]))
	faces.push_back(PackedInt32Array([3, 6, 8]))
	faces.push_back(PackedInt32Array([3, 8, 9]))
	faces.push_back(PackedInt32Array([4, 9, 5]))
	faces.push_back(PackedInt32Array([2, 4, 11]))
	faces.push_back(PackedInt32Array([6, 2, 10]))
	faces.push_back(PackedInt32Array([8, 6, 7]))
	faces.push_back(PackedInt32Array([9, 8, 1]))
func subdivide(face: PackedInt32Array, _radius: float) -> Array:
	var v0: int = face[0]
	var v1: int = face[1]
	var v2: int = face[2]
	
	# Add midpoints and ensure they're unique
	var mid0: Vector3 = (vertices[v0] + vertices[v1]).normalized()
	var mid1: Vector3 = (vertices[v1] + vertices[v2]).normalized()
	var mid2: Vector3 = (vertices[v2] + vertices[v0]).normalized()
	
	# Append new vertices and get their indices
	vertices.append(mid0)
	var m0: int = vertices.size() - 1
	vertices.append(mid1)
	var m1: int = vertices.size() - 1
	vertices.append(mid2)
	var m2: int = vertices.size() - 1
	
	# Create 4 subdivided faces
	return [
		PackedInt32Array([v0, m0, m2]),
		PackedInt32Array([m0, v1, m1]),
		PackedInt32Array([m2, m1, v2]),
		PackedInt32Array([m0, m1, m2])
	]
func generate(subdivisions,radius):
	generate_icosphere()
	var result_faces:Array = []
	var last_it:Array = faces
	for i in subdivisions:
		for face in last_it:
			result_faces += subdivide(face, radius)
		last_it = result_faces
		result_faces = []
	return [last_it, vertices]
