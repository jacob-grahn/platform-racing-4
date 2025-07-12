extends Control

@onready var SpeedLabel = $SpeedLabel
@onready var AccelLabel = $AccelLabel
@onready var JumpLabel = $JumpLabel
@onready var SkillLabel = $SkillLabel
@onready var SpeedSlider = $SpeedSlider
@onready var AccelSlider = $AccelSlider
@onready var JumpSlider = $JumpSlider
@onready var SkillSlider = $SkillSlider

var stats = [null, null, null, null]
var old_stats = [null, null, null, null]
var stats_changed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stats = [SpeedSlider.value, AccelSlider.value, JumpSlider.value, SkillSlider.value]
	old_stats = [SpeedSlider.value, AccelSlider.value, JumpSlider.value, SkillSlider.value]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	stats = [SpeedSlider.value, AccelSlider.value, JumpSlider.value, SkillSlider.value]
	if !stats_changed:
		for i in stats.size():
			if stats[i] != old_stats[i]:
				stats_changed = true
	update_text()

func update_text():
	SpeedLabel.text = str(SpeedSlider.value)
	AccelLabel.text = str(AccelSlider.value)
	JumpLabel.text = str(JumpSlider.value)
	SkillLabel.text = str(SkillSlider.value)

func set_stats(speed, accel, jump, skill) -> void:
	SpeedSlider.value = speed
	AccelSlider.value = accel
	JumpSlider.value = jump
	SkillSlider.value = skill
	stats = [SpeedSlider.value, AccelSlider.value, JumpSlider.value, SkillSlider.value]
	old_stats = [SpeedSlider.value, AccelSlider.value, JumpSlider.value, SkillSlider.value]
	stats_changed = false
	
func did_stats_changed() -> bool:
	return stats_changed

func get_total() -> Array:
	return [SpeedSlider.value, AccelSlider.value, JumpSlider.value, SkillSlider.value]
