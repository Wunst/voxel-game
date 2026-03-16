extends Node3D
class_name Chunk

const CHUNK_SIZE := 16

const MATERIAL := preload("res://world/material.tres")

var _blocks: Dictionary[Vector3i, Block] = {}
var _mesh_instance: MeshInstance3D

var mesh_dirty := false

func _init(chunk_pos: Vector3i) -> void:
	position = chunk_pos * CHUNK_SIZE

func set_block(block_pos: Vector3i, block: Block) -> void:
	assert(block_pos.x in range(CHUNK_SIZE) and block_pos.y in range(CHUNK_SIZE) and \
		block_pos.z in range(CHUNK_SIZE))
	_blocks[block_pos] = block
	
	mesh_dirty = true

func get_block(block_pos: Vector3i) -> Block:
	return _blocks.get(block_pos)

func mesh() -> void:
	if not mesh_dirty:
		return
	
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(MATERIAL)
	for block_pos in _blocks.keys():
		var block := _blocks[block_pos]
		if not block:
			continue
		
		block.emit_mesh(st, block_pos, self)
	
	st.index()
	
	# TODO: incremental mesh updates
	if _mesh_instance:
		_mesh_instance.queue_free()
	_mesh_instance = MeshInstance3D.new()
	_mesh_instance.mesh = st.commit()
	_mesh_instance.create_trimesh_collision()
	add_child(_mesh_instance)
	
	mesh_dirty = false
