extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func update_speed(value):
	$Margin/HBox/Speed.text = "Speed: " + str(snapped(value, 0.01))
