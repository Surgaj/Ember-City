extends Node3D

# EMBER INN — Godot Rebuild / Milestone 0.3
# Scope: architecture + exterior + first interior identity pass.
# No guests, navigation, economy or upgrade systems yet.

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

const TERRAIN_COLOR := Color("#6F9D73")
const GRASS_LIGHT_COLOR := Color("#82B77B")
const GRASS_DARK_COLOR := Color("#587F5D")
const PATH_COLOR := Color("#C9A46C")
const PATH_EDGE_COLOR := Color("#8C6B4B")
const CLEARING_COLOR := Color("#9BB27A")
const ROCK_COLOR := Color("#737A70")
const ROCK_LIGHT_COLOR := Color("#8A9186")
const TREE_TRUNK_COLOR := Color("#684832")
const TREE_LEAF_COLOR := Color("#4E7B58")
const TREE_LEAF_LIGHT_COLOR := Color("#639567")

const EMBER_STONE_COLOR := Color("#72665A")
const EMBER_STONE_LIGHT_COLOR := Color("#8A7C6D")
const EMBER_LOG_COLOR := Color("#5A3827")
const EMBER_COAL_COLOR := Color("#2F2622")
const EMBER_ORANGE := Color("#FF8A3D")
const EMBER_GOLD := Color("#FFC75A")
const RECEPTION_WOOD := Color("#704731")
const RECEPTION_TOP := Color("#B77A4E")
const DARK_WOOD := Color("#4F352A")
const BED_FRAME_COLOR := Color("#694635")
const MATTRESS_COLOR := Color("#E7D7BE")
const PILLOW_COLOR := Color("#F7EEE0")
const BLANKET_COLOR := Color("#A96D63")
const CAFE_WOOD := Color("#795039")
const CAFE_TOP := Color("#C38959")
const METAL_COLOR := Color("#59625E")
const RUG_COLOR := Color("#8B5D56")

@onready var surroundings: Node3D = $Surroundings
@onready var architecture: Node3D = $Architecture
@onready var interior_props: Node3D = $InteriorProps

var camera: Camera3D
var ember_light: OmniLight3D


func _ready() -> void:
	_setup_environment()
	_setup_camera()
	_build_surroundings()
	_build_structure()
	_build_interior_identity()
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
	environment.ambient_light_energy = 0.58
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = environment
	add_child(world)

	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.light_color = Color("#FFF0D2")
	sun.light_energy = 0.88
	sun.shadow_enabled = true
	sun.rotation_degrees = Vector3(-52.0, -38.0, 0.0)
	add_child(sun)

	var fill := DirectionalLight3D.new()
	fill.name = "SoftFill"
	fill.light_color = Color("#B7D1D5")
	fill.light_energy = 0.18
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


func _process(_delta: float) -> void:
	if ember_light == null:
		return

	var ticks := float(Time.get_ticks_msec()) * 0.006
	ember_light.light_energy = 2.45 + sin(ticks) * 0.16 + sin(ticks * 2.3) * 0.06


func _fit_camera() -> void:
	if camera == null:
		return

	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.y <= 0.0:
		return

	var aspect := viewport_size.x / viewport_size.y
	camera.size = 17.4 if aspect < 0.75 else 14.8


func _build_surroundings() -> void:
	_build_ground()
	_build_entry_path()
	_build_expansion_clearing()
	_build_landscape_props()


func _build_ground() -> void:
	# A broad, calm terrain pad keeps the inn from floating in empty space.
	_box(
		"TerrainBase",
		Vector3(20.0, 0.52, 17.2),
		Vector3(0.0, -0.66, 0.65),
		TERRAIN_COLOR,
		0.98,
		false,
		surroundings
	)

	# Soft grass islands break the rectangular silhouette without cluttering gameplay space.
	_cylinder(
		"GrassPatchBackLeft",
		2.65,
		0.07,
		Vector3(-7.1, -0.365, -4.8),
		GRASS_DARK_COLOR,
		24,
		false
	)
	_cylinder(
		"GrassPatchBackRight",
		2.35,
		0.065,
		Vector3(7.2, -0.362, -4.2),
		GRASS_LIGHT_COLOR,
		24,
		false
	)
	_cylinder(
		"GrassPatchFrontLeft",
		2.15,
		0.055,
		Vector3(-7.4, -0.36, 5.4),
		GRASS_LIGHT_COLOR,
		24,
		false
	)


func _build_entry_path() -> void:
	# The path is centered exactly on the architectural entrance, making the flow unmistakable.
	_box(
		"EntryPath",
		Vector3(2.55, 0.08, 4.2),
		Vector3(0.0, -0.355, 6.75),
		PATH_COLOR,
		0.96,
		false,
		surroundings
	)

	# Darker edge strips give the path weight and stop it from looking painted onto the grass.
	_box(
		"EntryPathEdgeLeft",
		Vector3(0.16, 0.055, 4.3),
		Vector3(-1.34, -0.345, 6.75),
		PATH_EDGE_COLOR,
		0.92,
		false,
		surroundings
	)
	_box(
		"EntryPathEdgeRight",
		Vector3(0.16, 0.055, 4.3),
		Vector3(1.34, -0.345, 6.75),
		PATH_EDGE_COLOR,
		0.92,
		false,
		surroundings
	)

	# Three shallow approach stones subtly pull the eye from the screen edge toward the doorway.
	for index in range(3):
		var z_pos := 8.48 - float(index) * 0.62
		_box(
			"ApproachStone_%s" % index,
			Vector3(2.18 - float(index) * 0.12, 0.07, 0.34),
			Vector3(0.0, -0.30, z_pos),
			PATH_EDGE_COLOR,
			0.94,
			false,
			surroundings
		)


func _build_expansion_clearing() -> void:
	# A deliberately empty pad communicates future growth without inventing gameplay yet.
	_cylinder(
		"FutureExpansionClearing",
		2.15,
		0.075,
		Vector3(7.25, -0.35, 2.25),
		CLEARING_COLOR,
		28,
		false
	)

	var marker_positions := [
		Vector3(5.55, -0.29, 1.05),
		Vector3(8.85, -0.29, 1.10),
		Vector3(5.75, -0.29, 3.70),
		Vector3(8.65, -0.29, 3.65),
	]
	for index in range(marker_positions.size()):
		_rock(
			"ExpansionMarker_%s" % index,
			marker_positions[index],
			Vector3(0.34, 0.22, 0.34),
			ROCK_LIGHT_COLOR
		)


func _build_landscape_props() -> void:
	# Trees live on the perimeter so they frame the inn instead of blocking the cutaway.
	_tree("TreeBackLeft", Vector3(-7.8, -0.39, -5.8), 1.05)
	_tree("TreeFarLeft", Vector3(-8.35, -0.39, 0.45), 0.86)
	_tree("TreeBackRight", Vector3(7.65, -0.39, -5.35), 0.96)
	_tree("TreeRearCluster", Vector3(3.55, -0.39, -7.05), 0.74)

	var rocks := [
		{"name": "RockLeftA", "pos": Vector3(-7.0, -0.30, 3.3), "scale": Vector3(0.55, 0.30, 0.42)},
		{"name": "RockLeftB", "pos": Vector3(-8.25, -0.30, 4.25), "scale": Vector3(0.34, 0.22, 0.30)},
		{"name": "RockBackA", "pos": Vector3(5.8, -0.30, -6.55), "scale": Vector3(0.44, 0.25, 0.34)},
		{"name": "RockRightA", "pos": Vector3(9.05, -0.30, -0.75), "scale": Vector3(0.48, 0.27, 0.37)},
	]
	for rock_data in rocks:
		_rock(
			String(rock_data["name"]),
			rock_data["pos"],
			rock_data["scale"],
			ROCK_COLOR
		)

	_bush("BushLeft", Vector3(-7.45, -0.33, 2.0), 0.52)
	_bush("BushBack", Vector3(6.2, -0.33, -5.7), 0.46)
	_bush("BushEntryLeft", Vector3(-2.15, -0.33, 6.05), 0.42)
	_bush("BushEntryRight", Vector3(2.15, -0.33, 6.05), 0.42)


func _build_interior_identity() -> void:
	_build_flow_rugs()
	_build_ember()
	_build_reception()
	_build_bedroom_props()
	_build_cafe_props()


func _build_flow_rugs() -> void:
	# The entrance runner points directly toward the Ember and keeps the lobby readable.
	_box(
		"LobbyRunner",
		Vector3(1.35, 0.035, 3.05),
		Vector3(0.0, 0.205, 2.85),
		RUG_COLOR,
		0.92,
		false,
		interior_props
	)
	_box(
		"ReceptionRug",
		Vector3(3.35, 0.032, 1.65),
		Vector3(-3.25, 0.205, 2.55),
		Color("#8F6B58"),
		0.94,
		false,
		interior_props
	)
	_box(
		"BedroomRug",
		Vector3(3.05, 0.032, 2.25),
		Vector3(-3.65, 0.205, -2.62),
		Color("#7C625C"),
		0.94,
		false,
		interior_props
	)


func _build_ember() -> void:
	var center := Vector3(0.0, 0.0, 0.20)

	# Raised hearth makes the Ember feel physically rooted in the inn.
	_cylinder(
		"EmberHearth",
		1.02,
		0.20,
		center + Vector3(0.0, 0.29, 0.0),
		EMBER_COAL_COLOR,
		20,
		true,
		interior_props
	)

	for index in range(12):
		var angle := TAU * float(index) / 12.0
		var stone_position := center + Vector3(cos(angle) * 0.88, 0.48, sin(angle) * 0.88)
		_sphere(
			"EmberStone_%s" % index,
			0.24,
			stone_position,
			EMBER_STONE_LIGHT_COLOR if index % 2 == 0 else EMBER_STONE_COLOR,
			Vector3(1.08, 0.62, 0.82),
			true,
			interior_props
		)

	var log_a := _box(
		"EmberLogA",
		Vector3(1.22, 0.20, 0.25),
		center + Vector3(0.0, 0.56, 0.0),
		EMBER_LOG_COLOR,
		0.96,
		true,
		interior_props
	)
	log_a.rotation_degrees.y = 36.0

	var log_b := _box(
		"EmberLogB",
		Vector3(1.22, 0.20, 0.25),
		center + Vector3(0.0, 0.60, 0.0),
		EMBER_LOG_COLOR,
		0.96,
		true,
		interior_props
	)
	log_b.rotation_degrees.y = -38.0

	_glowing_sphere(
		"EmberFlameLow",
		0.52,
		center + Vector3(0.0, 0.93, 0.0),
		EMBER_ORANGE,
		Vector3(0.78, 1.12, 0.78)
	)
	_glowing_sphere(
		"EmberFlameMid",
		0.38,
		center + Vector3(-0.10, 1.35, 0.03),
		EMBER_GOLD,
		Vector3(0.72, 1.35, 0.72)
	)
	_glowing_sphere(
		"EmberFlameTip",
		0.25,
		center + Vector3(0.10, 1.72, -0.02),
		Color("#FFF0A8"),
		Vector3(0.66, 1.46, 0.66)
	)

	ember_light = OmniLight3D.new()
	ember_light.name = "EmberWarmLight"
	ember_light.position = center + Vector3(0.0, 1.35, 0.0)
	ember_light.light_color = Color("#FF9B4A")
	ember_light.light_energy = 2.45
	ember_light.omni_range = 7.4
	ember_light.shadow_enabled = true
	interior_props.add_child(ember_light)


func _build_reception() -> void:
	# Immediately visible from the entrance and deliberately offset left of the Ember.
	_box(
		"ReceptionDesk",
		Vector3(3.00, 0.88, 0.82),
		Vector3(-3.25, 0.62, 2.60),
		RECEPTION_WOOD,
		0.90,
		true,
		interior_props
	)
	_box(
		"ReceptionTop",
		Vector3(3.18, 0.16, 0.96),
		Vector3(-3.25, 1.13, 2.60),
		RECEPTION_TOP,
		0.78,
		true,
		interior_props
	)
	_box(
		"ReceptionFrontPanel",
		Vector3(2.55, 0.44, 0.08),
		Vector3(-3.25, 0.61, 3.03),
		DARK_WOOD,
		0.94,
		true,
		interior_props
	)

	# Small register + bell instantly communicate the function of this station.
	_box(
		"ReceptionRegister",
		Vector3(0.55, 0.34, 0.44),
		Vector3(-2.62, 1.39, 2.55),
		METAL_COLOR,
		0.62,
		true,
		interior_props
	)
	_cylinder(
		"ReceptionBell",
		0.14,
		0.16,
		Vector3(-3.95, 1.30, 2.57),
		EMBER_GOLD,
		14,
		true,
		interior_props
	)

	# Key rack behind the desk, ready for the later check-in animation.
	_box(
		"ReceptionKeyRack",
		Vector3(2.25, 0.92, 0.16),
		Vector3(-3.25, 1.64, 3.42),
		DARK_WOOD,
		0.92,
		true,
		interior_props
	)
	for key_index in range(4):
		_cylinder(
			"KeyPeg_%s" % key_index,
			0.045,
			0.16,
			Vector3(-4.05 + float(key_index) * 0.54, 1.67, 3.30),
			EMBER_GOLD,
			8,
			true,
			interior_props
		)


func _build_bedroom_props() -> void:
	var bed_center := Vector3(-3.78, 0.0, -2.62)

	_box(
		"BedFrame",
		Vector3(2.70, 0.28, 1.82),
		bed_center + Vector3(0.0, 0.36, 0.0),
		BED_FRAME_COLOR,
		0.94,
		true,
		interior_props
	)
	_box(
		"Mattress",
		Vector3(2.48, 0.30, 1.62),
		bed_center + Vector3(0.0, 0.64, 0.0),
		MATTRESS_COLOR,
		0.98,
		true,
		interior_props
	)
	_box(
		"Blanket",
		Vector3(1.32, 0.08, 1.52),
		bed_center + Vector3(0.48, 0.83, 0.0),
		BLANKET_COLOR,
		0.98,
		true,
		interior_props
	)
	_box(
		"Pillow",
		Vector3(0.64, 0.18, 1.12),
		bed_center + Vector3(-0.82, 0.88, 0.0),
		PILLOW_COLOR,
		1.0,
		true,
		interior_props
	)
	_box(
		"BedHeadboard",
		Vector3(0.16, 1.18, 1.92),
		bed_center + Vector3(-1.34, 0.86, 0.0),
		DARK_WOOD,
		0.92,
		true,
		interior_props
	)

	_box(
		"BedsideTable",
		Vector3(0.62, 0.64, 0.62),
		Vector3(-2.18, 0.49, -3.25),
		RECEPTION_WOOD,
		0.92,
		true,
		interior_props
	)


func _build_cafe_props() -> void:
	# The café lives in the back-right room, visually balancing the bedroom.
	_box(
		"CafeCounter",
		Vector3(3.05, 0.88, 0.82),
		Vector3(3.75, 0.62, -2.42),
		CAFE_WOOD,
		0.90,
		true,
		interior_props
	)
	_box(
		"CafeCounterTop",
		Vector3(3.22, 0.15, 0.96),
		Vector3(3.75, 1.13, -2.42),
		CAFE_TOP,
		0.80,
		true,
		interior_props
	)
	_box(
		"CoffeeMachine",
		Vector3(0.88, 0.78, 0.62),
		Vector3(3.20, 1.57, -2.47),
		METAL_COLOR,
		0.58,
		true,
		interior_props
	)
	_box(
		"PastryCase",
		Vector3(0.88, 0.55, 0.62),
		Vector3(4.55, 1.45, -2.47),
		Color("#C99A69"),
		0.72,
		true,
		interior_props
	)

	for stool_index in range(2):
		_cylinder(
			"CafeStool_%s" % stool_index,
			0.31,
			0.72,
			Vector3(3.15 + float(stool_index) * 1.25, 0.54, -1.32),
			DARK_WOOD,
			14,
			true,
			interior_props
		)


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

	for index in range(segments.size()):
		var segment: Dictionary = segments[index]
		_box(
			"BackWallPier_%s" % index,
			Vector3(float(segment["width"]), middle_height, WALL_THICKNESS),
			Vector3(float(segment["x"]), middle_y, z),
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
	casts_shadow: bool = true,
	parent: Node3D = null
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

	var target_parent: Node3D = architecture if parent == null else parent
	target_parent.add_child(instance)
	return instance


func _cylinder(
	node_name: String,
	radius: float,
	height: float,
	position: Vector3,
	color: Color,
	segments: int = 16,
	casts_shadow: bool = true,
	parent: Node3D = null
) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = segments

	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.96

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
	var target_parent: Node3D = surroundings if parent == null else parent
	target_parent.add_child(instance)
	return instance


func _sphere(
	node_name: String,
	radius: float,
	position: Vector3,
	color: Color,
	scale_value: Vector3 = Vector3.ONE,
	casts_shadow: bool = true,
	parent: Node3D = null
) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 10
	mesh.rings = 6

	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.94

	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = position
	instance.scale = scale_value
	instance.material_override = material
	instance.cast_shadow = (
		GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		if casts_shadow
		else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	)
	var target_parent: Node3D = surroundings if parent == null else parent
	target_parent.add_child(instance)
	return instance


func _glowing_sphere(
	node_name: String,
	radius: float,
	position: Vector3,
	color: Color,
	scale_value: Vector3
) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 12
	mesh.rings = 8

	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.42
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 2.4

	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = position
	instance.scale = scale_value
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	interior_props.add_child(instance)
	return instance


func _tree(node_name: String, ground_position: Vector3, size_scale: float = 1.0) -> void:
	var trunk_height := 1.62 * size_scale
	_cylinder(
		node_name + "Trunk",
		0.18 * size_scale,
		trunk_height,
		ground_position + Vector3(0.0, trunk_height * 0.5, 0.0),
		TREE_TRUNK_COLOR,
		9,
		true
	)

	_sphere(
		node_name + "CrownLow",
		0.86 * size_scale,
		ground_position + Vector3(-0.18 * size_scale, 1.48 * size_scale, 0.04),
		TREE_LEAF_COLOR,
		Vector3(1.05, 0.82, 0.94)
	)
	_sphere(
		node_name + "CrownHigh",
		0.76 * size_scale,
		ground_position + Vector3(0.22 * size_scale, 2.02 * size_scale, -0.08),
		TREE_LEAF_LIGHT_COLOR,
		Vector3(0.94, 1.02, 0.92)
	)
	_sphere(
		node_name + "CrownSide",
		0.61 * size_scale,
		ground_position + Vector3(0.62 * size_scale, 1.54 * size_scale, 0.10),
		TREE_LEAF_COLOR,
		Vector3(0.88, 0.78, 0.92)
	)


func _rock(node_name: String, position: Vector3, scale_value: Vector3, color: Color) -> void:
	_sphere(
		node_name,
		0.62,
		position,
		color,
		scale_value,
		true
	)


func _bush(node_name: String, position: Vector3, size_scale: float) -> void:
	_sphere(
		node_name + "A",
		0.62 * size_scale,
		position + Vector3(-0.18 * size_scale, 0.20 * size_scale, 0.0),
		TREE_LEAF_COLOR,
		Vector3(1.0, 0.75, 0.9),
		true
	)
	_sphere(
		node_name + "B",
		0.54 * size_scale,
		position + Vector3(0.24 * size_scale, 0.22 * size_scale, 0.06),
		TREE_LEAF_LIGHT_COLOR,
		Vector3(0.9, 0.72, 0.86),
		true
	)
