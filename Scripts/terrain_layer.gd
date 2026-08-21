extends TileMapLayer

@onready var trees_node: Node2D = $"../Trees"

var map_size = Vector2(65536, 65536)

var water: Vector2i = Vector2i(randi_range(0,1), randi_range(2,3))

const TREE = preload("uid://bscmqod57i12")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.position =- Vector2(map_size / 2)
	
	var height_noise := FastNoiseLite.new()
	height_noise.noise_type = FastNoiseLite.TYPE_VALUE_CUBIC
	height_noise.seed = randi()
	height_noise.frequency = 0.01
	
	var sand_grass_noise := FastNoiseLite.new()
	sand_grass_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	sand_grass_noise.seed = randi()
	sand_grass_noise.frequency = 0.005
	
	var mud_forest_noise := FastNoiseLite.new()
	mud_forest_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	mud_forest_noise.seed = randi()
	mud_forest_noise.frequency = 0.005
	
	for x in map_size.x / 64:
		for y in map_size.y / 64:
			var impassable: Vector2i = Vector2i(randi_range(2,3), randi_range(2,3))
			var sand: Vector2i = Vector2i(randi_range(0,1), randi_range(4,5))
			var grass: Vector2i = Vector2i(randi_range(0,1), randi_range(0,1))
			var mud: Vector2i = Vector2i(randi_range(2,3), randi_range(0,1))
			var forest: Vector2i = Vector2i(randi_range(2,3), randi_range(4,5))
			
			var h: float = height_noise.get_noise_2d(x, y)
			var sg: float = sand_grass_noise.get_noise_2d(x, y)
			var mf: float = mud_forest_noise.get_noise_2d(x, y)
			
			var pos = Vector2((x * 64) - (map_size.x / 2) + randf_range(0,64), (y * 64) - (map_size.y / 2) + randf_range(0,64))
			
			if h < -0.1:
				set_cell(Vector2i(x, y), 1, water)
			elif h < 0:
				if sg < 0 :
					if mf > 0.35:
						set_cell(Vector2i(x, y), 1, mud)
						tree_inst(pos, "mud")
					elif mf > -0.35:
						set_cell(Vector2i(x, y), 1, forest)
					else:
						set_cell(Vector2i(x, y), 1, grass)
						tree_inst(pos, "forest")
				else:
					set_cell(Vector2i(x, y), 1, sand)
			elif h < 0.25:
				if sg > 0.1:
					set_cell(Vector2i(x, y), 1, sand)
				else:
					if mf > 0.35:
						set_cell(Vector2i(x, y), 1, mud)
						tree_inst(pos, "mud")
					elif mf > -0.35:
						set_cell(Vector2i(x, y), 1, forest)
					else:
						set_cell(Vector2i(x, y), 1, grass)
						tree_inst(pos, "forest")
			else:
				set_cell(Vector2i(x, y), 1, impassable)


func tree_inst(pos: Vector2, type: String):
	var instance = TREE.instantiate()
	instance.position = pos
	instance.type = type
	trees_node.add_child.call_deferred(instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
