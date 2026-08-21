extends Sprite2D

var forest_trees := [
	preload("res://Assets/tree1.png"),
	preload("res://Assets/tree2.png"),
	preload("res://Assets/tree3.png"),
	preload("res://Assets/tree4.png"),
]

var mud_trees := [
	preload("res://Assets/tree4.png"),
	preload("res://Assets/tree5.png"),
	preload("res://Assets/tree6.png"),
]

var type: String

func _ready() -> void:
	var chance: float = randf_range(0,1)
	
	if type == "mud":
		var i = randi_range(1, 2)
		if i == 1:
			if chance < 0.6:
				texture = mud_trees[2]
			elif chance < 0.9:
				texture = mud_trees[1]
				position.y -= 64
			else:
				texture = mud_trees[0]
				position.y -= 64
		else:
			self.queue_free()
	elif type == "forest":
		if chance < 0.35:
			texture = forest_trees[0]
		elif chance < 0.9:
			position.y -= 64
			if chance < 0.625:
				texture = forest_trees[1]
			else:
				texture = forest_trees[2]
		else:
			position.y -= 64
			texture = forest_trees[3]
	else:
		print("no tree type, deleting tree")
		self.queue_free()
