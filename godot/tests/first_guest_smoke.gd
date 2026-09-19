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
	var guest_key := scene.get_node_or_null("Actors/TestGuest/VisualRoot/CarryAnchor") as Node3D
	var camera := scene.get_node_or_null("IsometricCamera") as Camera3D
	var ember_collider := scene.get_node_or_null("PhysicsColliders/EmberCollider") as StaticBody3D
	var reception_collider := scene.get_node_or_null("PhysicsColliders/ReceptionCollider") as StaticBody3D

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
	if guest_key == null:
		_fail("Guest physical key anchor is missing")
		return
	if camera == null:
		_fail("Isometric camera is missing")
		return
	if ember_collider == null or reception_collider == null:
		_fail("Physical world colliders are missing")
		return

	var camera_start_position := camera.position
	scene.call("_pan_camera", Vector2(80.0, 0.0))
	await create_timer(0.25).timeout
	if camera.position.distance_to(camera_start_position) < 0.05:
		_fail("Camera pan did not move the isometric camera")
		return

	var camera_size_before_zoom := camera.size
	scene.call("_zoom_camera", 0.72)
	await create_timer(0.25).timeout
	if absf(camera.size - camera_size_before_zoom) < 0.25:
		_fail("Camera zoom did not change orthographic size")
		return

	receptionist.call("serve_checkin")
	await create_timer(0.95).timeout
	if not guest_key.visible:
		_fail("Receptionist did not hand the physical key to the guest")
		return

	var flame_start_position := flame.position
	var flame_start_scale := flame.scale
	var start_position := guest.global_position
	var minimum_ember_distance := 999.0
	var illegal_wall_crossing := false

	for sample_index in range(105):
		await create_timer(0.10).timeout
		var guest_pos := guest.global_position
		var ember_distance := Vector2(
			guest_pos.x - 0.0,
			guest_pos.z - 0.20
		).length()
		minimum_ember_distance = minf(minimum_ember_distance, ember_distance)

		var inside_bedroom_side := guest_pos.x < -1.55
		var in_real_door_gap := guest_pos.z > -1.67 and guest_pos.z < 0.02
		if inside_bedroom_side and not in_real_door_gap and guest_pos.z > -1.67:
			illegal_wall_crossing = true
			break

	var moved_distance := Vector2(
		guest.global_position.x - start_position.x,
		guest.global_position.z - start_position.z
	).length()

	if moved_distance < 0.35:
		_fail("TestGuest did not move far enough: %.3f" % moved_distance)
		return
	if minimum_ember_distance < 1.08:
		_fail("TestGuest entered Ember safety radius: %.3f" % minimum_ember_distance)
		return
	if illegal_wall_crossing:
		_fail("TestGuest crossed bedroom wall outside the real doorway")
		return

	var flame_position_delta := flame.position.distance_to(flame_start_position)
	var flame_scale_delta := flame.scale.distance_to(flame_start_scale)
	if flame_position_delta < 0.005 and flame_scale_delta < 0.01:
		_fail("Ember flame did not visibly animate")
		return

	print("FIRST GUEST PASS: collisions, safe route, key handoff, pan, zoom and Ember animation verified")
	quit(0)


func _fail(message: String) -> void:
	push_error("FIRST GUEST FAIL: " + message)
	quit(1)
