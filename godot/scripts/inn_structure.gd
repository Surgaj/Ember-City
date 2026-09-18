extends Node3D

# EMBER INN — Godot Rebuild / Milestone 0.1
# Scope of this scene: architecture only.
# No guests, economy, furniture, Ember, landscaping or exterior props yet.

const WALL_HEIGHT := 3.4
const PARTITION_HEIGHT := 1.75
const WALL_THICKNESS := 0.22

const FLOOR_COLOR := Color("#A96F47")
const FOUNDATION_COLOR := Color("#5D5147")
const WALL_COLOR := Color("#E7D3B3")
const WALL_INNER_COLOR := Color("#DCC29F")
const BEAM_COLOR := Color("#5D3E2E")
const THRESHOLD_COLOR := Color("#7B5238")
const PLANK_LINE_COLOR := Color("#785039")

@onready var architecture: Node3D = $Architecture

var camera: Camera3D


func _ready() -> void:
	_setup_environment()
	_setup_camera()
	_build_structure()
	get_viewport().size_changed.connect(_fit_camera)
	_fit_camera()


func _setup_environment() -> void:
	var world := WorldEnvironment.new()
	world.name = "WorldEnvironment"

	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#86AAA5")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#E8DDC9")
	environment.ambient_light_energy = 0.8
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = environment
	add_child(world)

	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.light_color = Color("#FFF0D2")
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	sun.rotation_degrees = Vector3(-52.0, -38.0, 0.0)
	add_child(sun)

	var fill := DirectionalLight3D.new()
	fill.name = "SoftFill"
	fill.light_color = Color("#B7D1D5")
	fill.light_energy = 0.28
	fill.shadow_enabled = false
	fill.rotation_degrees = Vector3(-28.0, 132.0, 0.0)
	add_child(fill)


func _setup_camera() -> void:
	camera = Camera3D.new()
	camera.name = "IsometricCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.keep_aspect = Camera3D.KEEP_HEIGHT
	camera.current = true
	camera.near = 0.1
	camera.far = 80.0
	add_child(camera)

	camera.position = Vector3(12.5, 11.0, 13.5)
	camera.look_at(Vector3(0.0, 0.9, 0.0), Vector3.UP)


func _fit_camera() -> void:
	if camera == null:
		return

	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.y <= 0.0:
		return

	var aspect := viewport_size.x / viewport_size.y
	camera.size = 15.8 if aspect < 0.75 else 13.5


func _build_structure() -> void:
	_build_foundation()
	_build_floor()
	_build_back_wall()
	_build_left_wall()
	_build_interior_partitions()
	_build_timber_frame()
	_build_entrance_frame()


func _build_foundation() -> void:
	_box(
		"Foundation",
		Vector3(12.8, 0.34, 10.8),
		Vector3(0.0, -0.19, 0.0),
		FOUNDATION_COLOR
	)


func _build_floor() -> void:
	_box(
		"InteriorFloor",
		Vector3(12.0, 0.18, 10.0),
		Vector3(0.0, 0.08, 0.0),
		FLOOR_COLOR
	)

	# Subtle raised seams give the floor scale without turning it into a grid.
	for z_index in range(-4, 5):
		_box(
			"FloorSeam_%s" % z_index,
			Vector3(11.75, 0.012, 0.025),
			Vector3(0.0, 0.177, float(z_index)),
			PLANK_LINE_COLOR,
			0.72,
			false
		)


func _build_back_wall() -> void:
	var z := -4.88

	# Lower and upper rails create real window openings instead of painted windows.
	_box("BackWallLower", Vector3(12.0, 0.78, WALL_THICKNESS), Vector3(0.0, 0.39, z), WALL_COLOR)
	_box("BackWallUpper", Vector3(12.0, 0.66, WALL_THICKNESS), Vector3(0.0, 3.07, z), WALL_COLOR)

	var middle_height := 1.96
	var middle_y := 1.76
	var segments := [
		{"x": -5.325, "width": 0.75},
		{"x": -2.10, "width": 2.70},
		{"x": 2.10, "width": 2.70},
		{"x": 5.325, "width": 0.75},
	]

	for index in segments.size():
		var segment: Dictionary = segments[index]
		_box(
			"BackWallPier_%s" % index,
			Vector3(float(segment.width), middle_height, WALL_THICKNESS),
			Vector3(float(segment.x), middle_y, z),
			WALL_COLOR
		)

	# Deep wooden sills make the three openings read as real windows.
	for window_x in [-4.2, 0.0, 4.2]:
		_box(
			"BackWindowSill_%s" % str(window_x),
			Vector3(1.55, 0.10, 0.38),
			Vector3(window_x, 0.82, z + 0.02),
			BEAM_COLOR
		)
		_box(
			"BackWindowHeader_%s" % str(window_x),
			Vector3(1.55, 0.12, 0.32),
			Vector3(window_x, 2.73, z + 0.02),
			BEAM_COLOR
		)


func _build_left_wall() -> void:
	var x_pos := -5.88

	_box("LeftWallLower", Vector3(WALL_THICKNESS, 0.78, 10.0), Vector3(x_pos, 0.39, 0.0), WALL_COLOR)
	_box("LeftWallUpper", Vector3(WALL_THICKNESS, 0.66, 10.0), Vector3(x_pos, 3.07, 0.0), WALL_COLOR)

	# One broad side window. The front side remains open for the tycoon cutaway view.
	_box(
		"LeftWallBack",
		Vector3(WALL_THICKNESS, 1.96, 3.55),
		Vector3(x_pos, 1.76, -3.0),
		WALL_COLOR
	)
	_box(
		"LeftWallFront",
		Vector3(WALL_THICKNESS, 1.96, 3.55),
		Vector3(x_pos, 1.76, 3.0),
		WALL_COLOR
	)
	_box(
		"LeftWindowSill",
		Vector3(0.38, 0.10, 2.0),
		Vector3(x_pos + 0.02, 0.82, 0.0),
		BEAM_COLOR
	)
	_box(
		"LeftWindowHeader",
		Vector3(0.32, 0.12, 2.0),
		Vector3(x_pos + 0.02, 2.73, 0.0),
		BEAM_COLOR
	)


func _build_interior_partitions() -> void:
	var y := PARTITION_HEIGHT * 0.5

	# Back-left bedroom. The gap between both segments is the real doorway.
	_box(
		"BedroomPartitionBack",
		Vector3(0.16, PARTITION_HEIGHT, 3.15),
		Vector3(-1.55, y, -3.25),
		WALL_INNER_COLOR
	)
	_box(
		"BedroomPartitionFront",
		Vector3(0.16, PARTITION_HEIGHT, 1.55),
		Vector3(-1.55, y, 0.80),
		WALL_INNER_COLOR
	)

	# Café wall deliberately stops early so service remains visually connected to the lobby.
	_box(
		"CafePartition",
		Vector3(0.16, PARTITION_HEIGHT, 2.95),
		Vector3(2.05, y, -3.33),
		WALL_INNER_COLOR
	)

	# Future wing on the right-front. Two segments leave a door-sized opening.
	_box(
		"FutureWingPartitionLeft",
		Vector3(1.15, 2.15, 0.18),
		Vector3(3.10, 1.075, 1.15),
		WALL_INNER_COLOR
	)
	_box(
		"FutureWingPartitionRight",
		Vector3(1.00, 2.15, 0.18),
		Vector3(5.15, 1.075, 1.15),
		WALL_INNER_COLOR
	)

	# Door posts make the locked expansion entrance obvious before any gameplay exists.
	_box("FutureDoorPostL", Vector3(0.16, 2.20, 0.24), Vector3(3.70, 1.10, 1.15), BEAM_COLOR)
	_box("FutureDoorPostR", Vector3(0.16, 2.20, 0.24), Vector3(4.55, 1.10, 1.15), BEAM_COLOR)
	_box("FutureDoorHeader", Vector3(1.02, 0.16, 0.24), Vector3(4.125, 2.16, 1.15), BEAM_COLOR)


func _build_timber_frame() -> void:
	# Structural top beams and posts sell the building as architecture rather than boxes.
	_box("BackTopBeam", Vector3(12.15, 0.18, 0.30), Vector3(0.0, WALL_HEIGHT, -4.88), BEAM_COLOR)
	_box("LeftTopBeam", Vector3(0.30, 0.18, 10.15), Vector3(-5.88, WALL_HEIGHT, 0.0), BEAM_COLOR)

	for post_x in [-5.88, -1.55, 2.05, 5.88]:
		_box(
			"BackPost_%s" % str(post_x),
			Vector3(0.22, WALL_HEIGHT, 0.26),
			Vector3(post_x, WALL_HEIGHT * 0.5, -4.88),
			BEAM_COLOR
		)

	_box(
		"LeftFrontPost",
		Vector3(0.26, WALL_HEIGHT, 0.22),
		Vector3(-5.88, WALL_HEIGHT * 0.5, 4.88),
		BEAM_COLOR
	)


func _build_entrance_frame() -> void:
	# This is the only front structure for now: a clear visual entry axis into the lobby.
	_box(
		"EntranceThreshold",
		Vector3(2.55, 0.12, 0.72),
		Vector3(0.0, 0.16, 4.72),
		THRESHOLD_COLOR
	)
	_box(
		"EntrancePostLeft",
		Vector3(0.22, 2.55, 0.22),
		Vector3(-1.12, 1.36, 4.62),
		BEAM_COLOR
	)
	_box(
		"EntrancePostRight",
		Vector3(0.22, 2.55, 0.22),
		Vector3(1.12, 1.36, 4.62),
		BEAM_COLOR
	)
	_box(
		"EntranceHeader",
		Vector3(2.46, 0.22, 0.24),
		Vector3(0.0, 2.58, 4.62),
		BEAM_COLOR
	)


func _box(
	node_name: String,
	size: Vector3,
	position: Vector3,
	color: Color,
	roughness: float = 0.88,
	casts_shadow: bool = true
) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size

	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = 0.0

	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = position
	instance.material_override = material
	instance.cast_shadow = (
		GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		if casts_shadow
		else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	)

	architecture.add_child(instance)
	return instance
