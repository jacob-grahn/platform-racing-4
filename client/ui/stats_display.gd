extends Control
class_name StatsDisplay

@onready var speed_text = $SpeedText
@onready var accel_text = $AccelText
@onready var jump_text = $JumpText
@onready var skill_text = $SkillText

var game
var player
var stats: Array


func init(game_scene):
	game = game_scene
	player = game_scene.get_node("PlayerManager").get_character()

func _physics_process(delta: float) -> void:
	if player:
		stats = player.stats.get_total()
		speed_text.text = str(stats[0])
		accel_text.text = str(stats[1])
		jump_text.text = str(stats[2])
		skill_text.text = str(stats[3])
