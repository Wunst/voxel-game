extends Node3D
class_name World

## World size in chunks.
@export var world_size := 8

## World height in chunks.
@export var world_height := 16

@export var noise: Noise

@onready var player := $Player
@onready var block_highlight := $BlockHighlight

const PV_SPLINE := preload("res://world/spline/pv_spline.tres")

var mesh_instance: MeshInstance3D

var _chunks: Dictionary[Vector3i, Chunk] = {}

func _ready() -> void:
	_generate_world()
	
	player.position = Vector3(world_size, world_height * 2, world_size) * Chunk.CHUNK_SIZE / 2

func _generate_world() -> void:
	_create_chunks()
	_terrain()

func _process(delta: float) -> void:
	# Highlight block player is looking at.
	block_highlight.position = Vector3(player.block_looking_at) + Vector3.ONE * .5
	
	# Mesh dirty chunks.
	_mesh()

func set_block(block_pos: Vector3i, block: Block) -> void:
	var chunk_pos := block_pos / Chunk.CHUNK_SIZE
	var chunk: Chunk = _chunks.get(chunk_pos)
	if not chunk:
		# TODO: Return bool if successful
		return
	
	chunk.set_block(block_pos % Chunk.CHUNK_SIZE, block)

func get_block(block_pos: Vector3i) -> Block:
	var chunk_pos := block_pos / Chunk.CHUNK_SIZE
	var chunk: Chunk = _chunks.get(chunk_pos)
	if not chunk:
		return null
	
	return chunk.get_block(block_pos % Chunk.CHUNK_SIZE)

func _create_chunks() -> void:
	for x in range(world_size):
		for y in range(world_height):
			for z in range(world_size):
				var chunk_pos := Vector3i(x, y, z)
				var chunk := Chunk.new(chunk_pos)
				_chunks[chunk_pos] = chunk
				add_child(chunk)

func _terrain() -> void:
	for x in range(world_size * Chunk.CHUNK_SIZE):
		for z in range(world_size * Chunk.CHUNK_SIZE):
			var stone_level := PV_SPLINE.sample(noise.get_noise_2d(x, z))
			var grass_level := stone_level + 3 * absf(noise.get_noise_2d(x, z))
			for y in range(stone_level):
				set_block(Vector3i(x, y, z), Block.STONE)
			for y in range(stone_level, grass_level):
				set_block(Vector3i(x, y, z), Block.DIRT)
			set_block(Vector3i(x, grass_level, z), Block.GRASS)

func _mesh() -> void:
	for chunk in _chunks.values():
		chunk.mesh()
