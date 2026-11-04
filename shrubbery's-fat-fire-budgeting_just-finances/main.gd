extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dashboardButton = $GridContainer/Dashboard
	var configButton = $GridContainer/Config
	dashboardButton.pressed.connect(_dashboard_button_pressed)
	configButton.pressed.connect(_config_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


### Button Pressed Functions
func _dashboard_button_pressed():
	var button = $GridContainer/Dashboard
	if button.button_pressed:
		print('DEBUG_LOG: Dashboard Pressed, Visbility = False')
	else:
		print('DEBUG_LOG: Dashboard Pressed, Visbility = True')

func _config_button_pressed():
	var button = $GridContainer/Config
	var scene = $Config
	if button.button_pressed:
		print('DEBUG_LOG: Config Pressed, Visbility = False')
		scene.visible = false
	else:
		print('DEBUG_LOG: Config Pressed, Visbility = True')
		scene.visible = true
