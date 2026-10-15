extends CharacterBody2D

@onready var tank_test_scene: Node2D = $".."
@onready var turret: Sprite2D = $Turret
@onready var test_tank: CharacterBody2D = $"../TestTank"
@onready var fight_radius: Area2D = $FightRadius

var time: float = 0
var look_at_tank: bool = false

const BULLET = preload("uid://c1o2iwa80al23")

const ROTATE_SPEED = 2
const SPEED = 15000


func _process(delta: float) -> void:
	
	#velocity = -transform.y * SPEED * delta
	
	var bodies = fight_radius.get_overlapping_bodies()
	
	if bodies.size() > 0:
		var tanks := []
		var distances := []
		
		for body in bodies:
			distances.append(global_position.distance_to(body.global_position))
			tanks.append(body)
		
		if distances.size() > 0:
			var index = distances.find(distances.min())
			turret.look_at(tanks[index].global_position)
		else:
			var move_direction = velocity.normalized()
			print(move_direction)
	
	move_and_slide()
