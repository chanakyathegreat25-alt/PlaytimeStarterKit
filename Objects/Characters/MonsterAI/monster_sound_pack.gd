extends Resource
class_name MonsterSoundPack

@export var ambient_idle_sounds: bool = false
@export var idle_sound: Array[AudioStream]
@export var ambient_moving_sounds: bool = false
@export var moving_sounds: Array[AudioStream]
@export var footstep_sounds: Array[AudioStream] = [preload("res://Objects/Characters/MonsterAI/Audio/defaultwalk1.wav"),preload("res://Objects/Characters/MonsterAI/Audio/defualtwalk2.wav"),preload("res://Objects/Characters/MonsterAI/Audio/defaultwalk3.wav")]
@export var footstep_volume: float = 0.0
@export var taunt_sound: AudioStream
@export var jumpscare_sound: AudioStream
