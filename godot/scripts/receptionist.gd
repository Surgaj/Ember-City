extends Node3D

signal key_handoff

@onready var visual_root: Node3D = $VisualRoot
@onready var key_anchor: Node3D = $VisualRoot/KeyAnchor

var service_timer := 0.0
var payment_timer := 0.0
var base_rotation_y := 0.0
var key_handoff_emitted := false


func _ready() -> void:
	base_rotation_y = visual_root.rotation.y


func _process(_delta: float) -> void:
	var ticks := float(Time.get_ticks_msec()) * 0.006
	var idle_bob := sin(ticks) * 0.018
	var service_bob := 0.0

	if service_timer > 0.0:
		service_timer = maxf(0.0, service_timer - _delta)
		service_bob = sin(ticks * 3.2) * 0.05
		visual_root.rotation.y = lerp_angle(visual_root.rotation.y, PI, clampf(_delta * 6.0, 0.0, 1.0))
		key_anchor.position.z = 0.18 + sin(ticks * 2.2) * 0.035
		if service_timer <= 0.78 and not key_handoff_emitted:
			key_handoff_emitted = true
			key_anchor.visible = false
			key_handoff.emit()
	elif payment_timer > 0.0:
		payment_timer = maxf(0.0, payment_timer - _delta)
		service_bob = sin(ticks * 4.0) * 0.035
		visual_root.rotation.y = lerp_angle(visual_root.rotation.y, PI, clampf(_delta * 5.0, 0.0, 1.0))
	else:
		visual_root.rotation.y = lerp_angle(visual_root.rotation.y, base_rotation_y, clampf(_delta * 4.0, 0.0, 1.0))

	visual_root.position.y = idle_bob + service_bob


func serve_checkin() -> void:
	service_timer = 1.55
	key_handoff_emitted = false
	key_anchor.visible = true
	key_anchor.position.z = -0.03


func receive_payment() -> void:
	payment_timer = 1.0
