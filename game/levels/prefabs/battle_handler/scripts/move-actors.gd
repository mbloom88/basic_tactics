extends "res://assets/scripts/state.gd"

var _active_allies = []
var _used_refs = []

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	_gather_active_allies()

################################################################################
# PRIVATE METHODS
################################################################################

func _gather_active_allies():
	var squad_list = PartyDatabase.provide_party()
	
	# If ally not in scene, instantiate for placement
	for squadie in squad_list.keys():
		if squad_list[squadie]['in_squad'] and not squadie in _used_refs:
			var new_ally = ActorDatabase.provide_actor_object(squadie)
			_active_allies.append(new_ally)
			_used_refs.append(new_ally.reference)
