"""
A database for looking up actor references.
"""
extends Node

# Character references
export (String, DIR) var _actor_reference_directory = ""
var _actors = {}

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready() -> void:
	_load_actor_references()

################################################################################
# PRIVATE METHODS
################################################################################

func _load_actor_references():
	"""
	Loads all actor .tres files and stores them in a local dictionary for
	reference purposes. Afterwards, the database can be called upon to provide
	actor information such as names and portraits.
	"""
	var dir = Directory.new()
	assert dir.dir_exists(_actor_reference_directory)
	
	if not dir.open(_actor_reference_directory) == OK:
		print("Could not read directory %s" % _actor_reference_directory)
	
	dir.list_dir_begin()
	var file_name = ""
	
	while true:
		file_name = dir.get_next()
		
		if file_name == "":
			break
		
		if not file_name.ends_with(".tres"):
			continue
		
		_actors[file_name.get_basename()] = \
			load(_actor_reference_directory.plus_file(file_name))

################################################################################
# PUBLIC METHODS
################################################################################

func lookup_name(actor_ref):
	"""
	Looks up an actor's name from its associated .tres file.
	
	Args:
		- actor_ref (String): The actor's .tres file name.
	
	Returns:
		- name_info (Array): Contains the following Strings:
			* name_info[0]: Actor's first name.
			* name_info[1]: Actor's nick name.
			* name_info[2]: Actor's last name.
	"""
	assert actor_ref in _actors
	
	var name_info = [
		_actors[actor_ref].first_name,
		_actors[actor_ref].nick_name,
		_actors[actor_ref].last_name
		]
	
	return name_info

#-------------------------------------------------------------------------------

func lookup_portrait(actor_ref, expression="neutral"):
	"""
	Looks up an actor's portrait expression from its associated .tres file.
	
	Args:
		- actor_ref (String): The actor's .tres file name.
		- expression (String): The desired portrait expression to represent the
			specified actor.
	
	Returns:
		- portrait (Texture): An expression portrait.
	"""
	assert actor_ref in _actors
	assert expression in _actors[actor_ref].expressions
	
	var portrait = _actors[actor_ref].expressions[expression]
	
	return portrait
