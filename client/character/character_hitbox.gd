extends CollisionShape2D
## Controls the character's collision shape.
## Adjusts between high and low profiles based on character state.

const HIGH: int = 180
const LOW: int = 32

var mode: String = "high"


func _ready():
	go_high()


func run(character: Character) -> void:
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


func go_high() -> void:
	mode = "high"
	shape.height = HIGH
	position.y = round(-HIGH / 2.0)


func go_low() -> void:
	mode = "low"
	shape.height = LOW
	position.y = round(-LOW / 2.0)
