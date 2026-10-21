extends CharacterBody2D

@onready var scene: Node2D = $".."
@onready var turret: Sprite2D = $Tank/Turret
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"../AudioStreamPlayer2D"
@onready var health_bar: HSlider = $HealthBar
@onready var tank_body: Sprite2D = $Tank/Body
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var button: Button = $Button
@onready var fight_radius: Area2D = $FightRadius
@onready var terrain_layer: TileMapLayer = $"../TerrainLayer"
@onready var tank: Node2D = $Tank
@onready var reload_bar: HSlider = $ReloadBar

const SOVIET_FIRE_SOUND = preload("res://Assets/soviet fire sound.mp3")
const BULLET = preload("uid://c1o2iwa80al23")

const ROTATE_SPEED = 2

var slow_terrain := [
	Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1), 
	Vector2i(2, 0), Vector2i(2, 1), Vector2i(3, 0), Vector2i(3, 1), 
] 

var very_slow_terrain := [
	Vector2i(0, 2), Vector2i(0, 3), Vector2i(1, 2), Vector2i(1, 3), 
	Vector2i(2, 2), Vector2i(2, 3), Vector2i(3, 2), Vector2i(3, 3), 
]

var can_fire = true
var reload_left: float = 0.0
var health = 100

var speed: float = 30000.0
var damage: int = 40
var reload_time: float = 4.0
var turret_rotate_speed: float = deg_to_rad(45)

var subtracted_speed: float = 0.0

var tank_textures := {
	"light": preload("res://Assets/T-70 Hull - Light Tank - Soviet Union.png"),
	"medium": preload("res://Assets/T-34-85-M Hull - Medium Tank - Soviet Union.png"),
	"heavy": preload("res://Assets/IS-2 Hull - Heavy Tank - Soviet Union.png"),
	"sheavy": preload("res://Assets/T-10M Hull - Modern Heavy Tank - Soviet Union.png"),
}

var turret_textures := {
	"light": preload("res://Assets/T-70 Turret - Light Tank - Soviet Union.png"),
	"medium": preload("res://Assets/T-34-85-M Turret - Medium Tank - Soviet Union.png"),
	"heavy": preload("res://Assets/IS-2 Turret - Heavy Tank - Soviet Union.png"),
	"sheavy": preload("res://Assets/T-10M Turret - Modern Heavy Tank - Soviet Union.png"),
}

var turret_position := {
	"light": Vector2(-4, 0),
	"medium": Vector2(0, -18),
	"heavy": Vector2(0, -18),
	"sheavy": Vector2(0, -14),
}

var turret_offset := {
	"light": Vector2(0, -1.5),
	"medium": Vector2(0, -5),
	"heavy": Vector2(0, -10),
	"sheavy": Vector2(0, -14),
}

var collision_shape_size := {
	"light": Vector2(32, 60),
	"medium": Vector2(52, 112),
	"heavy": Vector2(60, 136),
	"sheavy": Vector2(84, 164),
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
	speed = tank_speed[tank_type]
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
	
	button.size = collision_shape_size[tank_type]
	button.position = collision_shape_2d.position - collision_shape_size[tank_type] / 2
	button.pivot_offset = collision_shape_size[tank_type] / 2
	
	health_bar.max_value = health
	health_bar.value = health
	
	reload_bar.step = 0.01
	reload_bar.max_value = reload_time
	reload_bar.value = reload_time
	reload_left = 0.0
	can_fire = true


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


func _physics_process(delta: float) -> void:
	check_terrain()
	
	health_bar.rotation = 0
	reload_bar.rotation = 0
	
	if Global.controlled_node == self:
		var direction := Input.get_axis("move_left", "move_right")
		var turret_direction := Input.get_axis("turret_left", "turret_right")
		
		if direction:
			tank.rotation += direction * ROTATE_SPEED * delta
			collision_shape_2d.rotation += direction * ROTATE_SPEED * delta
			button.rotation += direction * ROTATE_SPEED * delta
		
		if turret_direction:
			turret.rotation += turret_direction * turret_rotate_speed * delta
		
		if Input.is_action_pressed("move_up"):
			velocity = -tank.transform.y * (speed - subtracted_speed) * delta
		elif Input.is_action_pressed("move_down"):
			velocity = tank.transform.y * ((speed - subtracted_speed) / 2) * delta
		else:
			velocity = Vector2(0, 0)
		
		if Input.is_action_just_pressed("fire"):
			if can_fire == true:
				can_fire = false
				reload_left = reload_time
				inst()
		
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
				
				turret.rotation = rotate_toward(turret.rotation, target_angle + deg_to_rad(90), turret_rotate_speed * delta)
				
				if angle_difference(turret.rotation, target_angle) < 0.05 and can_fire == true:
					can_fire = false
					reload_left = reload_time
					inst()
		else:
			velocity = Vector2.ZERO
			turret.rotation = rotate_toward(turret.rotation, deg_to_rad(0), turret_rotate_speed * delta)
			tank_body.rotation = rotate_toward(tank_body.rotation, deg_to_rad(0), ROTATE_SPEED * delta)
			collision_shape_2d.rotation = rotate_toward(collision_shape_2d.rotation, deg_to_rad(0), ROTATE_SPEED * delta)


func _process(delta: float) -> void:
	if reload_left > 0:
		reload_left -= delta
		if reload_left <= 0:
			reload_left = 0
			can_fire = true
	
	reload_bar.value = reload_time - reload_left
	
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
	instance.rotation = turret.rotation + tank.rotation
	instance.damage = damage
	scene.add_child(instance)

func _on_button_pressed() -> void:
	if Global.controlled_node != self:
		Global.controlled_node = self
		if Global.camera_node != null:
			Global.camera_node.get_parent().remove_child(Global.camera_node)
			self.add_child(Global.camera_node)
