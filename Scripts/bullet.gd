extends Area2D

@onready var line_2d: Line2D = $Marker2D/Line2D

var speed: float = 1000.0
var barrel_offset: float = 120.0
var damage: int = 10

var point

func _ready() -> void:
	set_as_top_level(true)
	line_2d.set_as_top_level(true)
	
	position += -transform.y * barrel_offset
	
	await get_tree().create_timer(3).timeout
	
	queue_free()

func _physics_process(delta: float) -> void:
	point = line_2d.get_parent().global_position
	line_2d.add_point(point)
	if line_2d.points.size() > 10:
		line_2d.remove_point(0)
	
	position += -transform.y * speed * delta
	
	var bodies = get_overlapping_bodies()
	
	if bodies.size() > 0:
		for body in bodies:
			body.health -= damage
		queue_free()
