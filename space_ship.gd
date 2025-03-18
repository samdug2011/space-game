extends CharacterBody3D

@export var max_speed: float = 50.0
@export var acceleration = 0.9
@export var rotate_speed = 0.9
@export var mouse_sensitivity : float = 0.001
var target = null
signal speed_changed

var mouseInput : Vector2 = Vector2(0,0)


var forward_speed = 0
var rotation_z = 0
func _ready():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
func _unhandled_input(event : InputEvent):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouseInput.x += event.relative.x
		mouseInput.y += event.relative.y


func get_input(delta):
	if Input.is_action_pressed("throttle_up"):
		forward_speed += acceleration*delta
	if Input.is_action_pressed("throttle_down"):
		forward_speed -= 3*acceleration*delta
	if Input.is_action_pressed("rotate_z_-"):
		rotation_z = -rotate_speed*delta
	if Input.is_action_pressed("rotate_z_+"):
		rotation_z = rotate_speed*delta
	if Input.is_action_pressed("target"):
		$RayCast3D.force_raycast_update()
		var collider = $RayCast3D.get_collider()
		target = collider
	if Input.is_action_just_pressed("esc_mouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	forward_speed = clamp(forward_speed, 0, max_speed)
	if forward_speed < 0:
		forward_speed = 0

func _physics_process(delta):
	get_input(delta)
	if target:
		look_at(target)
	else:
		transform.basis = transform.basis.rotated(transform.basis.y.normalized(), mouseInput.x * mouse_sensitivity)
		transform.basis = transform.basis.rotated(transform.basis.x.normalized(), -mouseInput.y * mouse_sensitivity)
		transform.basis = transform.basis.rotated(transform.basis.z.normalized(), rotation_z)
	velocity = transform.basis.z * forward_speed
	speed_changed.emit(forward_speed)
	mouseInput = Vector2(0,0)
	rotation_z = 0
	move_and_collide(velocity * delta)
