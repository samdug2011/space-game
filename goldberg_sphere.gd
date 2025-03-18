extends MeshInstance3D

# Constants for the Goldberg sphere
const FREQUENCY = 3
const RADIUS = 1.0

func _ready():
	var data = generate_goldberg_sphere(FREQUENCY, RADIUS)
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[Mesh.ARRAY_VERTEX] = PackedVector3Array(data[0])
	surface_array[Mesh.ARRAY_NORMAL] = PackedVector3Array(data[1])
	surface_array[Mesh.ARRAY_TEX_UV] = PackedVector2Array(data[2])
	surface_array[Mesh.ARRAY_INDEX] = PackedInt32Array(data[3])
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)

func generate_goldberg_sphere(frequency: int, radius: float) -> Array:
	var vertices = []
	var indices = []
	var normals = []
	var uvs = []

	# Generate vertices and faces for the Goldberg sphere
	# This is a simplified version and may need further refinement
	for i in range(frequency):
		for j in range(frequency):
			var theta = float(i) / float(frequency) * PI * 2.0
			var phi = float(j) / float(frequency) * PI
			var x = radius * sin(phi) * cos(theta)
			var y = radius * sin(phi) * sin(theta)
			var z = radius * cos(phi)
			vertices.append(Vector3(x, y, z))
			normals.append(Vector3(x, y, z).normalized())
			uvs.append(Vector2(float(i) / float(frequency), float(j) / float(frequency)))

	# Generate indices for the triangles
	for i in range(frequency - 1):
		for j in range(frequency - 1):
			var a = i * frequency + j
			var b = a + 1
			var c = a + frequency
			var d = c + 1
			indices.append(a)
			indices.append(b)
			indices.append(c)
			indices.append(b)
			indices.append(d)
			indices.append(c)

	return [vertices, normals, uvs, indices]
