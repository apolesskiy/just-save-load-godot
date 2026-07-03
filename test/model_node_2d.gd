# A savable Node2D with a model_scene that also saves its own transform. Used to verify
# that static (non-savable) children declared in the model_scene keep their authored local
# offset when reparented onto the loaded node, so their global position is preserved across
# a save/load round trip - matching what PackedScene.instantiate() would produce.
class_name JSLGTestModelNode2D extends Node2D

# Untyped for parity with JSLGTestModelNode; get_model_scene() guards the type at load.
var model_scene = null

func save_properties() -> Array:
  return ["model_scene", "transform"]
