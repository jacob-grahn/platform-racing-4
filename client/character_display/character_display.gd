class_name CharacterDisplay
extends Node2D

const AIRBORN = 'airborn'
const CHARGE = 'charge'
const CHARGE_HOLD = 'charge_hold'
const CRAWL = 'crawl'
const CROUCH = 'crouch'
const HURT = 'hurt'
const HURT_START = 'hurt_start'
const IDLE = 'idle'
const JUMP = 'jump'
const RECOVER = 'recover'
const RUN = 'run'
const SWIM = 'swim'
const ANIMS = [
	AIRBORN,
	CHARGE,
	CHARGE_HOLD,
	CRAWL,
	CROUCH,
	HURT,
	HURT_START,
	IDLE,
	JUMP,
	RECOVER,
	RUN,
	SWIM
]

@onready var foot_back_color: Sprite2D = $FootBack/Color
@onready var foot_back_lines: Sprite2D = $FootBack/Lines
@onready var body_color: Sprite2D = $Body/Color
@onready var body_lines: Sprite2D = $Body/Lines
@onready var foot_front_color: Sprite2D = $FootFront/Color
@onready var foot_front_lines: Sprite2D = $FootFront/Lines
@onready var head_color: Sprite2D = $Head/Color
@onready var head_lines: Sprite2D = $Head/Lines
@onready var animations: AnimationPlayer = $Animations


func _ready() -> void:
	pass # Replace with function body.


func set_style(character_config: Dictionary) -> void:
	# colors
	head_color.modulate = Color(character_config["head"]["color"])
	body_color.modulate = Color(character_config["body"]["color"])
	foot_front_color.modulate = Color(character_config["feet"]["color"])
	foot_back_color.modulate = Color(character_config["feet"]["color"])
	
	# parts
	var head_texture
	if character_config["head"]["texture"]:
		head_texture = character_config["head"]["texture"]
	else:
		head_texture = await CachingLoader.load_texture(character_config["head"]["url"])
	
	var body_texture
	if character_config["body"]["texture"]:
		body_texture = character_config["body"]["texture"]
	else:
		body_texture = await CachingLoader.load_texture(character_config["body"]["url"])
	
	var feet_texture
	if character_config["feet"]["texture"]:
		feet_texture = character_config["feet"]["texture"]
	else:
		feet_texture = await CachingLoader.load_texture(character_config["feet"]["url"])
	
	head_color.texture = head_texture
	head_lines.texture = head_texture
	body_color.texture = body_texture
	body_lines.texture = body_texture
	foot_front_color.texture = feet_texture
	foot_front_lines.texture = feet_texture
	foot_back_color.texture = feet_texture
	foot_back_lines.texture = feet_texture


func play(anim: String) -> void:
	animations.play(anim)


func play_random() -> void:
	animations.play(ANIMS.pick_random())


func set_speed_scale(num: float) -> void:
	animations.speed_scale = num
	
