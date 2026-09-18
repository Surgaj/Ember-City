extends CharacterBody3D

signal checkin_started
signal payment_started
signal payment_completed

enum State {
	IDLE,
	TO_RECEPTION,
	CHECKIN,
	TO_LOBBY,
	TO_ROOM_DOOR_OUT,
	TO_ROOM_DOOR_IN,
	TO_BED,
	SLEEP,
	RETURN_ROOM_DOOR_IN,
	RETURN_ROOM_DOOR_OUT,
	RETURN_LOBBY,
	TO_PAY,
	PAY,
	TO_EXIT,
	WAIT_OUTSIDE,
}

const MOVE_SPEED := 2.05
const ARRIVAL_DISTANCE := 0.20
const CHECKIN_SECONDS := 2.0
const SLEEP_SECONDS := 4.0
const PAY_SECONDS := 1.15
const OUTSIDE_WAIT_SECONDS := 1.8

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var visual_root: Node3D = $VisualRoot
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var route: Dictionary = {}
var state: State = State.IDLE
var wait_timer := 0.0
var current_target := Vector3.ZERO
var walking := false


func configure(route_points: Dictionary) -> void:
	route = route_points.duplicate(true)


func _ready() -> void:
	agent.path_desired_distance = 0.12
	agent.target_desired_distance = ARRIVAL_DISTANCE
	agent.radius = 0.32
	agent.height = 1.35
	call_deferred("_begin_cycle")


func _begin_cycle() -> void:
	if route.is_empty():
		return

	await get_tree().physics_frame
	await get_tree().physics_frame

	position = route["spawn"]
	visual_root.visible = true
	collision_shape.disabled = false
	_set_move_state(State.TO_RECEPTION, route["reception"])


func _physics_process(delta: float) -> void:
	_update_idle_bob()

	if _is_wait_state():
		velocity = Vector3.ZERO
		wait_timer -= delta
		if wait_timer <= 0.0:
			_finish_wait_state()
		return

	if not walking:
		velocity = Vector3.ZERO
		return

	var horizontal_distance := Vector2(
		global_position.x - current_target.x,
		global_position.z - current_target.z
	).length()

	if horizontal_distance <= ARRIVAL_DISTANCE:
		velocity = Vector3.ZERO
		walking = false
		_on_target_reached()
		return

	var next_path_position := agent.get_next_path_position()
	var direction := next_path_position - global_position
	direction.y = 0.0

	if direction.length_squared() < 0.0001:
		direction = current_target - global_position
		direction.y = 0.0

	if direction.length_squared() > 0.0001:
		direction = direction.normalized()
		velocity = direction * MOVE_SPEED
		look_at(global_position + direction, Vector3.UP)
	else:
		velocity = Vector3.ZERO

	move_and_slide()


func _update_idle_bob() -> void:
	if not visual_root.visible:
		return

	var ticks := float(Time.get_ticks_msec()) * 0.008
	var amplitude := 0.035 if walking else 0.018
	visual_root.position.y = sin(ticks) * amplitude


func _set_move_state(next_state: State, target: Vector3) -> void:
	state = next_state
	current_target = target
	agent.target_position = target
	walking = true


func _start_wait(next_state: State, seconds: float) -> void:
	state = next_state
	wait_timer = seconds
	walking = false
	velocity = Vector3.ZERO


func _is_wait_state() -> bool:
	return state in [
		State.CHECKIN,
		State.SLEEP,
		State.PAY,
		State.WAIT_OUTSIDE,
	]


func _on_target_reached() -> void:
	match state:
		State.TO_RECEPTION:
			checkin_started.emit()
			_start_wait(State.CHECKIN, CHECKIN_SECONDS)
		State.TO_LOBBY:
			_set_move_state(State.TO_ROOM_DOOR_OUT, route["room_door_out"])
		State.TO_ROOM_DOOR_OUT:
			_set_move_state(State.TO_ROOM_DOOR_IN, route["room_door_in"])
		State.TO_ROOM_DOOR_IN:
			_set_move_state(State.TO_BED, route["bed"])
		State.TO_BED:
			visual_root.visible = false
			collision_shape.set_deferred("disabled", true)
			_start_wait(State.SLEEP, SLEEP_SECONDS)
		State.RETURN_ROOM_DOOR_IN:
			_set_move_state(State.RETURN_ROOM_DOOR_OUT, route["room_door_out"])
		State.RETURN_ROOM_DOOR_OUT:
			_set_move_state(State.RETURN_LOBBY, route["lobby"])
		State.RETURN_LOBBY:
			_set_move_state(State.TO_PAY, route["reception"])
		State.TO_PAY:
			payment_started.emit()
			_start_wait(State.PAY, PAY_SECONDS)
		State.TO_EXIT:
			visual_root.visible = false
			collision_shape.set_deferred("disabled", true)
			_start_wait(State.WAIT_OUTSIDE, OUTSIDE_WAIT_SECONDS)


func _finish_wait_state() -> void:
	match state:
		State.CHECKIN:
			_set_move_state(State.TO_LOBBY, route["lobby"])
		State.SLEEP:
			visual_root.visible = true
			collision_shape.set_deferred("disabled", false)
			_set_move_state(State.RETURN_ROOM_DOOR_IN, route["room_door_in"])
		State.PAY:
			payment_completed.emit()
			_set_move_state(State.TO_EXIT, route["exit"])
		State.WAIT_OUTSIDE:
			position = route["spawn"]
			visual_root.visible = true
			collision_shape.set_deferred("disabled", false)
			_set_move_state(State.TO_RECEPTION, route["reception"])
