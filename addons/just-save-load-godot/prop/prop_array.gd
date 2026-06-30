class_name JSLGArray


static func pack(collected_objects, arr : Array) -> Array:
  var save_arr = []
  for elem in arr:
    var elem_to_save = JSLGProperty.pack(collected_objects, elem)
    if elem_to_save == null:
      continue
    save_arr.append(elem_to_save)
  return save_arr


static func unpack(objects_out, obj_data):
  var arr = []
  for elem in obj_data:
    var elem_val = JSLGProperty.unpack(objects_out, elem)
    if elem_val == null:
      print("Warning: skipping array element due to load failure.")
      continue
    arr.append(elem_val)
  return arr