extends Control

# Signals
signal state_changed(menu, state)

# Child nodes
onready var _squad_names = $HBoxContainer/ScrollContainer/SquadNames
onready var _portrait = $HBoxContainer/VBoxContainer/HBoxContainer/NeutralPortrait
onready var _stats = $HBoxContainer/VBoxContainer/HBoxContainer/ActorStats
onready var _squad_cap = $HBoxContainer/VBoxContainer/SquadCapacity

# Buttons
export (PackedScene) var _squad_button

# In-squad indicators
export (Texture) var green
export (Texture) var red

# State machine
var _current_state = null
var _state_stack = []

onready var _state_map = {
	'idle': $State/Idle,
	'interact': $State/Interact,
	'exit': $State/Exit,
}

# Independent scene editing
export (bool) var _onready_activation = false

################################################################################
# VIRTUAL METHODS
################################################################################

func _process(delta):
	var state_name = _current_state._update(self, delta)
	
	if state_name:
		_change_state(state_name)

#-------------------------------------------------------------------------------

func _ready():
	_state_stack.push_front($State/Idle)
	_current_state = _state_stack[0]
	_change_state('interact')

################################################################################
# PRIVATE METHODS
################################################################################

func _change_state(state_name):
	if state_name != 'previous':
		if _state_map[state_name] != _current_state:
			_current_state._exit(self)

	if state_name == 'previous':
		_state_stack.pop_front()
	else:
		var new_state = _state_map[state_name]
		_state_stack[0] = new_state

	_current_state = _state_stack[0]
	
	if state_name != 'previous':
		_current_state._enter(self)
	
	emit_signal("state_changed", self, state_name)

################################################################################
# PUBLIC METHODS
################################################################################

func interact():
	_change_state('interact')

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Squadie_update_portrait(actor_ref):
	_portrait.texture = ActorDatabase.lookup_portrait(actor_ref, 'neutral')

#-------------------------------------------------------------------------------

func _on_Squadie_just_toggled(button, actor_ref):
	if PartyDatabase.provide_actor(actor_ref)['essential']:
		return 
	elif button.icon == red:
		if PartyDatabase.squad_count < PartyDatabase.squad_limit:
			button.icon = green
			PartyDatabase.update_squadie_status(actor_ref, 'add')
	else:
		if PartyDatabase.squad_count > 0:
			button.icon = red
			PartyDatabase.update_squadie_status(actor_ref, 'remove')
	
	_squad_cap.text = 'Squad Capacity: %d/%d' % [PartyDatabase.squad_count,
			PartyDatabase.squad_limit]
