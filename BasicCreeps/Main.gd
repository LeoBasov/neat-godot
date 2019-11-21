extends Node

var Food  = load("res://scenes/Food/Food.tscn")
var Creep = load("res://scenes/creep/Creep.tscn")

export var numb_creeps = 10

func reset():
	for food in get_tree().get_nodes_in_group("Food"):
		food.queue_free()
		
	for creep in get_tree().get_nodes_in_group("Creep"):
		creep.queue_free()
		
	var scree_size = get_viewport().size
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for _i in numb_creeps:
		var positon = Vector2(rng.randf_range(0.0, scree_size.x), rng.randf_range(0.0, scree_size.y))
		var rotation = rng.randf_range(0.0, 2*PI)
		var creep = Creep.instance()
		creep.position = positon
		creep.rotation = rotation
		add_child(creep)
	
	get_tree().paused = true

func _ready():
	reset()
	
func _process(delta):
	if Input.is_action_pressed("ui_right"):
		$Creep.rotate_right()
	if Input.is_action_pressed("ui_left"):
		$Creep.rotate_left()
	if Input.is_action_pressed("ui_down"):
		$Creep.pull()
	if Input.is_action_pressed("ui_up"):
		$Creep.push()
	if Input.is_action_pressed("ui_reset"):
		reset()
		
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