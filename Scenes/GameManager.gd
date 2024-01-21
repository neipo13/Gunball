extends Node

#holds game-relevant info
#updates score
#counts up the time
#checks for winners
var seconds : float = 0
var orangePoints : int = 0
var bluePoints : int = 0

var postWinTimer:float = 5.0

var winningTeam : int = 0

var OrangeWon : int = -1
var BlueWon : int = 1

const BALL_INFO = preload("res://Ball/ball.tscn")
const PLAYER_INFO = preload("res://Player/player.tscn")
const GAME_TEXT_INFO = preload("res://UI/GameOverPopup.tscn")

const SQUARE_BODY = preload("res://Player/img/purple_body_square.png")
const DIAMOND_BODY = preload("res://Player/img/body_diamond.png")
const TRIANGLE_BODY = preload("res://Player/img/body_triangle.png")
const PARRALLELOGRAM_BODY = preload("res://Player/img/body_parallelogram.png")

var ScoreOverlay:Node

var players : Array[Node] = []

#populates level & players lists based on SettingsManager info
func _ready() -> void:
	SoundManager.PlayGameMusic()
	#DEBUG -- if both teams are empty just put p1 on blue & p2 on orange
	if(SettingsManager.BlueTeam.size() == 0 && SettingsManager.OrangeTeam.size() == 0):
		SettingsManager.BlueTeam.append(1)
		SettingsManager.OrangeTeam.append(2)
		
		#SettingsManager.BlueTeam.append(3)
		#SettingsManager.OrangeTeam.append(4)
	# load the blue team
	var teamPlayerNumber:int = 1
	for pid in SettingsManager.BlueTeam:
		var player:Node2D = PLAYER_INFO.instantiate()
		player.name = "player"+str(pid)
		var spawnPos: Vector2 = (get_tree().current_scene.find_child("Blue"+str(teamPlayerNumber)) as Node2D).position
		player.global_position = spawnPos
		player.call("setInitializationVars", pid, Palette.BLUE)
		get_tree().current_scene.add_child.call_deferred(player)
		players.append(player)
		var spr : Sprite2D = player.find_child("Body")
		spr.set_texture(PickTexture(pid))
		teamPlayerNumber+=1
	# load the orange team
	teamPlayerNumber = 1
	for pid in SettingsManager.OrangeTeam:
		var player:Node2D = PLAYER_INFO.instantiate()
		player.name = "player"+str(pid)
		var spawnPos: Vector2 = (get_tree().current_scene.find_child("Orange"+str(teamPlayerNumber)) as Node2D).position
		player.global_position = spawnPos
		player.call("setInitializationVars", pid, Palette.ORANGE)
		get_tree().current_scene.add_child.call_deferred(player)
		players.append(player)
		var spr : Sprite2D = player.find_child("Body")
		spr.set_texture(PickTexture(pid))
		teamPlayerNumber+=1
	# spawn in ball(s)
	RespawnBall(PickRandomRespawn())
	
	#get/hold refs to ScoreUI labels
	ScoreOverlay = get_tree().current_scene.find_child("ScoreOverlay")
	
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

func _process(delta:float) -> void:
	CheckEsc()
	if(winningTeam != 0):
		postWinTimer-=delta
		if(postWinTimer>0):return
		SceneTransition.ChangeScene("res://Scenes/Title.tscn")
		return
	if(SettingsManager.maxTimeSeconds > 0):
		if(seconds >= SettingsManager.maxTimeSeconds):
			print("TIME UP")
			if(orangePoints == bluePoints):
				print("OT")
				# set some OT indicator to change the seconds display to OT
			if orangePoints > bluePoints:
				print("ORANGE WINS")
				winningTeam = OrangeWon
			GameOver()
			if bluePoints > orangePoints:
				print("BLUE WINS")
				winningTeam = BlueWon
			GameOver()
			return
			
	seconds += delta
	if(SettingsManager.maxScore > 0 ):
		if orangePoints >= SettingsManager.maxScore:
			print("ORANGE WINS")
			winningTeam = OrangeWon
			GameOver()
		if bluePoints >= SettingsManager.maxScore:
			print("BLUE WINS")
			winningTeam = BlueWon
			GameOver()
			
func GameOver() -> void:
	SoundManager.PlaySfx("cheer")
	SoundManager.PlaySfx("game_end")
	#remove control from the players
	for p in players:
		p.set_script(null)
	#popup Game 
	var txt:Control = GAME_TEXT_INFO.instantiate()
	var winningColor:Color = Palette.ORANGE
	if winningTeam == BlueWon: winningColor = Palette.BLUE
	txt.modulate = winningColor
	get_tree().current_scene.add_child.call_deferred(txt)

func CheckEsc() -> void:
	if Input.is_action_just_pressed("Escape"):
		SoundManager.PlaySfx("escape")
		SceneTransition.ChangeScene("res://Scenes/Title.tscn")
		
func OrangeScored() -> void:	
	if(winningTeam != 0):
		return
	orangePoints += 1
	SoundManager.PlaySfx("goal1")
	SoundManager.PlaySfx("cheer2")
	ScoreOverlay.call("orangeScore", orangePoints)
	RespawnBall(PickRandomRespawn())

func BlueScored() -> void:
	if(winningTeam != 0):
		return
	bluePoints += 1
	SoundManager.PlaySfx("goal1")
	SoundManager.PlaySfx("cheer2")
	ScoreOverlay.call("blueScore", bluePoints)
	RespawnBall(PickRandomRespawn())

func PickRandomRespawn() -> Vector2:
	return Vector2.ZERO

func RespawnBall(location:Vector2) -> void:	
	#wait
	await get_tree().create_timer(SettingsManager.ballRespawnTime).timeout
	#dont spawn if someone already won
	if(winningTeam != 0):
		return
	#find spawn points & select 1
	#spawn ball at point
	var ball:Node2D = BALL_INFO.instantiate()
	ball.global_position = location
	get_tree().current_scene.add_child.call_deferred(ball)
	SoundManager.PlaySfx("spawn")
