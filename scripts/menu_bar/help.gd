extends PopupMenu


func _ready():
	id_pressed.connect(_id_pressed)

func _id_pressed(id:int):
	if id == 1:
		OS.shell_open("https://github.com/Tyrannicodin/hermitcraft-card-creator/discussions")
	elif id == 2:
		OS.shell_open("https://discord.gg/aDyXzbCjuU")
