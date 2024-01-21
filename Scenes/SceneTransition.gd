extends CanvasLayer


var duration : float = 0.75

var targetScene:String
var tween:Tween

func ChangeScene(target:String) -> void:
	if(targetScene==target): return
	targetScene=target
	
	$Changer.material.set_shader_parameter("in_out", 1.0)
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property($Changer.material, "shader_parameter/position", -1.5, duration).from(1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_callback(SceneChanged)


func SceneChanged()->void:
	get_tree().change_scene_to_file(targetScene)
	
	$Changer.material.set_shader_parameter("in_out", 0.0)
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property($Changer.material, "shader_parameter/position", 1.0, duration).from(-1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
