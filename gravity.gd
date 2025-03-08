extends RigidBody3D
@export var central_body:RigidBody3D
var G = 6.67430  # Gravitational constant
var grav_bodies:Array
func _ready() -> void:
	'''for sibling in get_tree().get_children():
		if sibling.is_in_group("grav"):
			grav_bodies.append(sibling)'''
	for i in get_tree().get_nodes_in_group("grav"):
		grav_bodies.append(i)
func _physics_process(delta):
	apply_gravity(delta)
func apply_gravity(delta):
	var acceleration = Vector3()  # Reset acceleration each frame
	
	for obj in grav_bodies:
		if obj != self:
			var direction = global_transform.origin.direction_to(obj.global_transform.origin)
			var distance_sq = global_transform.origin.distance_squared_to(obj.global_transform.origin)
			
			if distance_sq < 0.01:  # Prevents division by very small numbers
				continue  # Skip applying gravity if bodies are too close

			# Compute acceleration due to gravity: a = G * m2 / r^2
			var accel = direction * G * obj.mass / distance_sq
			acceleration += accel  # Sum acceleration from all objects

	# Apply acceleration to velocity
	linear_velocity += acceleration * delta  # a * dt = Δv
