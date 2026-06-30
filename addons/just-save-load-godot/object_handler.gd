# This class deals with raw objects.
class_name JSLGObjectHandler

# Object type - this is engine class/base class.
const engine_class_key : String = "+engine_class"

# Script type - this is the script class defined by [GlobalClass]/class_name
const script_class_key : String = "+script_class"

# Object metadata key
const metadata_key : String = "+meta"

static func pack_object_metadata(obj) -> Dictionary:
  return {
    engine_class_key: JSLGClassUtils.get_object_class_name(obj),
    script_class_key: JSLGClassUtils.get_script_class_name(obj),
  }

# Check if an object complies with the savable receiver interface.
static func is_savable(obj) -> bool:
  if not obj is Object: 
    return false

  if JSLGClassUtils.get_object_class_name(obj) == "":
    return false

  if JSLGClassUtils.get_script_class_name(obj) == "":
    return false

  # Object must have savable properties.
  return JSLGSavableTrait.has_trait(obj)


# Get an object's savable properties.
static func get_savable_properties(obj) -> Array:
  var save_properties = JSLGSavableTrait.maybe_save_properties_method(obj)
  if save_properties == JSLG.INVALID_CALLABLE:
    return []
  return save_properties.call()


# This is the unique identifier for the reference map.
# We save effort by using the already-unique in-memory object reference, but this can be anything.
static func get_savable_uid(obj):
  return str(obj.get_instance_id())


# Instantiate an empty object from metadata. 
# This creates a new object - the init() method is run.
static func make_instance(packed_obj):
  if metadata_key not in packed_obj:
    push_error("Save corrupt: save object missing metadata!")
    return null

  var metadata = packed_obj[metadata_key]

  # Make the object.
  var obj = ClassDB.instantiate(metadata[engine_class_key])
  if obj == null:
    print("Save incompatible: Failed to instantiate object of type " + metadata[engine_class_key])
    return null
  
  # Attach script to object.
  var script_info = null
  for global in ProjectSettings.get_global_class_list():
    if global["class"] == metadata[script_class_key]:
      script_info = global
      break

  if script_info == null:
    push_error("Save incompatible: global script class " + metadata[script_class_key] + " does not exist in this project!")
    return null

  # Get the cached script resource from the engine. Either use cached or load it.
  if not ResourceLoader.has_cached(script_info["path"]):
    ResourceLoader.load(script_info["path"])
  var script = ResourceLoader.get_cached_ref(script_info["path"])
  obj.set_script(script)
  
  return obj


static func pack(reference_map, obj : Object) -> Dictionary:
  var obj_dict = {}
  obj_dict[metadata_key] = JSLGObjectHandler.pack_object_metadata(obj)

  var props = JSLGObjectHandler.get_savable_properties(obj)

  for prop_name in props:
    var prop_to_save = JSLGProperty.pack(reference_map, obj.get(prop_name))
    if prop_to_save == null:
      continue
    obj_dict[prop_name] = prop_to_save
  return obj_dict


# Unpack data into an object.
#  Returns false if unpacking failed and the save is corrupt/incompatible.
#  objects_out - Map of instantiated objects
#  uid - UID of the object to unpack
#  packed_data - The data to unpack, as a dictionary of properties.
static func unpack(objects_out, object_data, uid) -> bool:
  var obj = objects_out[uid]
  var packed_data = object_data[uid]
  if obj == null:
    push_error("Save corrupt: no object with UID " + uid + " found to unpack!")
    return false
  if packed_data == null:
    push_error("Save corrupt: no data found to unpack for object " + uid)
    return false
  var known_fields = JSLGObjectHandler.get_savable_properties(obj)
  if known_fields == null:
    known_fields = []

  for prop_name in packed_data.keys():
    # Skip reserved keys.
    if prop_name in [metadata_key]:
      continue
    # Skip fields that aren't savable properties on the target object, with a warning.
    # This is important for security, so a malicious save file can't instantiate
    # any global class and load its properties. (It can instantiate any global class, but
    # the attack surface is reduced to savable properties only.)
    if prop_name not in known_fields:
      print("Warning: skipping unknown property " + prop_name + " of object " + uid)
      continue
    var prop_val = packed_data[prop_name]
    var loaded = JSLGProperty.unpack(objects_out, prop_val)

    if loaded == null:
      push_error("Failed to load property " + prop_name + " of object " + uid)
      return false

    # If the receiving property is an array or dict, use .assign() to support typed array/dict.
    # Collection type hints are a massive piece of duct tape. A typed array/dict is still an 
    # Array/Dictionary for the "is" keyword, but it is not mutually assignable with Object.set() or =.
    var target_prop = obj.get(prop_name)
    if target_prop is Array or target_prop is Dictionary:
      target_prop.assign(loaded)
    else:
      obj.set(prop_name, loaded)
  return true
