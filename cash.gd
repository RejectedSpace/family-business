extends RigidBody3D


func _on_body_entered(body: Node) -> void:
	if body is Player:
		body.get_cash()
		queue_free()


func _on_interactable_interacted(interactor: Interactor) -> void:
	interactor.player.get_cash()
	interactor.player.hud.show_money_tip(false)
	queue_free()

func _on_interactable_focused(interactor: Interactor) -> void:
	interactor.player.hud.show_money_tip(true)

func _on_interactable_unfocused(interactor: Interactor) -> void:
	interactor.player.hud.show_money_tip(false)
