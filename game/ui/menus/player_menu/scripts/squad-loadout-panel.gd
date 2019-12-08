extends NinePatchRect

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

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	_configure_squadies()

################################################################################
# VIRTUAL METHODS
################################################################################

func _configure_squadies():
	for squadie in _squad_names.get_children():
		squadie.queue_free()
	
	var squad = PartyDatabase.provide_party()
	
	for squadie in squad.keys():
		if squad[squadie]['hired']:
			var new_button = _squad_button.instance()
			var squadie_name = ActorDatabase.lookup_name(squadie)
			
			new_button.text = '%s "%s" %s' % [squadie_name[0], squadie_name[1],
				squadie_name[2]]
			new_button.update_actor_ref(squadie)
			_squad_names.add_child(new_button)
			
			# Signal connections
			new_button.connect(
				'update_portrait',
				 self,
				'_on_Squadie_update_portrait')
			new_button.connect('just_toggled', self, '_on_Squadie_just_toggled')
			
			# Set "in squad" indicators
			if squad[squadie]['in_squad']:
				new_button.icon = green
			else:
				new_button.icon = red

################################################################################
# PUBLIC METHODS
################################################################################

func activate():
	visible = true
	_configure_squadies()

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
