# This class deals with raw objects.
class_name JSLGObjectHandler

# Object type - this is engine class/base class.
const engine_class_key : String = "+engine_class"

# Script type - this is the script class defined by [GlobalClass]/class_name
const script_class_key : String = "+script_class"

# Object metadata key
const metadata_key : String = "+meta"

# Will happen before *this* class's static init.
static var __packer_registry_mutex : Mutex = Mutex.new()
static var __packer_registry : Dictionary = {}

static func __metadata_to_packer_registry_key(metadata : Dictionary) -> String:
  return metadata[engine_class_key] + "+" + metadata[script_class_key]

static func __packer_registry_key_to_metadata(key : String) -> Dictionary:
  var parts = key.split("+")
  return {
    engine_class_key: parts[0],
    script_class_key: parts[1],
  }

# Register a packer for a class. This requires an object instance, because there
# is no way to associate the script class with the object class otherwise.
static func register_packer(packer_script : Script, example_obj: Object) -> void:
  # Validate before locking mutex
  if not packer_script is Script:
    push_error("Packer must be a script!")
    return

  if not JSLGSavableTrait.has_static_trait(packer_script):
    push_error("Packer script %s must implement static JSLGSavableTrait!" % packer_script.resource_path)
    return

  var md = JSLGObjectHandler.pack_object_metadata(example_obj)
  var key = JSLGObjectHandler.__metadata_to_packer_registry_key(md)

  JSLGObjectHandler.__packer_registry_mutex.lock()
  if key in JSLGObjectHandler.__packer_registry:
    push_error("Packer for class " + key + " is already registered to script " + str(JSLGObjectHandler.__packer_registry[key].resource_path) + "!")
  else:
    __packer_registry[key] = packer_script
  JSLGObjectHandler.__packer_registry_mutex.unlock()

  print("Registered packer for class " + key + ": " + packer_script.resource_path)


static func get_packer_for_object(obj) -> Script:
  var md = JSLGObjectHandler.pack_object_metadata(obj)
  var key = JSLGObjectHandler.__metadata_to_packer_registry_key(md)
  JSLGObjectHandler.__packer_registry_mutex.lock()
  var packer = JSLGObjectHandler.__packer_registry.get(key, null)
  JSLGObjectHandler.__packer_registry_mutex.unlock()
  return packer


static func pack_object_metadata(obj) -> Dictionary:
  return {
    engine_class_key: JSLGClassUtils.get_object_class_name(obj),
    script_class_key: JSLGClassUtils.get_script_class_name(obj),
  }

# Check if an object is savable by JSLG.
static func is_savable(obj) -> bool:
  if not obj is Object: 
    return false

  if JSLGClassUtils.get_object_class_name(obj) == "":
    return false

  # Object implements trait
  if JSLGSavableTrait.has_trait(obj):
    return true

  # Check for registered packer. Must be an exact match.
  var packer = JSLGObjectHandler.get_packer_for_object(obj)
  return packer != null


# Get an object's savable properties.
static func get_savable_properties(obj) -> Array:
  # Implements savable.
  if JSLGSavableTrait.has_trait(obj):
    var save_properties = JSLGSavableTrait.maybe_save_properties_method(obj)
    if save_properties == JSLG.INVALID_CALLABLE:
      return []
    return save_properties.call()

  # Packer
  var packer = JSLGObjectHandler.get_packer_for_object(obj)
  if packer != null:
    # Note the static save_properties is called on the packer (Script), passing obj.
    return JSLGSavableTrait.call_static_save_properties(packer, obj)
  return []


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

  # Nodes save their savable children as references, in addition to their properties.
  if obj is Node:
    obj_dict.merge(JSLGNodeTreeHandler.pack(reference_map, obj))
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
    if prop_name in [JSLGObjectHandler.metadata_key, JSLGNodeTreeHandler.children_key]:
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
