"""
Handles all dialogue between characters and handles player responses when
prompted.

Notes:
	- Do not exceed two lines of text for dialogues.
"""
extends Control

# Signals
signal dialogue_finished
signal dialogue_loaded

# Child nodes
onready var _top_dialogue = $DialogueBoxTop
onready var _top_response = $DialogueResponseTop
onready var _bot_dialogue = $DialogueBoxBot
onready var _bot_response = $DialogueResponseBot

# Dialogue info
var _directory = ""
var _file_name = "" 
var _dialogue = {}
var _header = ""
var _block_info = {}
var _random = []
var _responses = {}
var _next_header = ""
var _start_flag = false

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	_clear_dialogue_info()

################################################################################
# PRIVATE METHODS
################################################################################

func _determine_dialogue_divergence():
	"""
	Determines how the dialogue will progress based on dialogue conditions that
	are met.
	"""
	var dialogue_exists = EventDatabase.lookup_dialogue(_directory, _file_name)
	
	if dialogue_exists:
		_next_header = _block_info['true']
	else:
		_next_header = _block_info['false']
	
	_next_dialogue_content()

#-------------------------------------------------------------------------------

func _determine_event_divergence():
	"""
	Determines how the dialogue will progressed based on event conditions that
	are met.
	"""
	var event_value = EventDatabase.lookup_event_value(_directory, \
		_block_info['key'])
	_next_header = _block_info['false']
	
	if event_value:
		match _block_info['condition']:
			'equals':
				if event_value == _block_info['values']:
					_next_header = _block_info['true']
			'equal_arrays':
				var size = _block_info['values'].size()
				var count = 0
				
				for value in event_value:
					if value in _block_info['values']:
						count +=1
				
				if count == size:
					_next_header = _block_info['true']
			'greater_than':
				if event_value > _block_info['values']:
					_next_header = _block_info['true']
			'greater_than_equal_to':
				if event_value >= _block_info['values']:
					_next_header = _block_info['true']
			'less_than_equal_to':
				if event_value <= _block_info['values']:
					_next_header = _block_info['true']

	_next_dialogue_content()

#-------------------------------------------------------------------------------

func _clear_dialogue_info():
	"""
	Clears previously-loaded dialogue file info.
	"""
	_directory = ""
	_file_name = ""
	_dialogue = {}
	_header = ""
	_block_info = {}
	_random = []
	_responses = {}
	_next_header = ""
	_start_flag = false

#-------------------------------------------------------------------------------

func _end_dialogue():
	"""
	Ends the dialogue sequence and notifies nodes that are connected about the
	completion.
	"""
	for dialogue in get_children():
		if dialogue.visible:
			dialogue.deactivate('fade_out')
			emit_signal("dialogue_finished")

#-------------------------------------------------------------------------------

func _next_dialogue_content():
	"""
	Progresses through the loaded dialogue file.
	"""
	if not _start_flag:
		var dialogue_exists = \
			EventDatabase.lookup_dialogue(_directory, _file_name)
		
		if not dialogue_exists:
			EventDatabase.update_dialogue(_directory, _file_name)
			_header = 'start'
			_block_info = _dialogue[_header]
		else:
			_header = 'repeat'
			_block_info = _dialogue[_header]
		
		_start_flag = true
	else:
		_header = _next_header
		_block_info = _dialogue[_header]
	
	var text = "Dialogue: %s" % _header
	CommandConsole.update_command_log(text)
	
	match _block_info['type']:
		'divergence':
			match _block_info['divert_type']:
				'dialogue':
					_determine_dialogue_divergence()
				'event':
					_determine_event_divergence()
		'event':
			_next_header = _dialogue[_header]['next']
			_update_event()
		'random':
			_random = _block_info['values']
			_select_random_dialogue()
		'response':
			_responses = _block_info['values']
			_setup_dialogue_box()
		'text':
			_next_header = _dialogue[_header]['next']
			_setup_dialogue_box()

#-------------------------------------------------------------------------------

func _parse_json_file(file_path):
	"""
	Converts a JSON file to a dictionary of dialogues and stores the name of
	the dialogue file.
	
	Args:
		- file_path (String): A file path to the specified dialogue JSON file.
	
	Returns:
		- dialogue (Dictionary): Parsed dialogue JSON file converted to a 
			dictionary.
	"""
	var file = File.new()
	assert file.file_exists(file_path)
	
	file.open(file_path, file.READ)
	var json = file.get_as_text()
	
	var dialogue = parse_json(json)
	assert dialogue.size() > 0
	
	file.close()
	var split_pool_array = file_path.get_basename().split("/")
	var split_array = Array(split_pool_array)
	_file_name = split_array.pop_back()
	var _temp = split_array.pop_back()
	_directory = split_array.pop_back()
	
	return dialogue

#-------------------------------------------------------------------------------

func _play_dialogue():
	"""
	Calls a target DialogueBox to be played for the scene based on the
	configurations within the loaded dialogue file.
	"""
	if _block_info['enter_scene']:
		
		match _block_info['screen_side']:
			'top':
				_top_dialogue.activate(_block_info['enter_speed'])
			'bottom':
				_bot_dialogue.activate(_block_info['enter_speed'])
	else:
		match _block_info['screen_side']:
			'top':
				_top_dialogue.activate('just_play')
			'bottom':
				_bot_dialogue.activate('just_play')

#-------------------------------------------------------------------------------

func _play_response():
	"""
	Calls a target DialogueResponse to be played for the scene based on the
	configurations within the loaded dialogue file.
	"""
	if _block_info['enter_scene']:
		
		match _block_info['screen_side']:
			'top':
				_top_response.activate(_block_info['enter_speed'])
			'bottom':
				_bot_response.activate(_block_info['enter_speed'])

#-------------------------------------------------------------------------------

func _select_random_dialogue():
	"""
	Selects a random dialogue to play next from an array specified by the loaded
	dialogue file.
	"""
	randomize()
	var index = randi() % _random.size() - 1
	_next_header = _random[index]
	_next_dialogue_content()

#-------------------------------------------------------------------------------

func _setup_dialogue_box():
	"""
	Sets up a target DialogueBox or DialogueResponse based on the configurations
	within the loaded dialogue file. Setup includes the following for actors
	who are speaking:
		- Load the name of the actor.
		- Load the portrait of the actor.
		- Load the dialogue or responses to the target DialogueBox or 
			DialogueResponse, respectively.
		- Align the DialogueBox or DialogueResponse at the top or bottom of the
			screen.
		- Align the DialogueBox's or DialogueResponse's actor portrait to
			the left or right of the prompt.
		- Align the DialogueBox's or DialogueResponse's actor name plate to
			the top or bottom of the prompt.
	"""
	var name_info = ActorDatabase.lookup_name(_block_info['speaker'])
	var portrait = ActorDatabase.lookup_portrait(_block_info['speaker'], \
		_block_info['expression'])
	
	match [_block_info['screen_side'], _block_info['type'], ]:
		['top', 'text']:
			_top_dialogue.box_alignment = _block_info['name_align']
			_top_dialogue.portrait_alignment = _block_info['portrait_align']
			_top_dialogue.update_portrait(portrait)
			_top_dialogue.update_name_plate(name_info)
			_top_dialogue.update_current_dialogue(_block_info['content'])
			_play_dialogue()
		['top', 'response']:
			_top_response.box_alignment = _block_info['name_align']
			_top_response.portrait_alignment = _block_info['portrait_align']
			_top_response.update_portrait(portrait)
			_top_response.update_name_plate(name_info)
			_top_response.update_responses(_responses)
			_play_response()
		['bottom', 'text']:
			_bot_dialogue.box_alignment = _block_info['name_align']
			_bot_dialogue.portrait_alignment = _block_info['portrait_align']
			_bot_dialogue.update_portrait(portrait)
			_bot_dialogue.update_name_plate(name_info)
			_bot_dialogue.update_current_dialogue(_block_info['content'])
			_play_dialogue()
		['bottom', 'response']:
			_bot_response.box_alignment = _block_info['name_align']
			_bot_response.portrait_alignment = _block_info['portrait_align']
			_bot_response.update_portrait(portrait)
			_bot_response.update_name_plate(name_info)
			_bot_response.update_responses(_responses)
			_play_response()

#-------------------------------------------------------------------------------

func _update_event():
	"""
	Updates the EventDatabase with the event key and value specified by the 
	loaded dialogue file.
	"""
	EventDatabase.update_event(_directory, _block_info['key'], \
		_block_info['condition'], _block_info['values'])
	
	var cmd_log_text = "Event %s %s." % [_header, _block_info['key']]
	CommandConsole.update_command_log(cmd_log_text)
	
	_next_dialogue_content()

################################################################################
# PUBLIC METHODS
################################################################################

func activate_dialogue():
	"""
	Activates the loaded dialogue.
	"""
	_next_dialogue_content()

#-------------------------------------------------------------------------------

func load_dialogue(file_path):
	"""
	Loads a new dialog file.
	"""
	_dialogue = _parse_json_file(file_path)
	emit_signal("dialogue_loaded")

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_DialogueBox_dialogue_finished():
	"""
	Post-DialogueBox handling. Removes the DialogueBox from the scene if 
	specified in the loaded dialogue file and determines whether to continue
	progressing through the dialogue. 
	"""
	if _block_info['exit_scene']:
		
		match _block_info['screen_side']:
			'top':
				_top_dialogue.deactivate(_block_info['exit_speed'])
			'bottom':
				_bot_dialogue.deactivate(_block_info['exit_speed'])
	
	if _block_info['next'] == 'end':
		_end_dialogue()
		_clear_dialogue_info()
	else:
		_next_dialogue_content()

#-------------------------------------------------------------------------------

func _on_DialogueResponse_response_selected(response, text):
	"""
	Post-DialogueResponse handling. Removes the DialogueResponse from the scene
	if specified in the loaded dialogue file and sets a corresponding
	DialogueBox with the response choice.
	"""
	if _block_info['exit_scene']:
		
		match _block_info['screen_side']:
			'top':
				_top_dialogue.update_current_dialogue(text)
				_top_dialogue.instantly_show_dialogue()
				_top_response.deactivate(_block_info['exit_speed'])
			'bottom':
				_bot_dialogue.update_current_dialogue(text)
				_bot_dialogue.instantly_show_dialogue()
				_bot_response.deactivate(_block_info['exit_speed'])
	
	_next_header = response
	_next_dialogue_content()
