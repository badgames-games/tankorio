extends CharacterBody2D

@onready var scene: Node2D = $".."
@onready var turret: Sprite2D = $Turret
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"../AudioStreamPlayer2D"
@onready var health_bar: HSlider = $HealthBar
@onready var tank_body: Sprite2D = $Body
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var button: Button = $Button
@onready var fight_radius: Area2D = $FightRadius
@onready var terrain_layer: TileMapLayer = $"../TerrainLayer"

const SOVIET_FIRE_SOUND = preload("res://Assets/soviet fire sound.mp3")
const BULLET = preload("uid://c1o2iwa80al23")

const ROTATE_SPEED = 2
const SPEED = 15000

var slow_terrain := [
	Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1), 
	Vector2i(2, 0), Vector2i(2, 1), Vector2i(3, 0), Vector2i(3, 1), 
] 

var very_slow_terrain := [
	Vector2i(0, 2), Vector2i(0, 3), Vector2i(1, 2), Vector2i(1, 3), 
	Vector2i(2, 2), Vector2i(2, 3), Vector2i(3, 2), Vector2i(3, 3), 
]

var can_fire = true
var health = 100

var subtracted_speed: float = 0.0


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


func _physics_process(delta: float) -> void:
	check_terrain()
	
	health_bar.rotation = 0
	
	if Global.controlled_node == self:
		var direction := Input.get_axis("move_left", "move_right")
		var turret_direction := Input.get_axis("turret_left", "turret_right")
		
		if direction:
			turret.rotation += direction * ROTATE_SPEED * delta
			tank_body.rotation += direction * ROTATE_SPEED * delta
			collision_shape_2d.rotation += direction * ROTATE_SPEED * delta
			button.rotation += direction * ROTATE_SPEED * delta
		
		if turret_direction:
			turret.rotation += turret_direction * ROTATE_SPEED * delta
		
		if Input.is_action_pressed("move_up"):
			velocity = -tank_body.transform.y * (SPEED - subtracted_speed) * delta
		elif Input.is_action_pressed("move_down"):
			velocity = tank_body.transform.y * ((SPEED - subtracted_speed) / 2) * delta
		else:
			velocity = Vector2(0, 0)
		
		if Input.is_action_just_pressed("fire"):
			if can_fire == true:
				can_fire = false
				inst()
				await get_tree().create_timer(1).timeout
				can_fire = true
		
		move_and_slide()
	else:
		var fight_bodies = fight_radius.get_overlapping_bodies()
		
		if fight_bodies.size() > 0:
			var tanks := []
			var distances := []
			
			for body in fight_bodies:
				distances.append(global_position.distance_to(body.global_position))
				tanks.append(body)
			
			if distances.size() > 0:
				var index = distances.find(distances.min())
				var target_angle = global_position.angle_to_point(tanks[index].global_position)
				
				turret.rotation = rotate_toward(turret.rotation, target_angle + deg_to_rad(90), ROTATE_SPEED * delta)
				
				if angle_difference(turret.rotation, target_angle) < 0.05 and can_fire == true:
					can_fire = false
					inst()
					await get_tree().create_timer(1).timeout
					can_fire = true
		else:
			velocity = Vector2.ZERO
			turret.rotation = rotate_toward(turret.rotation, deg_to_rad(0), ROTATE_SPEED * delta)
			tank_body.rotation = rotate_toward(tank_body.rotation, deg_to_rad(0), ROTATE_SPEED * delta)
			collision_shape_2d.rotation = rotate_toward(collision_shape_2d.rotation, deg_to_rad(0), ROTATE_SPEED * delta)


func _process(delta: float) -> void:
	if health != health_bar.value:
		if health <= 0:
			if Global.controlled_node == self:
				Global.camera_node.reparent(Global.player_node)
				Global.camera_node.position = Vector2.ZERO
				Global.controlled_node = Global.player_node
			if get_tree().get_nodes_in_group("PlayerTank").size() <= 1:
				get_tree().change_scene_to_file("res://Scenes/game_over.tscn")
			queue_free()
		health_bar.value = health


func inst():
	audio_stream_player_2d.stream = SOVIET_FIRE_SOUND
	audio_stream_player_2d.play(0)
	var instance = BULLET.instantiate()
	instance.position = position
	instance.rotation = turret.rotation
	scene.add_child(instance)

func _on_button_pressed() -> void:
	if Global.controlled_node != self:
		Global.controlled_node = self
		if Global.camera_node != null:
			Global.camera_node.get_parent().remove_child(Global.camera_node)
			self.add_child(Global.camera_node)
