extends CharacterBody3D
class_name Player

@export var world_in: World

const SPEED := 5.0
const GRAVITY := 18.0
const JUMP_VELOCITY := 8.0

@onready var camera := $Camera3D
@onready var ray: RayCast3D = $Camera3D/RayCast3D
@onready var block_sprite: Sprite2D = $HUD/BlockSprite/Sprite2D

var block_looking_at := Vector3i.MIN
var block_placing_to := Vector3i.MIN

static var blocks_can_place := [
	Block.DIRT,
	Block.GRASS,
	Block.STONE,
	Block.WOOD,
	Block.LEAVES,
]

var block_to_place := 0

func _physics_process(delta: float) -> void:
	# Turn around.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var mouse_delta := Input.get_last_mouse_velocity() * delta * 0.025
	rotate_y(-mouse_delta.x)
	camera.rotation.x = clampf(camera.rotation.x - mouse_delta.y, -PI/2, PI/2)
	
	# Placing and breaking blocks.
	if ray.is_colliding():
		var pos := ray.get_collision_point()
		var normal := ray.get_collision_normal()
		block_looking_at = Vector3i(pos - normal * .5)
		block_placing_to = Vector3i(pos + normal * .5)
	else:
		block_looking_at = Vector3i.MIN
	
	if Input.is_action_just_pressed("next_block"):
		block_to_place += 1
	elif Input.is_action_just_pressed("prev_block"):
		block_to_place -= 1
	block_to_place %= blocks_can_place.size()
	
	# TODO: find a less convoluted method of using UVs here
	block_sprite.region_rect.position = blocks_can_place[block_to_place].uvs[0] * Block.ATLAS_SIZE * 16
	
	if block_looking_at != Vector3i.MIN:
		if Input.is_action_just_pressed("break"):
			world_in.break_block(block_looking_at)
		elif Input.is_action_just_pressed("place"):
			# FIXME: prevent player from placing inside self
			assert(not world_in.blocks.get(block_placing_to))
			world_in.set_block(block_placing_to, blocks_can_place[block_to_place])
	
	# Add gravity.
	velocity.y -= GRAVITY * delta
	
	# Handle jump.
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
	
	# Handle horizontal movement.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var world_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	velocity.x = world_dir.x * SPEED
	velocity.z = world_dir.z * SPEED
	
	move_and_slide()
