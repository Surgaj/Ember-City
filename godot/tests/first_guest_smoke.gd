extends SceneTree

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load("res://scenes/inn_structure.tscn") as PackedScene
	if packed == null:
		_fail("Could not load inn_structure.tscn")
		return

	var scene := packed.instantiate()
	root.add_child(scene)

	await process_frame
	await physics_frame
	await physics_frame

	var guest := scene.get_node_or_null("Actors/TestGuest") as CharacterBody3D
	var region := scene.get_node_or_null("NavigationRegion3D") as NavigationRegion3D
	var door := scene.get_node_or_null("InteriorProps/BedroomDoorLeaf") as MeshInstance3D
	var receptionist := scene.get_node_or_null("Actors/Receptionist") as Node3D
	var flame := scene.get_node_or_null("InteriorProps/EmberFlameLow") as MeshInstance3D

	if guest == null:
		_fail("TestGuest was not spawned")
		return
	if region == null or region.navigation_mesh == null:
		_fail("NavigationRegion3D has no NavigationMesh")
		return
	if door == null:
		_fail("Bedroom door was not created")
		return
	if receptionist == null:
		_fail("Receptionist was not spawned")
		return
	if flame == null:
		_fail("Ember flame was not created")
		return

	var flame_start_position := flame.position
	var flame_start_scale := flame.scale
	var start_position := guest.global_position
	await create_timer(1.6).timeout
	var moved_distance := Vector2(
		guest.global_position.x - start_position.x,
		guest.global_position.z - start_position.z
	).length()

	if moved_distance < 0.35:
		_fail("TestGuest did not move far enough: %.3f" % moved_distance)
		return

	var flame_position_delta := flame.position.distance_to(flame_start_position)
	var flame_scale_delta := flame.scale.distance_to(flame_start_scale)
	if flame_position_delta < 0.005 and flame_scale_delta < 0.01:
		_fail("Ember flame did not visibly animate")
		return

	print("FIRST GUEST PASS: moved %.3f meters, receptionist present, Ember animated" % moved_distance)
	quit(0)


func _fail(message: String) -> void:
	push_error("FIRST GUEST FAIL: " + message)
	quit(1)
