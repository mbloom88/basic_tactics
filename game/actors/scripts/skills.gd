extends Node

# Signals
signal weapon_reload_requested

# Skill info
var _job_skills = []
var _weapon_skills = []

################################################################################
# PRIVATE METHODS
################################################################################

func _sort_skills_list():
	var skills = []
	for job_skill in _job_skills:
		skills.append(job_skill)
	for weapon_skill in _weapon_skills:
		skills.append(weapon_skill)
	for skill in skills:
		var new_skill = skill.instance()
		add_child(new_skill)

################################################################################
# PUBLIC METHODS
################################################################################

func load_job_skills(skill_refs):
	_job_skills = []
	for skill in get_children():
		remove_child(skill)
		skill.queue_free()
	
	for skill_ref in skill_refs:
		_job_skills.append(SkillsDatabase.provide_skill(skill_ref))
	
	_sort_skills_list()

#-------------------------------------------------------------------------------

func load_weapon_skills(skill_refs):
	_weapon_skills = []
	for skill in get_children():
		remove_child(skill)
		skill.queue_free()
	
	for skill_ref in skill_refs:
		_weapon_skills.append(SkillsDatabase.provide_skill(skill_ref))
	
	_sort_skills_list()

#-------------------------------------------------------------------------------

func provide_skills():
	"""
	Returns:
		- skills (Array): A list of all loaded skill objects.
	"""
	var skills = []
	for skill in get_children():
		skills.append(skill)
	
	return skills
