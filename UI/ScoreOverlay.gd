extends Control



var scaleSpringL : SpringData
var scaleSpringR : SpringData

@export var scaleSpringVel : float = 20
@export var scaleSpringDamp: float = 0.2
@export var scaleSpringFrec: float = 15

var blueScoreText : Label
var orangeScoreText : Label

func _ready() -> void:
	scaleSpringL = SpringData.new()
	scaleSpringL.goal = 1
	scaleSpringL.damping = scaleSpringDamp
	scaleSpringL.frequency = scaleSpringFrec
	scaleSpringR = SpringData.new()
	scaleSpringR.goal = 1
	scaleSpringR.damping = scaleSpringDamp
	scaleSpringR.frequency = scaleSpringFrec
	
	blueScoreText = find_child("BlueScore")
	orangeScoreText = find_child("OrangeScore")
	
func _process(delta:float) -> void:
	scaleSpringL.update(delta)
	var lscale:float = max(0, scaleSpringL.current)
	blueScoreText.scale = Vector2(lscale, lscale)
	var rscale:float = max(0, scaleSpringR.current)
	scaleSpringR.update(delta)
	orangeScoreText.scale = Vector2(rscale, rscale)
	
	
func blueScore(val:int)->void:
	scaleSpringL.velocity = scaleSpringVel
	blueScoreText.text = str(val)
	
func orangeScore(val:int)->void:
	scaleSpringR.velocity = scaleSpringVel
	orangeScoreText.text = str(val)
