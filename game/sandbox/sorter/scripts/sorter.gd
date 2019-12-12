extends Node2D

var stuff = []
var actor1 = {'move': 5,}
var actor2 = {'move': 2,}
var actor3 = {'move': 10,}
var actor4 = {'move': 1,}

################################################################################
# CLASSES
################################################################################

class CustomSorter:
	static func move_sorter(a, b):
		if a.provide_job_info()['move'] < b['move']:
			return true
		return false

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	stuff.append(actor1)
	stuff.append(actor2)
	stuff.append(actor3)
	stuff.append(actor4)
	
	print(stuff)
	stuff.sort_custom(CustomSorter, 'move_sorter')
	print(stuff)
