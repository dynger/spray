extends KinematicBody

var moveSpeed : float = 50.0
var jumpForce : float = 100.0
var gravity : float = 15.0

var vel : Vector3 = Vector3()

func _physics_process(delta):
	
	vel.x = 0
	vel.z = 0
	
	var input = Vector3()
	
	if Input.is_action_pressed("ui_up"):
		input.z += 1
	if Input.is_action_pressed("ui_down"):
		input.z -= 1
	if Input.is_action_pressed("ui_left"):
		input.x += 1
	if Input.is_action_pressed("ui_right"):
		input.x -= 1
		
	input = input.normalized()
	
	var dir = (transform.basis.z * input.z + transform.basis.x * input.x)
	
	vel.x = dir.x * moveSpeed
	vel.z = dir.z * moveSpeed
	
	vel.y -= gravity * delta
	
	if Input.is_action_pressed("Jump") and is_on_floor():
		vel.y = jumpForce
		
	vel = move_and_slide(vel, Vector3.UP)
