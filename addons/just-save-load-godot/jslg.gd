# SaveLoader contains the static functions to save and load objects.
class_name JSLG

# All keys include "+" prefix, which is illegal in property names.

# This key contains a reference to the root object in save data.
const root_key : String = "+root"

static var INVALID_CALLABLE : Callable = func(): pass


static func register_packer(packer_script : Script, example_obj: Object) -> void:
  JSLGObjectHandler.register_packer(packer_script, example_obj)


# Save an object and its references.
static func save(to_save: Object) -> String:
  if to_save == null:
    push_error("Save failed: root object is null!")
    return ""

  var reference_map = JSLGReferenceCollector.collect_references(to_save)

  # Call pre_save on all collected objects.
  for obj in reference_map.keys():
    JSLGSavableTrait.call_pre_save(obj)

  var save_dict = {}

  # Pack root as object reference.
  save_dict[root_key] = JSLGObjectRef.pack(to_save)

  # Save all referenced objects. Note this is a flat map!
  for obj in reference_map.keys():
    save_dict[JSLGObjectHandler.get_savable_uid(obj)] = JSLGObjectHandler.pack(reference_map, obj)
 
  return JSON.stringify(save_dict)



# Load objects from a save string.
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
  if JSLGObjectRef.uid_from_ref(root_ref) == "":
    push_error("Save corrupt: save root object has invalid reference")
    return null

  # Instantiate all objects to be loaded.
  for uid in object_data.keys():
    # Skip metadata.
    if uid == root_key:
      continue
    var obj = JSLGObjectHandler.make_instance(object_data[uid])
    if obj == null:
      push_error("Failed to load object " + uid)
      return null
    objects_out[uid] = obj
  
  # Populate properties.
  for uid in objects_out.keys():
    if not JSLGObjectHandler.unpack(objects_out, object_data, uid):
      push_error("Failed to unpack object " + uid)
      return null

  # Assign loaded children to nodes.
  for uid in objects_out.keys():
    if not JSLGNodeTreeHandler.unpack(objects_out, object_data, uid):
      push_error("Failed to unpack savable children for node " + uid)
      return null

  # Call post_load.
  for obj in objects_out.values():
    JSLGSavableTrait.call_post_load(obj)

  # Return root object.
  return JSLGObjectRef.unpack(objects_out, root_ref)
