extends Node

var NeatNode = load("res://scenes/common/neat/NeatNode.gd")
var Gene = load("res://scenes/common/neat/Gene.gd")

var nodes : Array
var genes :  Array
var innovation : int = 0
var sensor_ids : Array
var hidden_ids : Array
var output_ids : Array

export var nr_sensors_nodes : int = 1
export var nr_hidden_nodes : int = 1
export var nr_output_nodes : int = 1

func _init():
	nodes = []
	genes = []
	sensor_ids = []
	hidden_ids = []
	output_ids = []

func _ready():
	set_up(self.nr_sensors_nodes, self.nr_hidden_nodes, self.nr_output_nodes)
	
	print(get_str())
	

func add_neat_node(type : int) -> int:
	var id : int = self.nodes.size()
	var node = NeatNode.new(type, id)
	add_child(node)
	
	match type:
		1:
			self.sensor_ids.push_back(id)
		2:
			self.hidden_ids.push_back(id)
		3:
			self.output_ids.push_back(id)
			
	self.nodes.push_back(node)
	
	return id
	
func add_gene(input_node_id : int, output_node_id : int, weight : float = 1.0, enabled : bool = true) -> void:
	var gene = Gene.new(self.genes.size(), input_node_id, output_node_id, self.innovation, weight, enabled)
	add_child(gene)
	self.innovation += 1
	self.nodes[output_node_id].gene_ids.push_back(self.genes.size())
	self.genes.push_back(gene)
	
func connect_nodes():
	var bias_id : int = 0
	
	for hidden_id in self.hidden_ids:
		add_gene(bias_id, hidden_id)
		
		for sensor_id in self.sensor_ids:
			add_gene(sensor_id, hidden_id)
			
	for output_id in self.output_ids:
		add_gene(bias_id, output_id)
		
		for sensor_id in self.sensor_ids:
			add_gene(sensor_id, output_id)
			
		for hidden_id in self.hidden_ids:
			add_gene(hidden_id, output_id)
	
func update_levels():
	for output_id in self.output_ids:
		update_level(output_id)
	
func update_level(node_id : int) -> int:
	var loc_level : int = 0
	var node = self.nodes[node_id]
	
	for gene_id in node.gene_ids:
		loc_level = max( update_level( self.genes[gene_id].input_node_id ), loc_level )
	
	node.level = loc_level + 1
	
	return node.level
	
func set_up(nr_sensors : int, nr_hidden : int, nr_output : int) -> void:
	var bias_node_type : int  = 0
	var sensor_node_type : int  = 1
	var hidden_node_type : int  = 2
	var output_node_type : int  = 3
	var bias_node_id : int  = 0
	var bias_node = NeatNode.new(bias_node_type, bias_node_id)
	add_child(bias_node)
	
	nodes = []
	genes = []
	sensor_ids = []
	hidden_ids = []
	output_ids = []
	
	self.nodes.push_back(bias_node)
	
	for _i  in range(nr_sensors):
		add_neat_node(sensor_node_type)
		
	for _i  in range(nr_hidden):
		add_neat_node(hidden_node_type)
		
	for _i  in range(nr_output):
		add_neat_node(output_node_type)
	
	connect_nodes()
	update_levels()
	
func get_str() -> String:
	var string : String = ""
	
	string += "NODES:\n"
	string += "---------------------------------------------------------------\n";
	
	for node in nodes:
		string += node.get_str() + "\n";
		
	string += "---------------------------------------------------------------\n";
	string += "GENES:\n";
	string += "---------------------------------------------------------------\n";
	
	for gene in genes:
		string += gene.get_str() + "\n";
	
	string += "---------------------------------------------------------------\n";
	
	return string
	
func execute(input_id_vals : Dictionary) -> Dictionary:
	var return_id_vals : Dictionary
	
	for output_id in self.output_ids:
		return_id_vals[output_id] = execute_node(output_id, input_id_vals)
	
	return return_id_vals
	
func execute_node(id : int, input_id_vals : Dictionary) -> float:
	var ret_val : float
	
	for gene_id in self.nodes[id].gene_id:
		var gene = self.genes[gene_id]
		var next_id : int = gene.input_node_id
		var node = self.nodes[next_id]
		
		match node.type:
			0: #BIAS
				ret_val += 1.0*gene.weight
			1: #SENSOR
				ret_val += input_id_vals[next_id]*gene.weight
			2: #HIDDEN
				ret_val += execute_node(next_id, input_id_vals)*gene.weight
			3: #OUTPUT
				ret_val += execute_node(next_id, input_id_vals)*gene.weight
	
	return sigmoid(ret_val)
	
func sigmoid(value : float) -> float:
	return 1.0/(1.0 + exp(-4.9*value))
	