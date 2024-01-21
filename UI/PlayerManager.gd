extends Node

@onready var progressBar = $"Top/ProgressBar"
@onready var btnAnimator = $"Top/Btn/BtnAnimator"
@onready var minPlayers = $Top/MinPlayers

const SQUARE_BODY = preload("res://Player/img/purple_body_square.png")
const DIAMOND_BODY = preload("res://Player/img/body_diamond.png")
const TRIANGLE_BODY = preload("res://Player/img/body_triangle.png")
const PARRALLELOGRAM_BODY = preload("res://Player/img/body_parallelogram.png")

@export var ReadyTime:float = 2.0

var readyTimer:float = 0.0

var pitchMin = 0.5
var pitchMax = 2

var transitionStarted:bool=false
var teamsValid:bool = false

var p1:Node2D
var p2:Node2D
var p3:Node2D
var p4:Node2D

var p1_location:Location = Location.Middle
var p2_location:Location = Location.Middle
var p3_location:Location = Location.Middle
var p4_location:Location = Location.Middle

var p1PositionSpring:SpringData
var p2PositionSpring:SpringData
var p3PositionSpring:SpringData
var p4PositionSpring:SpringData

enum Location{
	Left,
	Middle,
	Right
}

const playerPrefab:Resource = preload("res://Player/player.tscn")
const middleColor:Color = Color.DIM_GRAY

func _ready()->void:
	SoundManager.PlayTeamSelect()
	progressBar.visible=false
	progressBar.value=0
	btnAnimator.play("loop")
	p1PositionSpring= SpringData.new()
	p1PositionSpring.frequency = 10
	p1PositionSpring.damping = 0.6
	p2PositionSpring= SpringData.new()
	p2PositionSpring.frequency = 10
	p2PositionSpring.damping = 0.6
	p3PositionSpring= SpringData.new()
	p3PositionSpring.frequency = 10
	p3PositionSpring.damping = 0.6
	p4PositionSpring= SpringData.new()
	p4PositionSpring.frequency = 10
	p4PositionSpring.damping = 0.6
	readyTimer = ReadyTime
	minPlayers.visible = false
	SettingsManager.BlueTeam.clear()
	SettingsManager.OrangeTeam.clear()

func _process(delta:float)->void:
	ListenForEscape()
	ListenForJoin()
	ListenForMove()
	ListenForReady(delta)
	UpdatePositionSprings(delta)

func SetupPlayer(player:Node2D):
	player.call("SetMenuState")

func ListenForJoin()->void:
	if(p1 == null && Input.is_action_just_pressed("1_shoot_l")):
		SoundManager.PlaySfx("spawn")
		p1PositionSpring.goal = $Middle/P1.global_position.x
		p1PositionSpring.current = p1PositionSpring.goal
		p1 = playerPrefab.instantiate()
		p1.global_position = $Middle/P1.global_position
		p1.call("setInitializationVars", 1, middleColor)
		SetupPlayer(p1)
		get_tree().current_scene.add_child(p1)
		p1.global_position = $Middle/P1.global_position
		var spr : Sprite2D = p1.find_child("Body")
		spr.set_texture(PickTexture(1))
	if(p2 == null && Input.is_action_just_pressed("2_shoot_l")):
		SoundManager.PlaySfx("spawn")
		p2PositionSpring.goal = $Middle/P2.global_position.x
		p2PositionSpring.current = p2PositionSpring.goal
		p2 = playerPrefab.instantiate()
		p2.global_position = $Middle/P2.global_position
		p2.call("setInitializationVars", 2, middleColor)
		SetupPlayer(p2)
		get_tree().current_scene.add_child(p2)
		p2.global_position = $Middle/P2.global_position
		var spr : Sprite2D = p2.find_child("Body")
		spr.set_texture(PickTexture(2))
	if(p3 == null && Input.is_action_just_pressed("3_shoot_l")):
		SoundManager.PlaySfx("spawn")
		p3PositionSpring.goal = $Middle/P3.global_position.x
		p3PositionSpring.current = p3PositionSpring.goal
		p3 = playerPrefab.instantiate()
		p3.global_position = $Middle/P3.global_position
		p3.call("setInitializationVars", 3, middleColor)
		SetupPlayer(p3)
		get_tree().current_scene.add_child(p3)
		p3.global_position = $Middle/P3.global_position
		var spr : Sprite2D = p3.find_child("Body")
		spr.set_texture(PickTexture(3))
	if(p4 == null && Input.is_action_just_pressed("4_shoot_l")):
		SoundManager.PlaySfx("spawn")
		p4PositionSpring.goal = $Middle/P4.global_position.x
		p4PositionSpring.current = p4PositionSpring.goal
		p4 = playerPrefab.instantiate()
		p4.global_position = $Middle/P4.global_position
		p4.call("setInitializationVars", 4, middleColor)
		SetupPlayer(p4)
		get_tree().current_scene.add_child(p4)
		p4.global_position = $Middle/P4.global_position
		var spr : Sprite2D = p4.find_child("Body")
		spr.set_texture(PickTexture(4))

func PickTexture(id:int)->Resource:
	if(id == 1):
		return SQUARE_BODY
	if(id == 2):
		return DIAMOND_BODY
	if(id == 3):
		return TRIANGLE_BODY
	if(id == 4):
		return PARRALLELOGRAM_BODY
	return SQUARE_BODY

func ListenForMove()->void:
	if(p1 != null):
		var a1_l:float = Input.is_action_just_pressed("1_left")
		var a1_r:float = Input.is_action_just_pressed("1_right")
		if(a1_l && p1_location == Location.Right):
			SoundManager.PlaySfx("team_change")
			p1_location = Location.Middle
			p1PositionSpring.goal = $Middle/P1.global_position.x
			p1.call("setInitializationVars", 1, middleColor)
			p1.call("setColor")
			SettingsManager.OrangeTeam.erase(1)
		elif(a1_l && p1_location == Location.Middle):
			SoundManager.PlaySfx("team_change")
			p1_location = Location.Left
			p1PositionSpring.goal = $Left/P1.global_position.x
			p1.call("setInitializationVars", 1, Palette.BLUE)
			p1.call("setColor")
			SettingsManager.BlueTeam.append(1)
			teamsValid = true
			minPlayers.visible = false
		elif(a1_r && p1_location == Location.Left):
			SoundManager.PlaySfx("team_change")
			p1_location = Location.Middle
			p1PositionSpring.goal = $Middle/P1.global_position.x
			p1.call("setInitializationVars", 1, middleColor)
			p1.call("setColor")
			SettingsManager.BlueTeam.erase(1)
		elif(a1_r && p1_location == Location.Middle):
			SoundManager.PlaySfx("team_change")
			p1_location = Location.Right
			p1PositionSpring.goal = $Right/P1.global_position.x
			p1.call("setInitializationVars", 1, Palette.ORANGE)
			p1.call("setColor")
			SettingsManager.OrangeTeam.append(1)
			teamsValid = true
			minPlayers.visible = false
	if(p2 != null):
		var a2_l:float = Input.is_action_just_pressed("2_left")
		var a2_r:float = Input.is_action_just_pressed("2_right")
		if(a2_l && p2_location == Location.Right):
			SoundManager.PlaySfx("team_change")
			p2_location = Location.Middle
			p2PositionSpring.goal = $Middle/P2.global_position.x
			p2.call("setInitializationVars", 2, middleColor)
			p2.call("setColor")
			SettingsManager.OrangeTeam.erase(2)
		elif(a2_l && p2_location == Location.Middle):
			SoundManager.PlaySfx("team_change")
			p2_location = Location.Left
			p2PositionSpring.goal = $Left/P2.global_position.x
			p2.call("setInitializationVars", 2, Palette.BLUE)
			p2.call("setColor")
			SettingsManager.BlueTeam.append(2)
			teamsValid = true
			minPlayers.visible = false
		elif(a2_r && p2_location == Location.Left):
			SoundManager.PlaySfx("team_change")
			p2_location = Location.Middle
			p2PositionSpring.goal = $Middle/P2.global_position.x
			p2.call("setInitializationVars", 2, middleColor)
			p2.call("setColor")
			SettingsManager.BlueTeam.erase(2)
		elif(a2_r && p2_location == Location.Middle):
			SoundManager.PlaySfx("team_change")
			p2_location = Location.Right
			p2PositionSpring.goal = $Right/P2.global_position.x
			p2.call("setInitializationVars", 2, Palette.ORANGE)
			p2.call("setColor")
			SettingsManager.OrangeTeam.append(2)
			teamsValid = true
			minPlayers.visible = false
	if(p3 != null):
		var a3_l:float = Input.is_action_just_pressed("3_left")
		var a3_r:float = Input.is_action_just_pressed("3_right")
		if(a3_l && p3_location == Location.Right):
			SoundManager.PlaySfx("team_change")
			p3_location = Location.Middle
			p3PositionSpring.goal = $Middle/P3.global_position.x
			p3.call("setInitializationVars", 3, middleColor)
			p3.call("setColor")
			SettingsManager.OrangeTeam.erase(3)
		elif(a3_l && p3_location == Location.Middle):
			SoundManager.PlaySfx("team_change")
			p3_location = Location.Left
			p3PositionSpring.goal = $Left/P3.global_position.x
			p3.call("setInitializationVars", 3, Palette.BLUE)
			p3.call("setColor")
			SettingsManager.BlueTeam.append(3)
			teamsValid = true
			minPlayers.visible = false
		elif(a3_r && p3_location == Location.Left):
			SoundManager.PlaySfx("team_change")
			p3_location = Location.Middle
			p3PositionSpring.goal = $Middle/P3.global_position.x
			p3.call("setInitializationVars", 3, middleColor)
			p3.call("setColor")
			SettingsManager.BlueTeam.erase(3)
		elif(a3_r && p3_location == Location.Middle):
			SoundManager.PlaySfx("team_change")
			p3_location = Location.Right
			p3PositionSpring.goal = $Right/P3.global_position.x
			p3.call("setInitializationVars", 3, Palette.ORANGE)
			p3.call("setColor")
			SettingsManager.OrangeTeam.append(3)
			teamsValid = true
			minPlayers.visible = false
	
	if(p4 != null):
		var a4_l:float = Input.is_action_just_pressed("4_left")
		var a4_r:float = Input.is_action_just_pressed("4_right")
		if(a4_l && p4_location == Location.Right):
			SoundManager.PlaySfx("team_change")
			p4_location = Location.Middle
			p4PositionSpring.goal = $Middle/P4.global_position.x
			p4.call("setInitializationVars", 4, middleColor)
			p4.call("setColor")
			SettingsManager.OrangeTeam.erase(4)
		elif(a4_l && p4_location == Location.Middle):
			SoundManager.PlaySfx("team_change")
			p4_location = Location.Left
			p4PositionSpring.goal = $Left/P4.global_position.x
			p4.call("setInitializationVars", 4, Palette.BLUE)
			p4.call("setColor")
			SettingsManager.BlueTeam.append(4)
			teamsValid = true
			minPlayers.visible = false
		elif(a4_r && p4_location == Location.Left):
			SoundManager.PlaySfx("team_change")
			p4_location = Location.Middle
			p4PositionSpring.goal = $Middle/P4.global_position.x
			p4.call("setInitializationVars", 4, middleColor)
			p4.call("setColor")
			SettingsManager.BlueTeam.erase(4)
		elif(a4_r && p4_location == Location.Middle):
			SoundManager.PlaySfx("team_change")
			p4_location = Location.Right
			p4PositionSpring.goal = $Right/P4.global_position.x
			p4.call("setInitializationVars", 4, Palette.ORANGE)
			p4.call("setColor")
			SettingsManager.OrangeTeam.append(4)
			teamsValid = true
			minPlayers.visible = false

func UpdatePositionSprings(delta:float)->void:
	if(p1 != null):
		p1PositionSpring.update(delta)
		p1.global_position.x=p1PositionSpring.current
	if(p2 != null):
		p2PositionSpring.update(delta)
		p2.global_position.x=p2PositionSpring.current
	if(p3 != null):
		p3PositionSpring.update(delta)
		p3.global_position.x=p3PositionSpring.current
	if(p4 != null):
		p4PositionSpring.update(delta)
		p4.global_position.x=p4PositionSpring.current
		
func ListenForReady(delta:float)->void:
	if (teamsValid && p1 != null && p1_location != Location.Middle && Input.is_action_pressed("1_shoot_l") || p2 != null && p2_location != Location.Middle && Input.is_action_pressed("2_shoot_l") || p3 != null && p3_location != Location.Middle && Input.is_action_pressed("3_shoot_l") || p4 != null && p4_location != Location.Middle && Input.is_action_pressed("4_shoot_l")):
		readyTimer -= delta
		progressBar.visible=true
		progressBar.value = ((ReadyTime-readyTimer)/ReadyTime)*100
		#SoundManager.PlaySfxPitched("confirm", (((ReadyTime-readyTimer)/ReadyTime) * (pitchMax - pitchMin)) + pitchMin)
		if readyTimer < 0 && not transitionStarted:
			if(SettingsManager.OrangeTeam.size() == 0 || SettingsManager.BlueTeam.size() == 0):
				if not teamsValid: return
				teamsValid = false
				minPlayers.visible = true
				return
			SoundManager.PlaySfx("confirm")
			transitionStarted = true
			SceneTransition.ChangeScene("res://Scenes/Game.tscn")
	elif readyTimer < ReadyTime:
		readyTimer+=delta
		progressBar.value = ((ReadyTime-readyTimer)/ReadyTime)*100
	else:
		readyTimer=ReadyTime
		progressBar.visible=false
			
func ListenForEscape():
	if Input.is_action_just_pressed("Escape"):
		SoundManager.PlaySfx("escape")
		SceneTransition.ChangeScene("res://Scenes/Title.tscn")



