extends CanvasLayer

@onready var label = $Control/Label


func update_secs(secs: float ):
	label.text = str(snappedf(secs, 0.1))
	
