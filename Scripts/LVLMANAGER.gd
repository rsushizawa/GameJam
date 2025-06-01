extends Node

var lvl := "1"  # Vai receber o nome da cena atual como string
var max_lvl := 5

func next_level():
	var new_lvl = int(lvl) + 1
	if new_lvl <= max_lvl:
		lvl = str(new_lvl)
		print("Avançando para o nível:", lvl)
	else:
		print("Último nível alcançado.")
