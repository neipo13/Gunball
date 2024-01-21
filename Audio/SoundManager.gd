extends Node


@export var SoundEffects:Array[Resource]
@export var MainMenuMusic:Resource
@export var TeamSelectMusic:Resource
@export var GameMusic:Resource

var streamPlayers:Dictionary = {}

const gameMusicStr = "game_music"
const mainMusicStr = "main_menu_music"
const selectMusicStr = "select_music"

func _ready()->void:
	# create the music players
	var menuStreamPlayer = AudioStreamPlayer.new()
	menuStreamPlayer.stream = MainMenuMusic
	menuStreamPlayer.process_mode = PROCESS_MODE_ALWAYS
	#menuStreamPlayer.volume_db = -100
	get_tree().root.add_child.call_deferred(menuStreamPlayer)
	streamPlayers[mainMusicStr] = menuStreamPlayer
	var selectStreamPlayer = AudioStreamPlayer.new()
	selectStreamPlayer.stream = TeamSelectMusic
	selectStreamPlayer.process_mode = PROCESS_MODE_ALWAYS
	#selectStreamPlayer.volume_db = -100
	get_tree().root.add_child.call_deferred(selectStreamPlayer)
	streamPlayers[selectMusicStr] = selectStreamPlayer
	var gameStreamPlayer = AudioStreamPlayer.new()
	gameStreamPlayer.stream = GameMusic
	gameStreamPlayer.process_mode = PROCESS_MODE_ALWAYS # important since hitstop is done via pause
	#gameStreamPlayer.volume_db = -100
	get_tree().root.add_child.call_deferred(gameStreamPlayer)
	streamPlayers[gameMusicStr] = gameStreamPlayer
	# create the audio players
	for i in SoundEffects.size():
		var sound:AudioStream = SoundEffects[i]
		var streamPlayer = AudioStreamPlayer.new()
		streamPlayer.stream = sound
		streamPlayer.max_polyphony = 10
		get_tree().root.add_child.call_deferred(streamPlayer)
		var slashSplit = SoundEffects[i].resource_path.split("/")
		var name = slashSplit[slashSplit.size()-1].split(".")[0]
		streamPlayers[name] = streamPlayer
		
	


func PlayMainMenu()->void:
	(streamPlayers[gameMusicStr] as AudioStreamPlayer).stop()
	(streamPlayers[selectMusicStr] as AudioStreamPlayer).stop()
	(streamPlayers[mainMusicStr] as AudioStreamPlayer).play()
func PlayTeamSelect()->void:
	(streamPlayers[gameMusicStr] as AudioStreamPlayer).stop()
	(streamPlayers[mainMusicStr] as AudioStreamPlayer).stop()
	(streamPlayers[selectMusicStr] as AudioStreamPlayer).play()
func PlayGameMusic()->void:
	(streamPlayers[mainMusicStr] as AudioStreamPlayer).stop()
	(streamPlayers[selectMusicStr] as AudioStreamPlayer).stop()
	(streamPlayers[gameMusicStr] as AudioStreamPlayer).play()
	
	
func PlaySfx(name:String)->void:
	(streamPlayers[name] as AudioStreamPlayer).pitch_scale = 1
	(streamPlayers[name] as AudioStreamPlayer).play()
	
func PlaySfxPitched(name:String, pitch:float)->void:
	(streamPlayers[name] as AudioStreamPlayer).pitch_scale = pitch
	(streamPlayers[name] as AudioStreamPlayer).play()
	


