extends CharacterBody2D

@onready var tank_test_scene: Node2D = $".."
@onready var turret: Sprite2D = $Turret
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"../AudioStreamPlayer2D"

const SOVIET_FIRE_SOUND = preload("res://Assets/soviet fire sound.mp3")
const BULLET = preload("uid://c1o2iwa80al23")

const ROTATE_SPEED = 2
const SPEED = 15000

func _physics_process(delta: float) -> void:
	if Global.controlled_node == self:
		var direction := Input.get_axis("move_left", "move_right")
		var turret_direction := Input.get_axis("turret_left", "turret_right")
		
		if direction:
			rotation += direction * ROTATE_SPEED * delta
		
		if turret_direction:
			turret.rotation += turret_direction * ROTATE_SPEED * delta
		
		if Input.is_action_pressed("move_up"):
			velocity = -transform.y * SPEED * delta
		elif Input.is_action_pressed("move_down"):
			velocity = transform.y * (SPEED / 2) * delta
		else:
			velocity = Vector2(0, 0)
		
		if Input.is_action_just_pressed("fire"):
			inst()
		
		move_and_slide()

func inst():
	audio_stream_player_2d.stream = SOVIET_FIRE_SOUND
	audio_stream_player_2d.play(0)
	var instance = BULLET.instantiate()
	instance.position = position
	instance.rotation = turret.rotation + rotation
	tank_test_scene.add_child(instance)


func _on_button_pressed() -> void:
	if Global.controlled_node != self:
		Global.controlled_node = self
		if Global.camera_node != null:
			Global.camera_node.get_parent().remove_child(Global.camera_node)
			self.add_child(Global.camera_node)
