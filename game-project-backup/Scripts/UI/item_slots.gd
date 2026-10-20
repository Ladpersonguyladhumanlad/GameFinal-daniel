extends Node

#region Item slot arrays
@onready var slot: Array[Node] = [
	$Slot1,
	$Slot2,
	$Slot3,
	$Slot4,
	$Slot5,
	$Slot6,
	$Slot7,
	$Slot8
]

var slot_occupied: Array[bool] = [
	false, # 1
	false, # 2
	false, # 3
	false, # 4
	false, # 5
	false, # 6
	false, # 7
	false, # 8
]
#endregion


func receive_item(item: Node):
	if item:
		for i in slot_occupied.size():
			if not slot_occupied[i]:
				print(item, i)
				item.reparent(slot[i])
				item.init()
				break



func slot_item_added(slot: Node, slot_id: int):
	print(slot_id)
	slot_occupied[slot_id] = true


func slot_item_removed(slot: Node, slot_id: int):
	print(slot_id)
	slot_occupied[slot_id] = false
