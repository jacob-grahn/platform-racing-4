extends CollisionShape2D

const HIGH: int = 180
const LOW: int = 32

var mode = "high"


func _ready():
	go_high()


func run(character: Character) -> void:
	if character.is_on_floor():
		go_low()
	elif character.lightbreak_windup > 0:
		go_low()
	elif character.lightbreak_direction.length() > 0:
		go_low()
	elif character.velocity.rotated(-character.rotation).y >= -0.01:
		go_low()
	elif character.is_crouching:
		go_low()
	else:
		go_high()
	
	# disable collision if we're stuck in a wall
	if character.is_in_solid():
		disabled = true
	elif character.lightbreak_type == LightTile.MOON && character.lightbreak_direction.length() > 0:
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
