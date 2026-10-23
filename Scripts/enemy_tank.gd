# Sections of this were coded with AI

extends CharacterBody2D

@onready var scene: Node2D = $".."
@onready var turret: Sprite2D = $Tank/Turret
@onready var fight_radius: Area2D = $FightRadius
@onready var move_radius: Area2D = $MoveRadius
@onready var tank_body: Sprite2D = $Tank/Body
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"../../AudioStreamPlayer2D"
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var health_bar: HSlider = $HealthBar
@onready var reload_bar: HSlider = $ReloadBar
@onready var terrain_layer: TileMapLayer = $"../../GameNode/TerrainLayer"
@onready var tank: Node2D = $Tank
@onready var ray_cast: RayCast2D = $Tank/Turret/RayCast2D
@onready var fire: AudioStreamPlayer2D = $Fire

var slow_terrain := [
	Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1), 
	Vector2i(2, 0), Vector2i(2, 1), Vector2i(3, 0), Vector2i(3, 1), 
] 

var very_slow_terrain := [
	Vector2i(0, 2), Vector2i(0, 3), Vector2i(1, 2), Vector2i(1, 3), 
	Vector2i(2, 2), Vector2i(2, 3), Vector2i(3, 2), Vector2i(3, 3), 
]

var time: float = 0
var look_at_tank: bool = false

const BULLET = preload("uid://c1o2iwa80al23")

const ROTATE_SPEED = 2

var speed: float = 30000.0
var speed_multiplier: float = 0.75
var damage: int = 40
var reload_time: float = 4.0
var turret_rotate_speed: float = deg_to_rad(45)

var subtracted_speed: float = 0.0

var can_fire = true
var reload_left: float = 0.0
var health = 100

enum State { IDLE, MOVE, FIGHT }
var current_state: State = State.IDLE

var fight_bodies
var move_bodies

var move_playing: bool = false

var tank_textures := {
	"light": preload("res://Assets/Puma Hull - Light Tank - Nazi Germany.png"),
	"medium": preload("res://Assets/Panther G Hull - Medium Tank - Nazi Germany.png"),
	"heavy": preload("res://Assets/Tiger II Hull - Heavy Tank - Nazi Germany.png"),
	"sheavy": preload("res://Assets/Maus Hull - Super Heavy Tank - Nazi Germany.png"),
}

var turret_textures := {
	"light": preload("res://Assets/Puma Turret - Light Tank - Nazi Germany.png"),
	"medium": preload("res://Assets/Panther G Turret - Medium Tank - Nazi Germany.png"),
	"heavy": preload("res://Assets/Tiger II Turret - Heavy Tank - Nazi Germany.png"),
	"sheavy": preload("res://Assets/Maus Turret - Super Heavy Tank - Nazi Germany.png"),
}

var turret_position := {
	"light": Vector2(0, -6),
	"medium": Vector2(0, -2),
	"heavy": Vector2(0, 8),
	"sheavy": Vector2(0, 20)
}

var turret_offset := {
	"light": Vector2(0, -3.5),
	"medium": Vector2(0, -8.5),
	"heavy": Vector2(0, -11.5),
	"sheavy": Vector2(0, -9)
}

var collision_shape_size := {
	"light": Vector2(36, 90),
	"medium": Vector2(60, 112),
	"heavy": Vector2(68, 132),
	"sheavy": Vector2(68, 180),
}

var tank_speed := {
	"light": 30000.0,
	"medium": 19286.0,
	"heavy": 12857.0,
	"sheavy": 8571.0,
}

var tank_health := {
	"light": 50,
	"medium": 500,
	"heavy": 950,
	"sheavy": 3100,
}

var tank_damage := {
	"light": 40,
	"medium": 280,
	"heavy": 590,
	"sheavy": 920,
}

var tank_reload := {
	"light": 4.0,
	"medium": 7.5,
	"heavy": 14.0,
	"sheavy": 20.0,
}

var tank_turret_speed := {
	"light": 45,
	"medium": 32,
	"heavy": 14,
	"sheavy": 6,
}

var tank_type: String = "light"


func _ready() -> void:
	apply_tank_type()


func apply_tank_type() -> void:
	speed = tank_speed[tank_type] * speed_multiplier
	health = tank_health[tank_type]
	damage = tank_damage[tank_type]
	reload_time = tank_reload[tank_type]
	turret_rotate_speed = deg_to_rad(tank_turret_speed[tank_type])
	
	tank_body.texture = tank_textures[tank_type]
	turret.texture = turret_textures[tank_type]
	turret.position = turret_position[tank_type]
	turret.offset = turret_offset[tank_type]
	
	var new_shape = RectangleShape2D.new()
	new_shape.size = collision_shape_size[tank_type]
	collision_shape_2d.shape = new_shape
	
	health_bar.max_value = health
	health_bar.value = health
	
	reload_bar.step = 0.01
	reload_bar.max_value = reload_time
	reload_bar.value = reload_time
	reload_left = 0.0
	can_fire = true


func _physics_process(delta: float) -> void:
	check_terrain()
	
	fight_bodies = fight_radius.get_overlapping_bodies()
	move_bodies = move_radius.get_overlapping_bodies()
	
	_check_state_transitions()
	
	match current_state:
		State.IDLE:
			_handle_idle_state(delta)
		State.MOVE:
			_handle_movement_state(delta)
		State.FIGHT:
			_handle_fight_state(delta)
	
	move_and_slide()


func _check_state_transitions() -> void:
	if fight_bodies.size() > 0:
		current_state = State.FIGHT
	elif move_bodies.size() > 0:
		current_state = State.MOVE
	else:
		current_state = State.IDLE


func _handle_idle_state(delta: float) -> void:
	velocity = Vector2.ZERO
	turret.rotation = rotate_toward(turret.rotation, deg_to_rad(0), turret_rotate_speed * delta)
	tank_body.rotation = rotate_toward(tank_body.rotation, deg_to_rad(0), ROTATE_SPEED * delta)
	collision_shape_2d.rotation = rotate_toward(collision_shape_2d.rotation, deg_to_rad(0), ROTATE_SPEED * delta)


func _handle_movement_state(delta: float) -> void:
	var tanks := []
	var distances := []
	
	for body in move_bodies:
		distances.append(global_position.distance_to(body.global_position))
		tanks.append(body)
	
	var closest_pos: Vector2
	
	if distances.size() > 0:
		var index = distances.find(distances.min())
		closest_pos = tanks[index].global_position
		var target_angle = global_position.angle_to_point(closest_pos)
		
		tank_body.rotation = rotate_toward(tank_body.rotation, target_angle + deg_to_rad(90), ROTATE_SPEED * delta)
		collision_shape_2d.rotation = rotate_toward(collision_shape_2d.rotation, target_angle + deg_to_rad(90), ROTATE_SPEED * delta)
		turret.rotation = rotate_toward(turret.rotation, target_angle + deg_to_rad(90), turret_rotate_speed * delta)
		
		velocity = -tank_body.transform.y.normalized() * (speed - subtracted_speed) * delta


func _handle_fight_state(delta: float) -> void:
		var tanks := []
		var distances := []
		
		for body in fight_bodies:
			distances.append(global_position.distance_to(body.global_position))
			tanks.append(body)
		
		if distances.size() > 0:
			var index = distances.find(distances.min())
			var target_angle = global_position.angle_to_point(tanks[index].global_position)
			
			turret.rotation = rotate_toward(turret.rotation, target_angle + deg_to_rad(90), turret_rotate_speed * delta)
			
			
			if angle_difference(turret.rotation, target_angle) < 0.05 and can_fire == true:
				var collider_ray = ray_cast.get_collider()
					
				if collider_ray is CharacterBody2D:
					return
				
				can_fire = false
				reload_left = reload_time
				inst()
			
			velocity = velocity.lerp(Vector2.ZERO, 2 * delta)
		else:
			var move_direction = velocity.normalized()


func check_terrain() -> void:
	var terrain_player_pos = terrain_layer.to_local(self.global_position)
	var terrain_grid_pos = terrain_layer.local_to_map(terrain_player_pos)
	var terrain_source_id = terrain_layer.get_cell_source_id(terrain_grid_pos)
	
	if terrain_source_id != 1:
		return
	
	var terrain_atlas_coords = terrain_layer.get_cell_atlas_coords(terrain_grid_pos)
	
	if slow_terrain.has(terrain_atlas_coords):
		subtracted_speed = speed / 3.0
	elif very_slow_terrain.has(terrain_atlas_coords):
		subtracted_speed = speed * 2.0 / 3.0
	else:
		subtracted_speed = 0.0


func _process(delta: float) -> void:
	if reload_left > 0:
		reload_left -= delta
		if reload_left <= 0:
			reload_left = 0
			can_fire = true
	
	reload_bar.value = reload_time - reload_left
	
	if health != health_bar.value:
		if health <= 0:
			queue_free()
		health_bar.value = health


func inst():
	fire.play()
	var instance = BULLET.instantiate()
	instance.position = position
	instance.rotation = turret.rotation
	instance.damage = damage
	scene.add_child(instance)
