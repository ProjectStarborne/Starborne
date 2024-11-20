extends ScrollContainer

@onready var label = get_children()[0]
@onready var sound = get_children()[1]
@onready var animation = label.get_children()[0]

func enter_message(msg):
	visible = true
	label.visible = true
	label.text += msg
	sound.play()
	animation.play("fade_out")
