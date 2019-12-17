extends Node

func _ready():
	do_something_first()
	do_something_second()



func do_something_first():
	var thing = 0
	for i in range(10000):
		thing = i
		print(thing)
	print('I just finished iterating over %s numbers!' % thing)


func do_something_second():
	print('I just said something!')
