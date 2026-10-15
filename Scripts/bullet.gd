extends Area2D

var speed: float = 1000.0
var barrel_offset: float = 105.0

func _ready() -> void:
	set_as_top_level(true)
	
	position += -transform.y * barrel_offset

func _physics_process(delta: float) -> void:
	position += -transform.y * speed * delta
