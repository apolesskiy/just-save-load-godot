# A savable Node that supports a model_scene. On load, JSLGNodeTreeHandler instantiates
# the model_scene and reparents its non-savable ("static") children onto this node,
# restoring data that was never serialized.
class_name JSLGTestModelNode extends Node

# Left untyped so the "non-PackedScene" test can assign a non-scene value.
# get_model_scene() guards on the type at load time.
var model_scene = null
var int_prop = 0
# Transient flag set by post_load; not part of save_properties.
var was_loaded = false

func save_properties() -> Array:
  return ["model_scene", "int_prop"]

func post_load() -> void:
  was_loaded = true
