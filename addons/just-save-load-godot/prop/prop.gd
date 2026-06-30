# Property handler deals with individual object properties.
class_name JSLGProperty


# Save one property.
#   reference_map - Collected reference map context for the save tree.
#   prop_val - The property value to be saved.
# Returns the packed property value, which can be a primitive or packed dict/array.
static func pack(reference_map, prop_val):
  # Save arrays, dicts.
  if prop_val is Array:
    return JSLGArray.pack(reference_map, prop_val)

  elif prop_val is Dictionary:
    return JSLGDict.pack(reference_map, prop_val)

  # Check for exported resources before checking for generic Object.
  elif JSLGResourceUID.is_exported_resource(prop_val):
    return JSLGResourceUID.pack(prop_val)

  elif prop_val is Object:
    # Only save objects if they are in the reference map.
    if reference_map.has(prop_val):
      return JSLGObjectRef.pack(prop_val)
    return null

  elif JSLGNumeric.is_numeric(prop_val):
    return JSLGNumeric.pack(prop_val)

  elif JSLGBuiltIn.is_builtin(prop_val):
    return JSLGBuiltIn.pack(prop_val)

  return prop_val


# Unpack a propety. We assume all objects have already been instantiated.
# We just unpack properties and resolve references.
#  objects_out - Loaded object map for reference resoultion.
#  prop_data - The property data to be loaded.
static func unpack(objects_out, obj_data):
  # We represent most data types with a Dictionary.
  if obj_data is Dictionary:
    var resolved_ref = JSLGObjectRef.unpack(objects_out, obj_data)
    if resolved_ref != null:
      return resolved_ref
    
    var resolved_numeric = JSLGNumeric.unpack(obj_data)
    if resolved_numeric != null:
      return resolved_numeric
    
    var resolved_builtin = JSLGBuiltIn.unpack(obj_data)
    if resolved_builtin != null:
      return resolved_builtin
    
    var resolved_resource = JSLGResourceUID.unpack(obj_data)
    if resolved_resource != null:
      return resolved_resource
   
    # If it's not a special type, it is just a dictionary.
    return JSLGDict.unpack(objects_out, obj_data)
  
  # Load arrays, which may contain other instantiable objects.
  if obj_data is Array:
    return JSLGArray.unpack(objects_out, obj_data)
  
  # Return loaded primitive.
  return obj_data
