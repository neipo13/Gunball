extends CharacterBody2D


@export var device : int = 1
@export var max_speed : float = 150
@export var acceleration : float = 250
@export var friction : float = 600
@export var teamColor : Color
@export var state:PlayerState = PlayerState.normal
@export var stunTime:float = 0.8
@export var stunSpinModifier:float = 24
@export var stunMoveSpeed:float = 400
@export var stunFriction:float = 300.0

var stunDirection:Vector2
var stunTimer:float = -1

enum  PlayerState{
	normal,
	stunned,
	menu
}

var devStr : String:
	get: return str(device)
	
# stored info for shooting
var l_hand : Node2D
var r_hand : Node2D
var body : Node2D
var handRotator : Node2D
var mostRecentDirection : Vector2 = Vector2(1.0,0.0) #default to aim right as thats the default for the hands
const BULLET = preload("res://Bullet/bullet.tscn")

@export var reloadTime : float = 0.6

var leftReloadTimer : float = -1.0
var rightReloadTimer : float = -1.0
var leftCanShoot : bool :
	get:
		return leftReloadTimer <= 0.0
var rightCanShoot : bool :
	get:
		return rightReloadTimer <= 0.0
		
func setInitializationVars(deviceID:int, color:Color)->void:
	device = deviceID
	teamColor = color

func setColor():
	(body as Sprite2D).modulate = teamColor
	(l_hand as Sprite2D).modulate = teamColor
	(r_hand as Sprite2D).modulate = teamColor
	

func _ready() -> void:
	l_hand = get_node("Sprites/Hands/hand_l")
	r_hand = get_node("Sprites/Hands/hand_r")
	handRotator = get_node("Sprites/Hands")
	handRotator.call("setInitializationVars", device)
	body = get_node("Sprites/Body")
	
	setColor()
	
	set_collision_mask_value(8 + device, false)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta:float) -> void:
	match state:
		PlayerState.normal:
			move(delta)
			checkShootL(delta)
			checkShootR(delta)
		PlayerState.stunned:
			stunMove(delta)

func get_hit(dir:Vector2)->void:
	stunDirection=dir.normalized()
	SetStunState()
	SoundManager.PlaySfx("player_hit")
			
func SetNormalState()->void:
	state = PlayerState.normal
func SetMenuState()->void:
	state = PlayerState.menu

func EndNormal()->void:
	pass

func SetStunState()->void:
	state = PlayerState.stunned
	stunTimer = stunTime
	velocity = stunDirection * stunMoveSpeed
	$Sprites/Body/AnimationPlayer.play("hitflash")

func EndStun()->void:
	body.rotation = 0.0
	velocity = Vector2.ZERO

func stunMove(delta:float) -> void:
	velocity = Math.approachVec2(velocity, Vector2.ZERO, stunFriction * delta)
	move_and_slide()
	body.rotation += delta * stunSpinModifier
	stunTimer -= delta
	if stunTimer < 0:
		EndStun()
		SetNormalState()
	

func move(delta:float) -> void:
	var input_direction : Vector2 = Input.get_vector(devStr+"_left", devStr+"_right", devStr+"_up", devStr+"_down")
	input_direction *= max_speed
	if not input_direction.length_squared() > 0.0 && velocity.length_squared() > 0.0:
		velocity = Math.approachVec2(velocity, Vector2.ZERO, friction * delta)
	else:
		velocity = Math.approachVec2(velocity, input_direction, acceleration * delta)
		mostRecentDirection = input_direction.normalized()
	
	move_and_slide()

func checkShootL(delta:float) -> void:
	if(leftReloadTimer > 0):
		leftReloadTimer -= delta
	if(Input.is_action_just_pressed(devStr+"_shoot_l") && leftCanShoot):
		shoot(l_hand)
		handRotator.call("shootLeft")
		leftReloadTimer = reloadTime
	pass
	
func checkShootR(delta:float) -> void:
	if(rightReloadTimer > 0):
		rightReloadTimer -= delta
	if(Input.is_action_just_pressed(devStr+"_shoot_r") && rightCanShoot):
		shoot(r_hand)
		handRotator.call("shootRight")
		rightReloadTimer = reloadTime
	pass
	
func shoot(b:Node2D) -> void:
	var bullet : RigidBody2D = BULLET.instantiate()
	bullet.global_position = b.global_position
	bullet.global_rotation = handRotator.global_rotation
	bullet.set_collision_layer_value(8+device, true)
	bullet.call("setDirection")
	bullet.call("setColor", teamColor)
	get_tree().current_scene.add_child(bullet)
	SoundManager.PlaySfx("shoot")

