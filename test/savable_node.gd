# A Node that implements the JSLGSavable trait directly. Its savable children are
# saved and re-parented automatically by JSLGNodeTreeHandler.
class_name JSLGTestSavableNode extends Node

var int_prop = 0
var string_prop = ""
# Transient flag set by post_load; not part of save_properties.
var was_loaded = false

func save_properties() -> Array:
  return ["int_prop", "string_prop"]

func post_load() -> void:
  was_loaded = true
