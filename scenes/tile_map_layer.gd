extends TileMapLayer


@export var grass_atlas_coords: Vector2i = Vector2i(2, 10)
@export var grass_source_id: int = 3

@export var dirt_atlas_coords: Vector2i = Vector2i(7, 10)
@export var dirt_source_id: int = 3

@export var snow_atlas_coords: Vector2i = Vector2i(2, 14)
@export var snow_source_id: int = 3

@export var sand_atlas_coords: Vector2i = Vector2i(7, 14)
@export var sand_source_id: int = 3

@export var water_atlas_coords: Vector2i = Vector2i(5, 3)
@export var water_source_id: int = 4

var temperature_noise: FastNoiseLite = FastNoiseLite.new()
var moisture_noise: FastNoiseLite = FastNoiseLite.new()
var altitude_noise: FastNoiseLite = FastNoiseLite.new()

var width: int = 1000
var height: int = 1000

func _ready() -> void:
	temperature_noise.seed = randi()
	moisture_noise.seed = randi()
	altitude_noise.seed = randi()
	altitude_noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	for x: int in width:
		for y: int in height:
			generate_tile(x, y)
			
			
func generate_tile(x: int, y: int) -> void:
	var temperature: float = (1 + temperature_noise.get_noise_2d(x, y)) * 0.5
	var moisture: float = (1 + moisture_noise.get_noise_2d(x, y)) * 0.5
	var altitude: float = 1 - (1 + altitude_noise.get_noise_2d(x, y)) * 0.5
	
	if altitude < 0.7:
		set_cell(Vector2i(x, y), water_source_id, water_atlas_coords)
	else:
		if temperature < 0.2:
			set_cell(Vector2i(x, y), snow_source_id, snow_atlas_coords)
		elif temperature > 0.8:
			set_cell(Vector2i(x, y), sand_source_id, sand_atlas_coords)
		else:
			if moisture > 0.5:
				set_cell(Vector2i(x, y), grass_source_id, grass_atlas_coords)
			else:
				set_cell(Vector2i(x, y), dirt_source_id, dirt_atlas_coords)


	
