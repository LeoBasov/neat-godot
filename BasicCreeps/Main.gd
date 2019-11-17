extends Node

var Food  = load("res://scenes/Food/Food.tscn")

func _ready():
	get_tree().paused = !(get_tree().paused)
	
func _process(delta):
	if Input.is_action_pressed("ui_right"):
		$Creep.rotate_right()
	if Input.is_action_pressed("ui_left"):
		$Creep.rotate_left()
	if Input.is_action_pressed("ui_down"):
		$Creep.pull()
	if Input.is_action_pressed("ui_up"):
		$Creep.push()
		
func _input(event):
	if event is InputEventMouseButton and event.button_index == 1:
		create_food(event.position)
	if event is InputEventMouseButton and event.button_index == 2:
		for food in get_tree().get_nodes_in_group("Food"):
			var distance = (food.position - event.position).length()
			if distance < 10.0:
				food.queue_free()
				break
		
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().quit()
		elif event.pressed and (event.scancode == KEY_P or event.scancode == KEY_SPACE):
			get_tree().paused = !(get_tree().paused)

func _physics_process(delta):
	pass
	
func create_food(position):
	var food = Food.instance()
	food.position = position
	add_child(food)