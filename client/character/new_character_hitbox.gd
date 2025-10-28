extends CollisionShape2D
## Controls the character's collision shape.
## Adjusts between high and low profiles based on character state.

# Hitbox types
# 0 - reacts to every tile
# 1 - reacts to every tile except water and net
# 2 - reacts only to water and net tiles

# Hitboxes list
# 1 - top left
# 2 - top middle
# 3 - top right
# 4 - center hitbox
# 5 - bottom left
# 6 - bottom middle
# 7 - bottom right
# 8 - hurtbox
# 9 - crawl hitbox
# 10 - not used

@onready var hitbox1 = $Hitbox1
@onready var hitbox2 = $Hitbox2
@onready var hitbox3 = $Hitbox3
@onready var hitbox4 = $Hitbox4
@onready var hitbox5 = $Hitbox5
@onready var hitbox6 = $Hitbox6
@onready var hitbox7 = $Hitbox7
@onready var hitbox8 = $Hitbox8
@onready var hitbox9 = $Hitbox9
@onready var hitbox10 = $Hitbox10

const HIGH: float = 180.0
const LOW: float = 32.0

var hitbox_size: Vector2 = Vector2(1, 1)
var mode: String = "high"


func _ready():
	go_high()


func run(character: Character) -> void:
	hitbox_size = character.movement.size
	if character.is_on_floor():
		go_low()
	elif character.lightbreak.is_active():
		go_low()
	elif character.velocity.rotated(-character.rotation).y >= -0.01:
		go_low()
	elif character.movement.is_crouching:
		go_low()
	else:
		go_high()
	
	# disable collision if we're stuck in a wall
	if character.is_in_solid():
		disabled = true
	elif character.lightbreak.type == LightTile.MOON and character.lightbreak.is_active():
		disabled = true
	else:
		disabled = false
	
	# position hitbox
	position.y = round(-shape.size.y / 2.0)


func go_high() -> void:
	mode = "high"
	shape.size.y = HIGH


func go_low() -> void:
	mode = "low"
	shape.size.y = LOW
