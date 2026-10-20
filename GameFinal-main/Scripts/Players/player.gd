extends CharacterBody3D

#region # Enums
enum State {
	IDLE_RESTING,
	IDLE_READY,
	MOVING,
	TURNING
}

enum QueuedAction {
	NONE,
	MOVE,
	TURN
}

enum MoveDirection {
	FORWARD,
	BACK
}
#endregion


#region # On ready and export vars
# Onready
@onready var main = get_node("/root/Main")
@onready var camera: Camera3D = $Head/Camera3D
@onready var pos_timer: Timer = $Position_Timer

@onready var ray_front_head: RayCast3D = $Head/RayFrontHead
@onready var ray_back_head: RayCast3D = $Head/RayBackHead
@onready var ray_front_feet: RayCast3D = $Feet/RayFrontFeet
@onready var ray_back_feet: RayCast3D = $Feet/RayBackFeet

@onready var collider: CollisionShape3D = $Collider


# Export
@export var turn_speed: float = 4.5 # Speed at which the player turns
@export var camera_fov: int = 80 # FOV

@export var forward_speed: float = 0.065 # Speed at which the player moves
@export var back_speed: float = 0.055
@export var move_amount: int = 1 # Distance the player moves per step

@export var rest_time: float = 0.08

@export var interact_range: float = 2 # Distance at which the player can interact
#endregion


#region # Vars
var current_movement_speed = forward_speed 

var target_pos = Vector3(position)
var target_deg: int = 0

var queued_move = target_pos
var queued_deg: int = target_deg

var move_dir: int = 0

var state = State.IDLE_READY
var queued_action = QueuedAction.NONE

var can_move: bool = true
var can_turn: bool = true
#endregion


# -------------------------------------------------------------------------------------------------
# READY (Called when the node (Player) enters the scene)
# -------------------------------------------------------------------------------------------------
func _ready() -> void: 
	
	target_pos = position # Ensuring initial target position matches actual position
	camera.fov = camera_fov # Ensuring camera fov matches camera_fov variable
	pos_timer.wait_time = rest_time
	
	ray_front_head.target_position.y = -move_amount - 0.2
	ray_back_head.target_position.y = -move_amount - 0.2
	
	ray_front_feet.target_position.y = -move_amount - 0.2
	ray_back_feet.target_position.y = -move_amount - 0.2


# -------------------------------------------------------------------------------------------------
# INPUT (RUNS ON INPUT)
# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
# -------------------------------------------------------------------
# INTERACTION
#region -------------------------------------------------------------
	# Is the input a left mouse click?
	if (event is InputEventMouseButton  # Is the input a mouse button?
	and event.button_index == MOUSE_BUTTON_LEFT # Is the input LMB specifically?
	):

		if state == State.IDLE_READY:

			# Variables
			var mouse_pos = get_viewport().get_mouse_position()
			var from = camera.project_ray_origin(mouse_pos)
			var to = from + camera.project_ray_normal(mouse_pos) * interact_range # = distance of ray?
			var space_state = get_world_3d().direct_space_state
			var result_dict = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))

			# INTERACT
			if event.pressed and result_dict and result_dict.collider.has_method("interact"): # Does the result's name contain "Interactable"?
					result_dict.collider.interact()

			# USE ITEM
			elif result_dict and result_dict.collider.has_method("interact"):
				main.current_object = result_dict.collider
				main.try_item_use()
#endregion oooooooooooooooooooooooooooooooooooooooooooooooooooooooooo


# -------------------------------------------------------------------
# KEY PRESSES
#region -------------------------------------------------------------
	if event is InputEventKey and event.pressed:

	# -----------------------------------------------
	# TURNING
	#region -----------------------------------------
		if can_turn:
			# Turning right
			if event.is_action_pressed("move_turn_right"):
				queued_action = QueuedAction.TURN # Set action queue
				queued_deg = -90 # Set queued turn

			# Turning left
			if event.is_action_pressed("move_turn_left"):
				queued_action = QueuedAction.TURN # Set action queue
				queued_deg = 90 # Set queued turn
	#endregion oooooooooooooooooooooooooooooooooooooo


	# -----------------------------------------------
	# MOVING
	#region -----------------------------------------
		if can_move:
			# MOVING FORWARD
			if (event.is_action_pressed("move_forward") 
			and not (state != State.TURNING and (Input.is_action_pressed("move_turn_left") or Input.is_action_pressed("move_turn_right")))):
				queued_move = queue_move(MoveDirection.FORWARD, forward_speed) # Call queue move with forward direction and speed

			# MOVING BACKWARD
			if (event.is_action_pressed("move_back") 
			and not (state != State.TURNING and (Input.is_action_pressed("move_turn_left") or Input.is_action_pressed("move_turn_right")))):
				queued_move = queue_move(MoveDirection.BACK, back_speed) # Call queue move with back direction and speed
	#endregion oooooooooooooooooooooooooooooooooooooo

#endregion oooooooooooooooooooooooooooooooooooooooooooooooooooooooooo


# -------------------------------------------------------------------------------------------------
# DEBUG QOL TOOLS
# -------------------------------------------------------------------------------------------------
#region
	if (event is InputEventKey
	and event.keycode == KEY_TAB
	and event.pressed):
		get_tree().reload_current_scene()
		print("Reload scene")
#endregion oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo


# -------------------------------------------------------------------------------------------------
# PHYSICS PROCESS (Runs every 1/60 sec)
# -------------------------------------------------------------------------------------------------
func _physics_process(_delta) -> void:

# PROCESSING
#region -------------------------------------------------------------
	if state == State.TURNING:
		process_turn(target_deg)

	elif state == State.MOVING:
		process_move(target_pos, current_movement_speed)
#endregion oooooooooooooooooooooooooooooooooooooooooooooooooooooooooo


# RESOLVING QUEUES
#region -------------------------------------------------------------
	if state == State.IDLE_READY and not queued_action == QueuedAction.NONE:

		if queued_action == QueuedAction.TURN:
			state = State.TURNING # Set state to turning
			target_deg += queued_deg # Set target degrees to queued degrees
			
			queued_action = QueuedAction.NONE # Remove queued action

		if queued_action == QueuedAction.MOVE:
			if not ((current_movement_speed == forward_speed and (ray_front_head.is_colliding() or ray_front_feet.is_colliding())) 
			or (current_movement_speed == back_speed and (ray_back_head.is_colliding() or ray_back_feet.is_colliding()))):
				state = State.MOVING # Set state to moving
				target_pos += queued_move # Set target pos to queued pos
			else:
				set_state_rest()

			queued_action = QueuedAction.NONE # Remove queued action

		if not state == State.IDLE_RESTING:
			toggle_raycasts(false)
#endregion oooooooooooooooooooooooooooooooooooooooooooooooooooooooooo


# -------------------------------------------------------------------------------------------------
# CUSTOM FUNCTIONS
#region -------------------------------------------------------------------------------------------

func process_turn(target: int):
	rotation_degrees.y = move_toward(rotation_degrees.y, target, turn_speed) # Rotating camera towards target rotation
	# Resetting state once camera reaches target rotation
	if rotation_degrees.y == target:
		set_state_rest()


func queue_move(direction: MoveDirection, speed: float, movement: Vector3 = Vector3(0, 0, 0), deg_for_move: int = 0):
	deg_for_move = wrap_rotation(target_deg)

	queued_action = QueuedAction.MOVE # Set action queue
	current_movement_speed = speed # Set move speed

	if direction == MoveDirection.FORWARD:
		move_dir = int(deg_for_move)

	elif direction == MoveDirection.BACK:
		move_dir = int(-deg_for_move)
		if move_dir == 0:
			move_dir = -1


	match move_dir:
	# Forward
		0, -180:
			movement.z = -move_amount
	# Sides
		90, -90:
			movement.x = -move_amount * sign(move_dir)
	# Backward
		180, -1:
			movement .z = +move_amount
	# Wildcard
		_:
			print("MOVEMENT ERROR!")

	return movement


func set_state_rest():
	state = State.IDLE_RESTING
	# Wrapping rotations
	target_deg = wrap_rotation(target_deg)
	rotation_degrees.y = target_deg
	# Start timer
	pos_timer.start()
	# Enable raycasts
	toggle_raycasts(true)
	# Enable moving


func process_move(target: Vector3, speed):
	#print(target)
	# Moving towards target position
	position.x = move_toward(position.x, target.x, speed) # X position
	position.z = move_toward(position.z, target.z, speed) # Z position

	# Resetting state once target position is reached
	if position == target:
		set_state_rest()


func wrap_rotation(val: int):
	val = wrapi(val, -180, 180)
	if val == -180:
		val = 180
	return val


func toggle_raycasts(to: bool):
	ray_front_head.enabled = to
	ray_back_head.enabled = to
	ray_front_feet.enabled = to
	ray_back_feet.enabled = to
#endregion oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo


# -------------------------------------------------------------------------------------------------
# CONNECTED SIGNALS
#region -------------------------------------------------------------------------------------------
func _on_position_timer_timeout() -> void:
	state = State.IDLE_READY
#endregion oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
