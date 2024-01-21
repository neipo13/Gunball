extends Node2D

var device : int = 1
var devStr : String:
	get: return str(device)
	
var hand_l : Sprite2D
var hand_r : Sprite2D

var rotationSpring : SpringData

var dragSpring : SpringData

var scaleSpringL : SpringData
var scaleSpringR : SpringData

@export var dragSpringVel : float = 50
@export var scaleSpringVel : float = 100

func setInitializationVars(deviceID:int)->void:
	device = deviceID
	
func _ready() -> void:
	hand_l = get_node("hand_l")
	hand_r = get_node("hand_r")
	rotationSpring = SpringData.new()
	dragSpring = SpringData.new()
	dragSpring.damping = 0.4
	dragSpring.goal = deg_to_rad(35)
	scaleSpringL = SpringData.new()
	scaleSpringL.goal = 1
	scaleSpringL.damping = 0.3
	scaleSpringL.frequency = 30
	scaleSpringR = SpringData.new()
	scaleSpringR.goal = 1
	scaleSpringR.damping = 0.3
	scaleSpringR.frequency = 30
	

func _process(delta:float) -> void:
	var input_direction :Vector2 = Input.get_vector(devStr+"_left", devStr+"_right", devStr+"_up", devStr+"_down")
	if input_direction.length_squared() > 0:
		setRotation(input_direction.angle())
	
	rotationSpring.update(delta)
	rotation = rotationSpring.current
	
	dragSpring.update(delta)
	hand_l.rotation = dragSpring.current
	hand_r.rotation = dragSpring.current
	
	scaleSpringL.update(delta)
	hand_l.scale = Vector2(scaleSpringL.current, scaleSpringL.current)
	scaleSpringR.update(delta)
	hand_r.scale = Vector2(scaleSpringR.current, scaleSpringR.current)
	

func shootLeft()->void:
	scaleSpringL.velocity = scaleSpringVel
func shootRight()->void:
	scaleSpringR.velocity = scaleSpringVel



func setRotation(rot:float) -> void:
	if(rotationSpring.goal > 3 && rot < 0): 
		rotationSpring.current = -PI
		rotationSpring.goal = -PI
	if(rotationSpring.goal < -2.3 && rot > 0): 
		rotationSpring.current = 4 * PI/3
		rotationSpring.goal = 4 * PI/3
	if(rot > rotationSpring.goal): dragSpring.velocity = -dragSpringVel
	if(rot < rotationSpring.goal): dragSpring.velocity = dragSpringVel
	rotationSpring.goal = rot

