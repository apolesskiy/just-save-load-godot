# SaveLoader contains the static functions to save and load objects.
class_name SaveLoader

# Include illegal character that can't exist in actual property names to avoid conflicts.
const metadata_key : String = "+meta"

# Object type - this is engine class/base class.
const engine_class_key : String = "+engine_class"

# Script type - this is the script class defined by [GlobalClass]/class_name
const script_class_key : String = "+script_class"

# Object UID - this is the save game's unique ID for the object.
const uid_key : String = "+uid"

# This key marks a dictionary as a reference to another object.
const ref_key : String = "+ref"

# This key contains a reference to the root object in save data.
const root_key : String = "+root"

# This key marks a collection as a dictionary.
const dict_key : String = "+dict"

# This key marks the key of a dictionary tuple.
const key_key : String = "+key"

# This key marks the value of a dictionary tuple.
const value_key : String = "+value"

static var __invalid_callable : Callable = func(): pass

# Check an object's savable properties. This is part of the receiver interface.
static func __get_save_properties_method(obj) -> Callable:
  if not obj is Object:
    return __invalid_callable
  if obj.has_method("save_properties"):
    return obj.save_properties
  if obj.has_method("SaveProperties"):
    return obj.SaveProperties
  return __invalid_callable


static func __get_on_load_complete_method(obj) -> Callable:
  if not obj is Object:
    return __invalid_callable
  if obj.has_method("on_load_complete"):
    return obj.on_load_complete
  if obj.has_method("OnLoadComplete"):
    return obj.OnLoadComplete
  return __invalid_callable


# Get an object's savable properties. This is part of the receiver interface.
static func __get_savable_properties(obj) -> Array:
  var save_properties = __get_save_properties_method(obj)
  if save_properties == __invalid_callable:
    return []
  return save_properties.call()


# Get an object's class name as it would appear in ClassDB.
static func __get_object_class_name(obj) -> StringName:
  if not obj is Object:
    return ""
  return obj.get_class()


static func __get_script_class_name(obj) -> String:
  if not obj is Object:
    return ""
  if obj.get_script() == null:
    return ""
  return obj.get_script().get_global_name()


# Check if an object complies with the savable receiver interface.
static func __is_savable(obj) -> bool:
  if not obj is Object: 
    return false

  if __get_object_class_name(obj) == "":
    return false

  if __get_script_class_name(obj) == "":
    return false

  # Object must have savable properties.
  return __get_save_properties_method(obj) != __invalid_callable


static func __is_ref(obj) -> bool:
  return obj is Dictionary and ref_key in obj


static func __is_serialized_dict(obj) -> bool:
  return dict_key in obj


static func __uid_from_ref(ref: Dictionary):
  return ref.get(ref_key, "")


static func __uid_from_object(obj):
  return str(obj.get_instance_id())


static func __object_to_ref(obj : Object) -> Dictionary:
  return {
    ref_key: __uid_from_object(obj)
  }


static func __ref_to_object(uid_to_object_map, ref) -> Object:
  if not __is_ref(ref):
    return null
  var obj = uid_to_object_map.get(ref.get(ref_key, null), null)
  if obj == null:
    print("Bad reference: Object " + str(ref) + " not found in save!")
  return obj


static func __build_object_metadata(obj) -> Dictionary:
  return {
    engine_class_key: __get_object_class_name(obj),
    script_class_key: __get_script_class_name(obj),
  }


# Add a reference to save to the UID map.
# Non-savable references and references that already exist in the map are ignored.
static func __collect_one_reference(collected_objects, obj):
  if not __is_savable(obj):
    return
  if obj in collected_objects:
    return
  # Note resources with a UID are special. We treat them as a value type because they are cached by
  # ResourceLoader.
  if  JSLGResourceUID.is_exported_resource(obj):
    return
  collected_objects[obj] = true


# Introspects an array and returns a list of references to collect.
static func __collect_array(collected_objects, arr : Array) -> Array:
  var to_collect = []
  for elem in arr:
    if __is_savable(elem):
      to_collect.append(elem)
    elif elem is Array:
      to_collect.append_array(__collect_array(collected_objects, elem))
    elif elem is Dictionary:
      to_collect.append_array(__collect_dictionary(collected_objects, elem))

  return to_collect


static func __collect_dictionary(collected_objects, dict : Dictionary):
  return __collect_array(collected_objects, dict.keys()) + __collect_array(collected_objects, dict.values())
  

static func __collect(obj : Object) -> Dictionary:
  # Note: collect is different from save/load in that it is implemented iteratively.
  # We expect reference chains to be arbitrarily long/cyclic, while nested dicts/arrays
  # will be shallow enough to be handled recursively.
  # For example, it is unlikely to see array[array[...until overflow...]].

  if not __is_savable(obj):
    return {}
  var collected_objects = {}
  var collect_queue = [obj]
  # Use the engine's built-in ID because why not, it's guaranteed unique in context.
  while collect_queue.size() > 0:
    var next_obj = collect_queue.pop_front()
    __collect_one_reference(collected_objects, next_obj)
    var props = __get_save_properties_method(next_obj).call()
    for prop in props:
      var prop_val = next_obj.get(prop)

      # Handle savable objects, arrays, and dicts. Everything else can't be a ref so is not relevant.
      if __is_savable(prop_val):
        collect_queue.append(prop_val)
      elif prop_val is Array:
       collect_queue.append_array(__collect_array(collected_objects, prop_val))
      elif prop_val is Dictionary:
        collect_queue.append_array(__collect_dictionary(collected_objects, prop_val))

  return collected_objects


static func __save_array(collected_objects, arr : Array) -> Array:
  var save_arr = []
  for elem in arr:
    var elem_to_save = __save_prop(collected_objects, elem)
    if elem_to_save == null:
      continue
    save_arr.append(elem_to_save)
  return save_arr


static func __save_dictionary(collected_objects, dict : Dictionary) -> Dictionary:
  var save_dict = {}
  save_dict[dict_key] = []
  for key in dict.keys():
    var key_to_save = __save_prop(collected_objects, key)
    if key_to_save == null:
      continue
    var val_to_save = __save_prop(collected_objects, dict[key])
    if val_to_save == null:
      continue
    var save_tuple = {key_key: key_to_save, value_key: val_to_save}
    save_dict[dict_key].append(save_tuple)
  return save_dict


static func __save_prop(collected_objects, prop_val):
  if prop_val is Array:
    return __save_array(collected_objects, prop_val)
  elif prop_val is Dictionary:
    return __save_dictionary(collected_objects, prop_val)
  # Check for exported resources before checking for generic Object.
  elif JSLGResourceUID.is_exported_resource(prop_val):
    return JSLGResourceUID.make_exported_resource(prop_val)
  elif prop_val is Object:
    if collected_objects.has(prop_val):
      return __object_to_ref(prop_val)
    return null
  elif prop_val is int or prop_val is float:
    return JSLGNumeric.make_numeric(prop_val)
  elif JSLGBuiltIn.is_builtin(prop_val):
    return JSLGBuiltIn.make_builtin(prop_val)
  return prop_val


# Save this save data.
static func save(to_save: Object) -> String:
  if to_save == null:
    push_error("Save failed: root object is null!")
    return ""
  var collected_objects = __collect(to_save)
  var save_dict = {}
  save_dict[root_key] = __object_to_ref(to_save)
  for obj in collected_objects.keys():
    var obj_dict = {}
    obj_dict[metadata_key] = __build_object_metadata(obj)
    var props = __get_savable_properties(obj)
    for prop_name in props:
      var prop_to_save = __save_prop(collected_objects, obj.get(prop_name))
      if prop_to_save == null:
        continue
      obj_dict[prop_name] = prop_to_save
    save_dict[__uid_from_object(obj)] = obj_dict
 
  return JSON.stringify(save_dict)


static func __load_prop(objects_out, obj_data):
  if obj_data is Dictionary:
    # If we find a dictionary, it can be a ref, a collection, or an object
    var resolved_ref = __ref_to_object(objects_out, obj_data)
    if resolved_ref != null:
      return resolved_ref
    var resolved_numeric = JSLGNumeric.get_numeric(obj_data)
    if resolved_numeric != null:
      return resolved_numeric
    var resolved_builtin = JSLGBuiltIn.get_builtin(obj_data)
    if resolved_builtin != null:
      return resolved_builtin
    var resolved_resource = JSLGResourceUID.get_exported_resource(obj_data)
    if resolved_resource != null:
      return resolved_resource
    return __load_dictionary(objects_out, obj_data)
  if obj_data is Array:
    return __load_array(objects_out, obj_data)
  
  return obj_data


static func __load_array(objects_out, obj_data):
  var arr = []
  for elem in obj_data:
    var elem_val = __load_prop(objects_out, elem)
    if elem_val == null:
      print("Warning: skipping array element due to load failure.")
      continue
    arr.append(elem_val)
  return arr


static func __load_dictionary(objects_out, obj_data):
  var dict = {}
  if not __is_serialized_dict(obj_data):
    print("Warning: dictionary is not a ref or serialized dict, skipping.")
    return null
  for tuple in obj_data[dict_key]:
    var key_val = __load_prop(objects_out, tuple[key_key])
    if key_val == null:
      print("Warning: skipping dictionary tuple due to key load failure.")
      continue
    var val_val = __load_prop(objects_out, tuple[value_key])
    if val_val == null:
      print("Warning: skipping dictionary tuple due to value load failure.")
      continue
    dict[key_val] = val_val
  return dict


static func __object_instance_from_metadata(metadata):
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


# Load save data into an object.
static func load(save_str: String) -> Object:
  var json = JSON.new()
  var err = json.parse(save_str)
  if err != OK:
    print("Save corrupt: failed to parse save data [Error " + str(err) + "] at line " + str(json.get_error_line()) + ": " + json.get_error_message()) 
    return
  var objects_out = {}
  var object_data = json.data
  if object_data == null:
    print("Save corrupt: save data missing object list")
    return null

  if not object_data.has(root_key):
    push_error("Save corrupt: save does not specify a root object!")
    return null

  var root_ref = object_data[root_key]
  if __uid_from_ref(root_ref) == "":
    push_error("Save corrupt: save root object has invalid reference")
    return null

  # Instantiate all objects to be loaded.
  for uid in object_data.keys():
    # Skip metadata.
    if uid in [root_key]:
      continue
    var obj_dict = object_data[uid]
    if metadata_key not in obj_dict:
      push_error("Save corrupt: save object " + uid + " missing metadata!")
      return null
    var obj = __object_instance_from_metadata(obj_dict[metadata_key])
    if obj == null:
      push_error("Failed to load object " + uid)
      return null
    objects_out[uid] = obj
  
  # Populate properties.
  for uid in objects_out.keys():
    var obj = objects_out[uid]
    var obj_data = object_data[uid]

    var known_fields = __get_save_properties_method(obj).call()
    if known_fields == null:
      known_fields = []

    for prop_name in obj_data.keys():
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
      var prop_val = obj_data[prop_name]
      var loaded = __load_prop(objects_out, prop_val)

      if loaded == null:
        push_error("Failed to load property " + prop_name + " of object " + uid)
        return null

      # If the receiving property is an array or dict, use .assign() to support typed array/dict.
      # Collection type hints are a massive piece of duct tape. A typed array/dict is still an 
      # Array/Dictionary for the "is" keyword, but it is not mutually assignable with Object.set() or =.
      var target_prop = obj.get(prop_name)
      if target_prop is Array or target_prop is Dictionary:
        target_prop.assign(loaded)
      else:
        obj.set(prop_name, loaded)

  # Call on_load_complete.
  for obj in objects_out.values():
    var on_load_complete = __get_on_load_complete_method(obj)
    if on_load_complete != __invalid_callable:
      on_load_complete.call()

  return __ref_to_object(objects_out, root_ref)
