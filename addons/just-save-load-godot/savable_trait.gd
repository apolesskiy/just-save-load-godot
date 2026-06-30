# JSLGSavableTrait is one of two ways to save an object with JSLG.
#
# Trait requirements:
# 1. Script must have a class_name (appear in the global class table).
# 2. Script must implement method save_properties() listing savable properties.
# Optional methods:
# - pre_save() will be called before saving the object.
# - post_load() will be called after loading the object.
class_name JSLGSavableTrait

const save_properties_method_names : Array[String] = ["save_properties", "SaveProperties"]
const pre_save_method_name : Array[String] = ["pre_save", "PreSave"]
const post_load_method_name : Array[String] = ["post_load", "PostLoad"]


static func has_trait(obj) -> bool:
  return JSLGSavableTrait.maybe_save_properties_method(obj) != JSLG.INVALID_CALLABLE

# REQUIRED:
# func save_properties() -> Array
#   Should return an array of property names to be saved/loaded.
static func maybe_save_properties_method(obj) -> Callable:
  if not obj is Object:
    return JSLG.INVALID_CALLABLE
  for method_name in save_properties_method_names:
    if obj.has_method(method_name):
      return obj.get(method_name)
  return JSLG.INVALID_CALLABLE


# Optional:
# func pre_save() -> void
#   This method will be called before saving the object. It can be used to prepare the
#   object for serialization.
static func maybe_pre_save_method(obj) -> Callable:
  if not obj is Object:
    return JSLG.INVALID_CALLABLE
  for method_name in pre_save_method_name:
    if obj.has_method(method_name):
      return obj.get(method_name)
  return JSLG.INVALID_CALLABLE


static func call_pre_save(obj) -> void:
  var pre_save = JSLGSavableTrait.maybe_pre_save_method(obj)
  if pre_save != JSLG.INVALID_CALLABLE:
    pre_save.call()


# Optional:
# func post_load() -> void
#   This method will be called after loading the object. It can be used to restore any
#   transient state that was not saved.
static func maybe_post_load_method(obj) -> Callable:
  if not obj is Object:
    return JSLG.INVALID_CALLABLE
  for method_name in post_load_method_name:
    if obj.has_method(method_name):
      return obj.get(method_name)
  return JSLG.INVALID_CALLABLE


static func call_post_load(obj) -> void:
  var post_load = JSLGSavableTrait.maybe_post_load_method(obj)
  if post_load != JSLG.INVALID_CALLABLE:
    post_load.call()