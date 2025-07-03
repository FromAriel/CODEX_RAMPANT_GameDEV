###############################################################
# src/scripts/player.gd
# Key Classes      • Player – controllable character
# Key Functions    • _physics_process – handles movement
###############################################################
class_name Player
extends CharacterBody2D

const SPEED := 200.0


func _ready() -> void:
    if not has_node("Sprite2D"):
        var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
        img.fill(Color.WHITE)
        var tex := ImageTexture.create_from_image(img)
        var sprite := Sprite2D.new()
        sprite.name = "Sprite2D"
        sprite.texture = tex
        add_child(sprite)
    if not has_node("CollisionShape2D"):
        var shape := RectangleShape2D.new()
        shape.extents = Vector2(8, 8)
        var col := CollisionShape2D.new()
        col.shape = shape
        add_child(col)


func _physics_process(_delta: float) -> void:
    var input_vec := (
        Vector2(
            Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
            Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
        )
        . normalized()
    )
    velocity = input_vec * SPEED
    move_and_slide()
