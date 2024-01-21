extends Node

var xSpring : SpringData
var ySpring : SpringData

var shakeMagnitude : float  = 250
var damping : float = 0.75
var frequency : float = 12

var cam : Camera2D :
	get:
		return get_viewport().get_camera_2d()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	xSpring = SpringData.new()
	xSpring.damping = damping
	xSpring.goal = 0
	xSpring.frequency = frequency
	ySpring = SpringData.new()
	ySpring.damping = damping
	ySpring.goal = 0
	ySpring.frequency = frequency	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta:float) -> void:
	if cam == null:
		return
	xSpring.update(delta)
	ySpring.update(delta)
	
	cam.offset = Vector2(xSpring.current, ySpring.current)

func ShakeDir(direction:Vector2) -> void:
	xSpring.velocity = shakeMagnitude * direction.x
	ySpring.velocity = shakeMagnitude * direction.y
	
func ShakeRandom(mag:float) -> void:
	var x:float= randf_range(-1, 1)
	var y:float = randf_range(-1, 1)
	ShakeMag(Vector2(x, y), mag)
	
	
func ShakeMag(direction:Vector2, mag:float) -> void:
	direction = direction.normalized()
	xSpring.velocity = mag * direction.x
	ySpring.velocity = mag * direction.y
