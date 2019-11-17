extends Area2D

signal eaten()

func _ready():
	$Fill.modulate = Color(0, 1, 0)


func _on_Food_body_entered(body):
	emit_signal("eaten")
	queue_free()


func _on_Food_tree_exiting():
	emit_signal("eaten")
