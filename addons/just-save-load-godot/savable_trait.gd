# JSLGSavableTrait makes an object savable by JSLG.
# There are two ways to implement the trait: implement on an object, or implement and
# register a packer for a class.
#
# Trait implementation requirements:
# 1. Script must have a class_name (appear in the global class table).
# 2. Script must implement method save_properties() listing savable properties.
# Optional methods:
# - pre_save() will be called before saving the object.
# - post_load() will be called after loading the object.
#
# Packer requirements:
# 1. Target object must have a class_name or be an engine type.
# 2. Script must implement static save_properties() -> Array method.
# 3. Script must register as a packer for a class in JSLGPackerRegistry. This can be done in static_init.
# Optional methods:
# - static pre_save(obj) will be called before saving an object of the target class.
# - static post_load(obj) will be called after loading an object of the target class.

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
  # Non-static
  var pre_save = JSLGSavableTrait.maybe_pre_save_method(obj)
  if pre_save != JSLG.INVALID_CALLABLE:
    pre_save.call()
    return

  # Static
  var packer = JSLGObjectHandler.get_packer_for_object(obj)
  if packer != null:
    JSLGSavableTrait.call_static_pre_save(packer, obj)


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
  # Non-static
  var post_load = JSLGSavableTrait.maybe_post_load_method(obj)
  if post_load != JSLG.INVALID_CALLABLE:
    post_load.call()
    return

  # Static
  var packer = JSLGObjectHandler.get_packer_for_object(obj)
  if packer != null:
    JSLGSavableTrait.call_static_post_load(packer, obj)

# Find a static method on a script matching one of the candidate names, returning
# its name (or "" if none exist). Uses Script.has_script_method(), which detects
# both GDScript and C# static methods - Object.has_method()/get() do not report
# C# static methods, so they cannot be used for packers. The method is invoked with
# script.call(name, ...), which works for static methods in both languages.
static func find_static_method(script, method_names : Array[String]) -> String:
  if not script is Script:
    return ""
  for method_name in method_names:
    if script.has_script_method(method_name):
      return method_name
  return ""


# Packer trait check: does the script define a static save_properties method?
static func has_static_trait(script) -> bool:
  return JSLGSavableTrait.find_static_method(script, save_properties_method_names) != ""


static func call_static_save_properties(script, obj) -> Array:
  var method_name = JSLGSavableTrait.find_static_method(script, save_properties_method_names)
  if method_name == "":
    return []
  return script.call(method_name, obj)


static func call_static_pre_save(script, obj) -> void:
  var method_name = JSLGSavableTrait.find_static_method(script, pre_save_method_name)
  if method_name != "":
    script.call(method_name, obj)


static func call_static_post_load(script, obj) -> void:
  var method_name = JSLGSavableTrait.find_static_method(script, post_load_method_name)
  if method_name != "":
    script.call(method_name, obj)
