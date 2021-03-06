extends Spatial

var lookSensitivity : float = 5.0
var minAngle : float = -18
var maxAngle : float = 45.0

var mouseDelta : Vector2 = Vector2()

onready var player = get_parent()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Input.warp_mouse_position(Vector2(960,540))

func _input(event):
	if event is InputEventMouseMotion:
		mouseDelta = event.relative

func _process(delta):

	var rot = Vector3(mouseDelta.y, mouseDelta.x, 0) * lookSensitivity * delta
	
	rotation_degrees.x += rot.x
	rotation_degrees.x = clamp(rotation_degrees.x, minAngle, maxAngle)
	
	player.rotation_degrees.y -= rot.y
	
	mouseDelta = Vector2()
	
	
