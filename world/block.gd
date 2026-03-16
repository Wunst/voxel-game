extends RefCounted
class_name Block

static var DIRT := Block.new({
	"side_face_index": 0,
})
static var GRASS := Block.new({
	"top_face_index": 2,
	"side_face_index": 1,
	"bottom_face_index": 0,
})
static var STONE := Block.new({
	"side_face_index": 6,
})
static var WOOD := Block.new({
	"side_face_index": 3,
	"top_face_index": 4,
	"bottom_face_index": 4,
})
static var LEAVES := Block.new({
	"side_face_index": 5,
	"is_opaque": false,
})

# Size of the texture atlas in tiles.
const ATLAS_SIZE := 3

## Size of each block texture.
const TEXTURE_SIZE := 16

# See below for property format.
var properties := {}

func _init(properties: Dictionary = {}) -> void:
	self.properties = properties.merged({
		"is_opaque": true,
		
		## Tile indices for each face.
		# "top_face_index": int,
		# "bottom_face_index": int,
		# "side_face_index": int, # required
	})

func emit_mesh(st: SurfaceTool, block_pos: Vector3i, chunk_in: Chunk) -> void:
	# Mesh faces for each voxel.
	const FACES := {
		Vector3i.LEFT: [Vector3(0, 1, 0), Vector3(0, 1, 1), Vector3(0, 0, 1), Vector3(0, 0, 0)],
		Vector3i.RIGHT: [Vector3(1, 1, 1), Vector3(1, 1, 0), Vector3(1, 0, 0), Vector3(1, 0, 1)],
		Vector3i.UP: [Vector3(0, 1, 0), Vector3(1, 1, 0), Vector3(1, 1, 1), Vector3(0, 1, 1)],
		Vector3i.DOWN: [Vector3(0, 0, 1), Vector3(1, 0, 1), Vector3(1, 0, 0), Vector3(0, 0, 0)],
		Vector3i.BACK: [Vector3(0, 1, 1), Vector3(1, 1, 1), Vector3(1, 0, 1), Vector3(0, 0, 1)],
		Vector3i.FORWARD: [Vector3(1, 1, 0), Vector3(0, 1, 0), Vector3(0, 0, 0), Vector3(1, 0, 0)],
	}
	
	for dir in FACES.keys():
		var adjacent: Block = chunk_in.get_block(block_pos + dir)
		if adjacent and adjacent.properties["is_opaque"]:
			# Face is obscured.
			continue
		
		var vertices: Array[Vector3]
		vertices.assign(FACES[dir])
		_emit_quad(st, Vector3(block_pos), vertices, _get_uvs(dir))

func _emit_quad(st: SurfaceTool, pos: Vector3, vertices: Array[Vector3], uvs: Array[Vector2]) -> void:
	for i in [0, 1, 2, 2, 3, 0]:
		st.set_uv(uvs[i])
		st.add_vertex(pos + vertices[i])

func _get_uvs(dir: Vector3i) -> Array[Vector2]:
	var tile_index: int = properties["side_face_index"]
	if dir == Vector3i.UP:
		tile_index = properties.get("top_face_index", tile_index)
	elif dir == Vector3i.DOWN:
		tile_index = properties.get("bottom_face_index", tile_index)
	
	var start_uv := Vector2(tile_index % ATLAS_SIZE, tile_index / ATLAS_SIZE)
	return [
		start_uv / ATLAS_SIZE,
		(start_uv + Vector2.RIGHT) / ATLAS_SIZE,
		(start_uv + Vector2.ONE) / ATLAS_SIZE,
		(start_uv + Vector2.DOWN) / ATLAS_SIZE,
	]
