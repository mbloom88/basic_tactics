extends Node

# Item references
export (String, DIR) var _melee_weapon_directory = ""
export (String, DIR) var _ranged_weapon_directory = ""
var _items = {}

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready() -> void:
	_load_item_references(_melee_weapon_directory, 'weapon')
	_load_item_references(_ranged_weapon_directory, 'weapon')

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
		
		_items[file_name.get_basename()] = load(directory.plus_file(file_name))

################################################################################
# PUBLIC METHODS
################################################################################

func lookup_icon(item_ref):
	"""
	Looks up an Items's icon from its associated .tres file.
	
	Args:
		- item_ref (String): The Item's .tres file name.
	
	Returns:
		- icon (Texture): The Item's icon.
	"""
	assert item_ref in _items
	assert _items[item_ref].icon
	
	var icon = _items[item_ref].icon
	
	return icon

#-------------------------------------------------------------------------------

func lookup_name(item_ref):
	"""
	Looks up an item's name from its associated .tres file.
	
	Args:
		- item_ref (String): The Items's .tres file name.
	
	Returns:
		- item_name (String): Item name.
	"""
	assert item_ref in _items
	var item_name = _items[item_ref].item_name
	
	return item_name
