extends Area3D

class_name Interactor

func interact(interactable: Interactable) -> void:
	interactable.interacted.emit(self)

func focus(interactable: Interactable) -> void:
	interactable.focused.emit(self)

func unfocus(interactable: Interactable) -> void:
	interactable.unfocused.emit(self)

func get_closest_interactable() -> Interactable:
	var list: Array[Area3D] = get_overlapping_areas()
	var closest_distance: float = INF
	var closest: Interactable = null
	for interactable in list:
		var distance = interactable.global_position.distance_to(global_position)
		if distance < closest_distance:
			closest = interactable as Interactable
			closest_distance = distance
	return closest
