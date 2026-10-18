extends Area2D

var speed: float = 1000.0
var barrel_offset: float = 120.0

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
			body.health -= 10
		queue_free()
