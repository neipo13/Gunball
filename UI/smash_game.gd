extends Label

var xScaleSpring : SpringData
var yScaleSpring : SpringData

func _ready() -> void:	
	xScaleSpring = SpringData.new()
	xScaleSpring.goal = 1
	xScaleSpring.damping = 0.15
	xScaleSpring.frequency = 30
	
	yScaleSpring = SpringData.new()
	yScaleSpring.goal = 1
	yScaleSpring.damping = 0.2
	yScaleSpring.frequency = 15
	
func  _process(delta:float) -> void:
	xScaleSpring.update(delta)
	scale.x = xScaleSpring.current
	
	yScaleSpring.update(delta)
	scale.y = yScaleSpring.current
