extends RefCounted
class_name Block

static var DIRT := Block.new(0)
static var GRASS := Block.new(2)
static var STONE := Block.new(6)
static var WOOD := Block.new(3)
static var LEAVES := Block.new(5, false)

# Size of the texture atlas in tiles.
const ATLAS_SIZE := 3

# Mesh faces for each voxel.
const FACES := {
	Vector3i.LEFT: [Vector3(0, 1, 0), Vector3(0, 1, 1), Vector3(0, 0, 1), Vector3(0, 0, 0)],
	Vector3i.RIGHT: [Vector3(1, 1, 1), Vector3(1, 1, 0), Vector3(1, 0, 0), Vector3(1, 0, 1)],
	Vector3i.UP: [Vector3(0, 1, 0), Vector3(1, 1, 0), Vector3(1, 1, 1), Vector3(0, 1, 1)],
	Vector3i.DOWN: [Vector3(0, 0, 1), Vector3(1, 0, 1), Vector3(1, 0, 0), Vector3(0, 0, 0)],
	Vector3i.BACK: [Vector3(0, 1, 1), Vector3(1, 1, 1), Vector3(1, 0, 1), Vector3(0, 0, 1)],
	Vector3i.FORWARD: [Vector3(1, 1, 0), Vector3(0, 1, 0), Vector3(0, 0, 0), Vector3(1, 0, 0)],
}

var uvs: Array[Vector2]
var is_opaque: bool

func _init(tile_index: int, opaque: bool = true) -> void:
	var start_uv := Vector2(tile_index % ATLAS_SIZE, tile_index / ATLAS_SIZE)
	uvs = [
		start_uv / ATLAS_SIZE,
		(start_uv + Vector2.RIGHT) / ATLAS_SIZE,
		(start_uv + Vector2.ONE) / ATLAS_SIZE,
		(start_uv + Vector2.DOWN) / ATLAS_SIZE,
	]
	
	is_opaque = opaque

func emit_mesh(st: SurfaceTool, block_pos: Vector3i, world_in: World) -> void:
	for dir in FACES.keys():
		var adjacent: Block = world_in.blocks.get(block_pos + dir)
		if adjacent and adjacent.is_opaque:
			# Face is obscured.
			continue
		
		var vertices: Array[Vector3]
		vertices.assign(FACES[dir])
		_emit_quad(st, Vector3(block_pos), vertices, uvs)

func _emit_quad(st: SurfaceTool, pos: Vector3, vertices: Array[Vector3], uvs: Array[Vector2]) -> void:
	for i in [0, 1, 2, 2, 3, 0]:
		st.set_uv(uvs[i])
		st.add_vertex(pos + vertices[i])
