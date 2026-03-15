extends Node3D
class_name World

@export var world_size := 64
@export var noise: Noise

const MATERIAL := preload("res://world/material.tres")

var blocks: Dictionary[Vector3i, Block] = {}

@onready var player := $Player
@onready var block_highlight := $BlockHighlight

var mesh_instance: MeshInstance3D

func _ready() -> void:
	_generate_world()

func _process(delta: float) -> void:
	# Highlight block player is looking at.
	block_highlight.position = Vector3(player.block_looking_at) + Vector3.ONE * .5

func _generate_world() -> void:
	for x in range(world_size):
		for z in range(world_size):
			var stone_level := 20 + 16 * noise.get_noise_2d(x, z)
			var grass_level := stone_level + 3 * absf(noise.get_noise_2d(x, z))
			for y in range(stone_level):
				blocks[Vector3i(x, y, z)] = Block.STONE
			for y in range(stone_level, grass_level):
				blocks[Vector3i(x, y, z)] = Block.DIRT
			blocks[Vector3i(x, grass_level, z)] = Block.GRASS
	
	_generate_mesh()

func _generate_mesh() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(MATERIAL)
	for block_pos in blocks.keys():
		blocks[block_pos].emit_mesh(st, block_pos, self)
	
	st.index()
	
	# TODO: incremental mesh updates
	if mesh_instance:
		mesh_instance.queue_free()
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = st.commit()
	mesh_instance.create_trimesh_collision()
	add_child(mesh_instance)

func break_block(block_pos: Vector3i) -> void:
	blocks.erase(block_pos)
	_generate_mesh()

func set_block(block_pos: Vector3i, block: Block) -> void:
	assert(block_pos.x in range(world_size) and block_pos.z in range(world_size))
	assert(block, "should use break_block to place air")
	
	blocks[block_pos] = block
	_generate_mesh()
