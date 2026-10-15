extends Node2D

@onready var test_tank: CharacterBody2D = $TestTank

func _ready() -> void:
	Global.controlled_node = test_tank
