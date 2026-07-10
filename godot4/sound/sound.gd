extends Node

@export var rank_promotion: AudioStream
@export var good_pickup: AudioStream
@export var treasure_found: AudioStream
@export var raider_catch: AudioStream

@onready var sound_players = get_children()


func play(sound_stream: AudioStream, pitch_scale: float = 1.0, volume_db: float = 0.0):
	for sound_player: AudioStreamPlayer in sound_players:
		if not sound_player.playing:
			sound_player.pitch_scale = pitch_scale
			sound_player.volume_db = volume_db
			sound_player.stream = sound_stream
			sound_player.play()
			return
	print("Too many sounds playing at once")
