extends RichTextLabel

@export var speed : float = 5.0
@export var fade : bool = false

var time:float= 0
var sinTime:float= 0


# Called when the node enters the scene tree for the first time.
func flashText() -> void:
	if !fade:
		pass
	modulate.a = (sinTime + 1) / 2.0
	pass

func _process(delta:float) -> void:
	time += delta
	sinTime = sin(time*speed)
	flashText()
