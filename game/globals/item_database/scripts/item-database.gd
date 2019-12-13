extends Node

# Item references
export (String, DIR) var _weapon_directory = ""
var _weapons = {}

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready() -> void:
	_load_item_references(_weapon_directory, 'weapon')

################################################################################
# PRIVATE METHODS
################################################################################

func _load_item_references(directory, type):
	"""
	Loads item .tres files and stores them in a local dictionary for
	reference purposes. Afterwards, the database can be called upon to provide
	item information such as weapon stats or item objects.
	"""
	var dir = Directory.new()
	assert dir.dir_exists(directory)
	
	if not dir.open(directory) == OK:
		print("Could not read directory %s" % directory)
	
	dir.list_dir_begin()
	var file_name = ""
	
	while true:
		file_name = dir.get_next()
		if file_name == "":
			break
		if not file_name.ends_with(".tres"):
			continue
		
		match type:
			'weapon':
				_weapons[file_name.get_basename()] = \
					load(directory.plus_file(file_name))
