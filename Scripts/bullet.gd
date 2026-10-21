extends Area2D

var speed: float = 2000.0
var barrel_offset: float = 120.0
var damage: int = 10

func _ready() -> void:
	set_as_top_level(true)
	
	position += -transform.y * barrel_offset
	
	await get_tree().create_timer(3).timeout
	
	queue_free()

func _physics_process(delta: float) -> void:
	position += -transform.y * speed * delta
	
	var bodies = get_overlapping_bodies()
	
	if bodies.size() > 0:
		for body in bodies:
			body.health -= damage
		queue_free()
