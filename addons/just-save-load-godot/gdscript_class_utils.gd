class_name JSLGClassUtils

# Get an object's class name as it would appear in ClassDB.
static func get_object_class_name(obj) -> StringName:
  if not obj is Object:
    return ""
  return obj.get_class()


# Get script class name (defined by class_name keyword).
# Note that script class != ClassDB class - all scripts are ClassDB "Script".
static func get_script_class_name(obj) -> String:
  if not obj is Object:
    return ""
  if obj.get_script() == null:
    return ""
  return obj.get_script().get_global_name()
