extends PopupMenu


func _ready():
	id_pressed.connect(_id_pressed)

func _id_pressed(id:int):
	match id:
		1:
			ServerRunner.new(GlobalStorage.path).run_server()
		2:
			var runner = ServerRunner.new(GlobalStorage.path)
			runner.npm_build()
			runner.build_pid = 0
		3:
			var runner = ServerRunner.new(GlobalStorage.path)
			runner.npm_ci()
			runner.ci_pid = 0
