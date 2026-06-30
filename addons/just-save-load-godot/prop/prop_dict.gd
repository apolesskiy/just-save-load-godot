class_name JSLGDict

# This key marks a collection as a dictionary.
const prop_key : String = "+dict"

# This key marks the key of a dictionary tuple.
const key_key : String = "+key"

# This key marks the value of a dictionary tuple.
const value_key : String = "+value"

static func is_dict(obj) -> bool:
  return prop_key in obj


static func pack(collected_objects, dict : Dictionary) -> Dictionary:
  var save_dict = {}
  save_dict[prop_key] = []
  for key in dict.keys():
    var key_to_save = JSLGProperty.pack(collected_objects, key)
    if key_to_save == null:
      continue
    var val_to_save = JSLGProperty.pack(collected_objects, dict[key])
    if val_to_save == null:
      continue

    # Store as key-value tuples because Godot dict keys are arbitrary Variants.
    var save_tuple = {key_key: key_to_save, value_key: val_to_save}
    save_dict[prop_key].append(save_tuple)
  return save_dict


static func unpack(objects_out, obj_data):
  var dict = {}
  if not is_dict(obj_data):
    print("Warning: dictionary is not a ref or serialized dict, skipping.")
    return null
  for tuple in obj_data[prop_key]:
    var key_val = JSLGProperty.unpack(objects_out, tuple[key_key])
    if key_val == null:
      print("Warning: skipping dictionary tuple due to key load failure.")
      continue
    var val_val = JSLGProperty.unpack(objects_out, tuple[value_key])
    if val_val == null:
      print("Warning: skipping dictionary tuple due to value load failure.")
      continue
    dict[key_val] = val_val
  return dict