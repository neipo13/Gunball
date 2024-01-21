extends Area2D

var bodies : Array[Node2D]

@export var blueTeam : bool = false

var orangeTeam : bool : 
	get: return !blueTeam


var scoreParticles : Resource = preload("res://Ball/goalExplosionParticles.tscn")

var distortionPlayer : AnimationPlayer
var distortionRect : ColorRect

func _ready() -> void:	
	distortionPlayer = get_tree().current_scene.find_child("DistortionPlayer")
	distortionRect = get_tree().current_scene.find_child("DistortionRect")
#check for ball in net
func _on_body_entered(body:Node2D) -> void:	
	bodies.append(body)
	pass # Replace with function body.
	
func _on_body_exited(body:Node2D) -> void:
	bodies.erase(body)
	pass # Replace with function body.

func checkForEnclosure(body:Node2D) -> bool:
	var rad:float = body.get_node('CollisionShape2D').shape.radius
	var body_extents:Vector2 = Vector2(rad*2, rad*2)
	var areaShape:CollisionShape2D =get_node('CollisionShape2D')
	var area_extents:Vector2 = areaShape.shape.extents
	var body_rect:Rect2= Rect2(body.global_position - body_extents, body_extents * 2)
	var area_rect:Rect2 = Rect2(areaShape.global_position - area_extents, area_extents * 2)
	if area_rect.encloses(body_rect):
		return true
	return false


func _physics_process(_delta: float) -> void:
	if bodies.size() == 0:
		return
	for item in bodies:
		var yep : bool = checkForEnclosure(item)
		if(yep):
			HitstopManager.hit_stop_short()
			ScreenshakeManager.ShakeRandom(900)
			var particles : Node2D = scoreParticles.instantiate()
			if blueTeam:
				particles.modulate = Palette.ORANGE
				particles.rotation = 0
			elif orangeTeam:
				particles.modulate = Palette.BLUE
				particles.rotation_degrees = 180
			get_tree().current_scene.add_child(particles)
			particles.global_position = item.global_position
			distortionPlayer.play("distort")
			var canvasInfo:Vector2 = distortionRect.size
			distortionRect.material.set_shader_parameter("center", item.get_global_transform_with_canvas().origin/canvasInfo)
			var mgmr:Node = get_tree().current_scene.find_child("GameManager")
			if blueTeam: mgmr.call("OrangeScored")
			if orangeTeam: mgmr.call("BlueScored")
			item.queue_free()

