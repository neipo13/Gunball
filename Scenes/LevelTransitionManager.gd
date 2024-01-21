extends Node

@export var inputWaitTime : float = 1.0

var transitioning : bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta:float) -> void:
	#first check for escape sequence, that is always primary
	if(!transitioning && Input.is_action_just_pressed("Escape")):
		transitioning = true
		SoundManager.PlaySfx("escape")
		get_tree().quit()
	# first we have to wait till we are good to transition 
	if(inputWaitTime > 0):
		inputWaitTime -= delta
		return
	
	# then if we get past that we can just check for any action pressed
	if(!transitioning && Input.is_anything_pressed()):
		transitioning = true
		SoundManager.PlaySfx("confirm")
		SceneTransition.ChangeScene("res://UI/TeamSelect.tscn")
		
