extends Node3D

@onready var visual_root: Node3D = $VisualRoot

var service_timer := 0.0
var payment_timer := 0.0
var base_rotation_y := 0.0


func _ready() -> void:
	base_rotation_y = visual_root.rotation.y


func _process(_delta: float) -> void:
	var ticks := float(Time.get_ticks_msec()) * 0.006
	var idle_bob := sin(ticks) * 0.018
	var service_bob := 0.0

	if service_timer > 0.0:
		service_timer = maxf(0.0, service_timer - _delta)
		service_bob = sin(ticks * 3.2) * 0.05
		visual_root.rotation.y = lerpf(visual_root.rotation.y, base_rotation_y - 0.20, 0.16)
	elif payment_timer > 0.0:
		payment_timer = maxf(0.0, payment_timer - _delta)
		service_bob = sin(ticks * 4.0) * 0.035
		visual_root.rotation.y = lerpf(visual_root.rotation.y, base_rotation_y + 0.16, 0.16)
	else:
		visual_root.rotation.y = lerpf(visual_root.rotation.y, base_rotation_y, 0.10)

	visual_root.position.y = idle_bob + service_bob


func serve_checkin() -> void:
	service_timer = 1.55


func receive_payment() -> void:
	payment_timer = 1.0
