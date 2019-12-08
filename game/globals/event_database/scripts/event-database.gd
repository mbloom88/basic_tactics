"""
A database for event records.
"""
extends Node

# Databases
var _dialogue = {}
var _events = {}

################################################################################
# PUBLIC METHODS
################################################################################

func lookup_dialogue(key, value):
	"""
	Looks up a specified dialogue value and returns true if it has been 
	recorded.
	
	Args:
		- key (String): The directory that the dialogue is located in. The 
			name is typically a location in the world.
		- dialogue (string): The name of the dialogue JSON file, which is 
			usually a character or cutscene.
	
	Returns:
		- dialogue_exists (bool): True if dialogue was started previously and
			recorded.
	"""
	var dialogue_exists = false
	
	if _dialogue.has(key):
		if _dialogue[key].has(value):
			dialogue_exists = true
	
	return dialogue_exists

#-------------------------------------------------------------------------------

func lookup_event_value(key, key2):
	"""
	Looks up a specified event key and returns the value of said key.
	
	Args:
		- key (String): The directory that the dialogue is located in. The 
			name is typically a location in the world.
		- key2 (String): The name of the event.
	
	Returns:
		- event_value (var): The value of the key event. Returns null if no
			event or event value exists.
	"""
	var event_value = null
	
	if _events.has(key):
		if _events[key].has(key2):
			return _events[key][key2]
	
	return event_value

#-------------------------------------------------------------------------------

func update_dialogue(key, value):
	"""
	Adds a dialogue value to the dialogue dictionary. A dialogue key is also
	added if it does not already exist.
	
	Args:
		- key (String): The directory that the dialogue is located in. The 
			name is typically a location in the world.
		- value (String): The name of the dialogue JSON file, which is usually
			a character or cutscene.
	"""
	if not _dialogue.has(key):
		_dialogue[key] = []
	
	_dialogue[key].append(value)

#-------------------------------------------------------------------------------

func update_event(key, key2, operation, value):
	"""
	Adds or updates an event key with a specified value to the events
	dictionary.
	
	Args:
		- key (String): The directory that the dialogue is located in. The 
			name is typically a location in the world.
		- key2 (String): The name of the event.
		- operation (String): The type of operation to be perform on the event
			key value (see match statements below).
		- value (var): The value of the key event.
	"""
	if not _events.has(key):
		_events[key] = {}
	
	if not _events[key].has(key2):
		_events[key][key2] = null
	
	match operation:
		'append':
			if _events[key][key2] == null:
				_events[key][key2] = []
			
			if not _events[key][key2].has(value):
				_events[key][key2].append(value)
		'boolean':
			_events[key][key2] = value
		'decrement':
			if _events[key][key2] == null:
				_events[key][key2] = 0
			
			_events[key][key2] -= value
		'increment':
			if _events[key][key2] == null:
				_events[key][key2] = 0
			
			_events[key][key2] += value
