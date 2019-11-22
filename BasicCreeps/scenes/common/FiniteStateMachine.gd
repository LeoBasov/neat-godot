extends Node

var state_stack : Array

func _init():
	self.state_stack = []
	
func update(delta : float) -> void:
	var current_state :  FuncRef = get_current_state()
	
	if current_state != null:
		current_state.call_func(delta)
	
func pop_state() -> FuncRef:
	return self.state_stack.pop_back()
	
func push_state(state : FuncRef) -> void:
	if get_current_state() != state:
		self.state_stack.push_back(state)
	
func get_current_state() -> FuncRef:
	return  (self.state_stack.back() if self.state_stack.size() > 0 else null)