extends Node3D
@export var BlackHole: PackedScene
@export var StarScene: PackedScene
@export var star_count := 100
@export var galaxy_radius := 50.0
@export var disk_thickness := 10.0
@export var central_mass := 1000.0

func _ready() -> void:
	randomize()
	
	# Spawn a central massive body
	var central = BlackHole.instantiate()
	central.mass = central_mass
	central.transform.origin = Vector3.ZERO
	add_child(central)  # no call_deferred here
	central.add_to_group("grav")
	
	# Spawn stars
	for i in range(star_count):
		var star = StarScene.instantiate()
		var r = galaxy_radius * sqrt(randf())
		var angle = randf() * TAU
		var x = r * cos(angle)
		var z = r * sin(angle)
		var y = (randf() - 0.5) * disk_thickness
		
		star.mass = randf_range(0.5, 5.0)
		star.transform.origin = Vector3(x, y, z)
		
		# Give them some initial velocity
		if r > 0.01:
			var G = 6.67430
			var v_mag = sqrt(G * central_mass / r)
			var radial_dir = Vector3(x, 0, z).normalized()
			var tangential_dir = Vector3(-radial_dir.z, 0, radial_dir.x)
			star.linear_velocity = tangential_dir * v_mag * (1 + (randf() - 0.5) * 0.1)
		add_child(star)  # no call_deferred
		#star.add_to_group("grav")
