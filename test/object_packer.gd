# A packer for JSLGTestPackerTarget. It implements the JSLGSavable trait *statically*
# so that JSLGTestPackerTarget can be saved/loaded without implementing the trait itself.
#
# Register with:
#   JSLG.register_packer(JSLGTestPacker, JSLGTestPackerTarget.new())
class_name JSLGTestPacker


# REQUIRED: static save_properties(obj) -> Array
# Returns the list of properties to save for the given object.
static func save_properties(obj) -> Array:
  return ["int_prop", "string_prop", "nested_prop"]


# OPTIONAL: static pre_save(obj) -> void, called before the object is serialized.
static func pre_save(obj) -> void:
  obj.was_saved = true


# OPTIONAL: static post_load(obj) -> void, called after the object is loaded.
static func post_load(obj) -> void:
  obj.was_loaded = true
