extends RigidBody2D

const FORCE : float = 1.0
const TORQUE : float = 10.0
const MAX_LIN_VELOCITY : float = 100.0
const MAX_ANGULAR_VELOCITY : float = 100.0
const SENSE_RADIUS : float = 500.0

var size_screen : Vector2
var found_food = null

var input_vals : Dictionary
var output_vals : Dictionary
var food_vector = null

func _on_Food_eaten():
	found_food = null
	food_vector = null
	$Brain.pop_state()
	$Brain.push_state(funcref(self, "state_forage"))

func state_forage(delta):
	var foods = get_tree().get_nodes_in_group("Food")
	var distance = 1e+6
	
	for food in foods:
		var new_dist = (food.position - position).length()
	
		if new_dist < SENSE_RADIUS and new_dist < distance:
			distance = new_dist
			found_food = food
			
	if found_food:
		found_food.connect("eaten", self, "_on_Food_eaten")
		$Brain.pop_state()
		$Brain.push_state(funcref(self, "state_hunt"))
	else:
		push()
		
func state_hunt(delta):	
	var variance = 0.1
	var angle = (found_food.position - position).angle()
	var diff = rotation - (found_food.position - position).angle()
	
	if abs(diff) > variance:
		if angle > rotation:
			rotate_right()
		else:
			rotate_left()
	else:
		push()

func _ready():
	size_screen = get_viewport().size
	$Brain.push_state(funcref(self, "state_forage"))
	
	input_vals[1] = position.x
	input_vals[2] = position.y
	input_vals[3] = linear_velocity.x
	input_vals[4] = linear_velocity.y
	input_vals[5] = angular_velocity
	input_vals[6] = 0.0
	input_vals[7] = 0.0
	
	output_vals[8] = 0.0
	output_vals[9] = 0.0
	output_vals[10] = 0.0
	
func rotate_right():
	add_torque(TORQUE)
	
func rotate_left():
	add_torque(-TORQUE)
	
func push():
	var force = Vector2(1.0, 0.0).rotated(rotation)*FORCE
	add_central_force(force)
	
func pull():
	var force = Vector2(1.0, 0.0).rotated(rotation)*FORCE
	add_central_force(-force)
	
func _process(delta):
	#$Brain.update(delta)
	
	input_vals[1] = position.x
	input_vals[2] = position.y
	input_vals[3] = linear_velocity.x
	input_vals[4] = linear_velocity.y
	input_vals[5] = angular_velocity
	input_vals[6] = 0.0
	input_vals[7] = 0.0
	
	if found_food:
		food_vector = found_food.position - position
		input_vals[6] = food_vector.x
		input_vals[7] = food_vector.y
	
	output_vals = $Genome.execute(input_vals)
	
func _physics_process(delta):
	applied_force.x = 100.0*(output_vals[8] - 0.5)
	applied_force.y = 100.0*(output_vals[9] - 0.5)
	applied_torque = 1000.0*(output_vals[10] - 0.5)
	
	if linear_velocity.length() >= MAX_LIN_VELOCITY:
		applied_force = Vector2(0.0, 0.0)
	if angular_velocity >= MAX_ANGULAR_VELOCITY:
		applied_torque = 0.0
	
	applied_force = Vector2(1, 0).rotated(rotation)*applied_force.length()
	
func _integrate_forces (state):
	periodic_boundary(state)
	
func periodic_boundary(state):
	if position.x > size_screen.x:
		var t = state.get_transform()
		t.origin.x = 0.0
		state.set_transform(t)
	elif position.x < 0:
		var t = state.get_transform()
		t.origin.x = size_screen.x
		state.set_transform(t)
		
	if position.y > size_screen.y:
		var t = state.get_transform()
		t.origin.y = 0.0
		state.set_transform(t)
	elif position.y < 0:
		var t = state.get_transform()
		t.origin.y = size_screen.y
		state.set_transform(t)