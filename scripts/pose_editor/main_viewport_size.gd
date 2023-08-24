extends SubViewport

@onready var left = $"../../../LeftContainer"
@onready var right = $"../../../RightContainer"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	size = get_window().size
