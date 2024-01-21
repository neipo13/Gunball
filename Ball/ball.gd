extends RigidBody2D

@onready var hitflashPlayer : AnimationPlayer = $HitflashPlayer
@onready var sprite : Sprite2D = $Sprite2D

var scaleSpringR : SpringData

@export var scaleSpringVel : float = 10
@export var scaleSpringDamp: float = 0.3
@export var scaleSpringFrec: float = 15



func _ready()->void:
	scaleSpringR = SpringData.new()
	scaleSpringR.goal = sprite.scale.x #assume same x & y scale
	scaleSpringR.damping = scaleSpringDamp
	scaleSpringR.frequency = scaleSpringFrec
	
func _process(delta:float)->void:
	scaleSpringR.update(delta)
	sprite.scale = Vector2(scaleSpringR.current, scaleSpringR.current)
	
func get_hit(_dir:Vector2) -> void:
	hitflashPlayer.play("hitflash")
	scaleSpringR.velocity = scaleSpringVel


func _on_body_entered(body:Node2D)->void:
	#check if other body is a player
	if body is CharacterBody2D:
		body.call("get_hit", linear_velocity.normalized())
		linear_velocity = Vector2.ZERO
		HitstopManager.hit_stop_mid()
