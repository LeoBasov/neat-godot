extends Node

var id : int
var input_node_id : int
var output_node_id : int
var innovation : int = 0
var weight : float = 1.0
var enabled : bool = true

func _init(id : int, input_node_id : int, output_node_id : int, innovation : int, weight : float, enabled : bool):
	self.id = id
	self.input_node_id = input_node_id
	self.output_node_id = output_node_id
	self.innovation = innovation
	self.weight = weight
	self.enabled = enabled
	
func get_str() -> String:
	var string : String = ""
	
	string += "ID: "         + str(id)             + " "
	string += "IN: "         + str(input_node_id)  + " "
	string += "OUT: "        + str(output_node_id) + " "
	string += "WEIGHT: "     + str(weight)         + " "
	string += "ENABLED: "    + str(enabled)        + " "
	string += "INNOVATION: " + str(innovation)     + " "
	
	return string