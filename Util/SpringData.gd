class_name SpringData

@export var damping : float = 0.8
@export var frequency : float = 20

var velocity : float
var current : float
var goal : float

var OnChange : Callable
	
func update(delta:float) -> void:
	var newInfo:Vector2= DampedSpring.CalcDampedSimpleHarmonicMotion(current, velocity, goal, delta, frequency, damping)
	current = newInfo.x
	velocity = newInfo.y
	if not OnChange.is_null(): OnChange.call(self)
