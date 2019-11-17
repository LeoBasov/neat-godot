extends Node

enum Type{BIAS = 0, SENSOR = 1, HIDDEN = 2, OUTPUT = 3}

var type : int
var id : int
var level : int
var gene_ids : Array

func _init(type : int, id : int, level : int = 0):
	self.type = type
	self.id = id
	self.level = level
	self.gene_ids = []
	
func get_str() -> String:
	var string : String = ""
	
	string += "ID: " + str(self.id) + " "
	string += "TYPE: " + str(self.type) + " "
	string += "LEVEL: " + str(self.level) + " "
	
	string += "GENES ["
	
	for gene_id in self.gene_ids:
		string += str(gene_id) + ", "
	
	string += "] "
	
	return string