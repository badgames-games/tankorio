extends CharacterBody2D

@onready var scene: Node2D = $".."
@onready var turret: Sprite2D = $Turret
@onready var fight_radius: Area2D = $FightRadius
@onready var move_radius: Area2D = $MoveRadius
@onready var tank_body: Sprite2D = $Body
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"../AudioStreamPlayer2D"
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var health_bar: HSlider = $HealthBar
@onready var terrain_layer: TileMapLayer = $"../TerrainLayer"

const SOVIET_FIRE_SOUND = preload("res://Assets/soviet fire sound.mp3")

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
const SPEED = 15000

var subtracted_speed: float = 0.0

var can_fire = true
var health = 100

enum State { IDLE, MOVE, FIGHT }
var current_state: State = State.IDLE

var fight_bodies
var move_bodies


func _physics_process(delta: float) -> void:
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
	turret.rotation = rotate_toward(turret.rotation, deg_to_rad(0), ROTATE_SPEED * delta)
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
		
		velocity = -tank_body.transform.y * (SPEED - subtracted_speed) * delta


func _handle_fight_state(delta: float) -> void:
		var tanks := []
		var distances := []
		
		for body in fight_bodies:
			distances.append(global_position.distance_to(body.global_position))
			tanks.append(body)
		
		if distances.size() > 0:
			var index = distances.find(distances.min())
			var target_angle = global_position.angle_to_point(tanks[index].global_position)
			
			turret.rotation = rotate_toward(turret.rotation, target_angle, ROTATE_SPEED * delta)
			
			
			if angle_difference(turret.rotation, target_angle) < 0.05 and can_fire == true:
				can_fire = false
				inst()
				await get_tree().create_timer(1).timeout
				can_fire = true
			
			velocity = velocity.lerp(Vector2.ZERO, 2 * delta)
		else:
			var move_direction = velocity.normalized()
			print(move_direction)


func check_terrain() -> void:
	var terrain_player_pos = terrain_layer.to_local(self.global_position)
	var terrain_grid_pos = terrain_layer.local_to_map(terrain_player_pos)
	var terrain_source_id = terrain_layer.get_cell_source_id(terrain_grid_pos)
	
	if terrain_source_id != 1:
		return
	
	var terrain_atlas_coords = terrain_layer.get_cell_atlas_coords(terrain_grid_pos)
	
	if slow_terrain.has(terrain_atlas_coords):
		subtracted_speed = 5000.0
	elif very_slow_terrain.has(terrain_atlas_coords):
		subtracted_speed = 10000.0
	else:
		subtracted_speed = 0.0


func _process(delta: float) -> void:
	if health != health_bar.value:
		if health <= 0:
			if get_tree().get_nodes_in_group("EnemyTank").size() <= 1:
				get_tree().change_scene_to_file("res://Scenes/victory_screen.tscn")
			queue_free()
		health_bar.value = health


func inst():
	audio_stream_player_2d.stream = SOVIET_FIRE_SOUND
	audio_stream_player_2d.play(0)
	var instance = BULLET.instantiate()
	instance.position = position
	instance.rotation = turret.rotation + deg_to_rad(90)
	scene.add_child(instance)
