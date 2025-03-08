extends Node

func prepare_mesh(faces: Array, points: PackedVector3Array) -> Array:
	var prepared_faces: PackedInt32Array = PackedInt32Array()

	for face_index in range(faces.size()):
		var face = faces[face_index]
		if face.size() == 3:
			prepared_faces.append_array(face)
		else:
			# Split the face and add new faces to the queue
			var result = triangulate(faces.find(face), faces, points)  # Pass dummy face_index
			points = result[0]
			prepared_faces.append_array(result[1])
	
	return [prepared_faces, points]

func get_mid(face_index:int, faces:Array, points:PackedVector3Array) -> Vector3:
	var face:PackedInt32Array = faces[face_index]
	var mid:Vector3 = Vector3(0,0,0)
	for point in face:
		mid += points[point]
	mid = mid / face.size()
	return mid

func triangulate(face_index: int, faces: Array, points: PackedVector3Array) -> Array:
	var face: PackedInt32Array = faces[face_index]
	if face.size() <= 3:
		return [points, faces]  # Already a triangle
	
	var new_faces: Array = []
	var new_points: PackedVector3Array = points
	var center: Vector3 = get_mid(face_index, faces, points)
	var center_index: int = new_points.size()
	new_points.append(center)
	
	# Split the face into triangles radiating from the center
	for i in range(face.size()):
		var next_i: int = wrapi(i + 1, 0, face.size())
		new_faces.append(PackedInt32Array([face[i], face[next_i], center_index]))
	
	# Replace the original face with new triangles
	faces.remove_at(face_index)
	faces.append_array(new_faces)
	return [new_points, faces]

func extrude(face_index:int, faces:Array, points:PackedVector3Array, value:float) -> Array:
	var face:PackedInt32Array = faces[face_index]
	var new_points:PackedVector3Array = PackedVector3Array()
	for index in face:
		new_points.append(points[index] * (value + 1))
	var count = points.size()
	points.append_array(new_points)
	var new_faces:Array = []
	var last_face:PackedInt32Array = PackedInt32Array()
	for i in range(new_points.size()):
		last_face.append(count + i)
	for i in range(face.size()):
		var i_next:int = face[wrapi(i + 1, 0, face.size())]
		var i_val:int = face[i]
		new_faces.append(PackedInt32Array([i_val, i_next, (count + wrapi(i + 1, 0, face.size())), (count + i)]))
	faces.append_array(new_faces)
	faces.append(last_face)
	return [faces, points]

func dual_operator(faces: Array, points: PackedVector3Array):
	var new_faces: Array = []
	var new_points: PackedVector3Array = PackedVector3Array()
	var faces_per_point: Dictionary = {}

	print("Starting dual_operator")
	print("Initial faces: ", faces)
	print("Initial points: ", points)

	# Create a dictionary of faces per point
	for face in faces:
		for index in face:
			index = points[index]
			if not faces_per_point.has(index):
				faces_per_point[index] = [face]
			else:
				faces_per_point[index].append(face)
	print("Faces per point: ", faces_per_point)

	# Create new points at the center of each face
	for face in faces:
		var mid: Vector3 = Vector3(0, 0, 0)
		for index in face:
			mid += points[index]
		mid /= face.size()
		new_points.append(mid)
	print("New points: ", new_points)

	# Create new faces by connecting the new points
	for point in points:
		if faces_per_point.has(point):
			var unordered_faces = faces_per_point[point]
			var ordered_faces = []
			var next_face = unordered_faces.pop_front()
			ordered_faces.append(next_face)
			var i = 0
			while unordered_faces.size() > 0:
				print("Run:", point, "-", i)
				print("unordered_faces before loop:", unordered_faces)
				print("next_face:", next_face)
				var found_next_face = false
				for face in unordered_faces:
					var shared_edges = 0
					for index in face:
						if index in next_face:
							shared_edges += 1
					if shared_edges == 2:
						next_face = face
						ordered_faces.append(face)
						unordered_faces.erase(face)
						print("Found next face:", next_face)
						found_next_face = true
						break
				print("unordered_faces after loop:", unordered_faces)
				if not found_next_face:
					print("No next face found, breaking out of loop")
					break
				i += 1
				if i > 100:  # Safety check to prevent infinite loop
					print("Breaking out of loop to prevent infinite loop")
					break

			var new_face: PackedInt32Array = PackedInt32Array()
			for face in ordered_faces:
				new_face.append(faces.find(face))
			new_faces.append(new_face)
	print("New faces: ", new_faces)

	print("Completed dual_operator")
	return [new_faces, new_points]
