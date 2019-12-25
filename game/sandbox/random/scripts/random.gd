extends Node2D

var is_true = true

func _ready():
	my_func1()

func my_func1():
	if is_true:
		print('func1')
		my_func2()
	my_func3()


func my_func2():
	print('func2')


func my_func3():
	print('func3')