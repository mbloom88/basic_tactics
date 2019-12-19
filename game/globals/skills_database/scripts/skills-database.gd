extends Node

# Skill references
export (String, DIR) var _weapon_skills_directory = ""
var _skills = {}

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	_load_skill_references(_weapon_skills_directory)

################################################################################
# PRIVATE METHODS
################################################################################

func _load_skill_references(directory):
	"""
	Loads skill .tres files and stores them in a local dictionary for
	reference purposes. Afterwards, the database can be called upon to provide
	skill information.
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
		
		_skills[file_name.get_basename()] = load(directory.plus_file(file_name))

################################################################################
# PUBLIC METHODS
################################################################################

func lookup_description(skill_ref):
	assert skill_ref in _skills
	var skill_description = _skills[skill_ref].description
	
	return skill_description

#-------------------------------------------------------------------------------

func lookup_name(skill_ref):
	assert skill_ref in _skills
	var skill_name = _skills[skill_ref].skill_name
	
	return skill_name

#-------------------------------------------------------------------------------

func provide_skill(skill_ref):
	assert skill_ref in _skills
	var skill = _skills[skill_ref].skill_scene
	
	return skill
