class_name JSLGBuiltIn

# Marker for built-in variants that can be str_to_var'd safely.
const builtin_key : String = "+builtin"

# These are the built-in variants that  we deem safe to serialize directly.
# As they are not Objects, they should not have any references to other objects.
static func is_builtin(obj) -> bool:
  return obj is Vector2 or\
    obj is Vector2i or\
    obj is Vector3 or\
    obj is Vector3i or\
    obj is Color or\
    obj is Rect2 or\
    obj is Rect2i or\
    obj is Transform2D or\
    obj is Plane or\
    obj is Quaternion or\
    obj is AABB or\
    obj is Basis or\
    obj is Transform3D or\
    obj is RID or\
    obj is PackedByteArray or\
    obj is PackedInt32Array or\
    obj is PackedInt64Array or\
    obj is PackedFloat32Array or\
    obj is PackedFloat64Array or\
    obj is PackedStringArray or\
    obj is PackedVector2Array or\
    obj is PackedVector3Array or\
    obj is PackedColorArray 


static func make_builtin(prop) -> Dictionary:
  if not is_builtin(prop):
    return {}
  return {builtin_key: var_to_str(prop)}


static func get_builtin(obj):
  if not obj is Dictionary:
    return null
  if builtin_key not in obj:
    return null
  var builtin = obj[builtin_key]
  # Builtin serialization is a string "<BuiltinType>(datadatadata)"
  var builtin_type = builtin.substr(0, builtin.find("("))

  match builtin_type:
    "Vector2":
      return str_to_var(builtin) as Vector2
    "Vector2i":
      return str_to_var(builtin) as Vector2i
    "Vector3":
      return str_to_var(builtin) as Vector3
    "Vector3i":
      return str_to_var(builtin) as Vector3i
    "Color":
      return str_to_var(builtin) as Color
    "Rect2":
      return str_to_var(builtin) as Rect2
    "Rect2i":
      return str_to_var(builtin) as Rect2i
    "Transform2D":
      return str_to_var(builtin) as Transform2D
    "Plane":
      return str_to_var(builtin) as Plane
    "Quaternion":
      return str_to_var(builtin) as Quaternion
    "AABB":
      return str_to_var(builtin) as AABB
    "Basis":
      return str_to_var(builtin) as Basis
    "Transform3D":
      return str_to_var(builtin) as Transform3D
    "RID":
      return str_to_var(builtin) as RID
    "PackedByteArray":
      return str_to_var(builtin) as PackedByteArray
    "PackedInt32Array":
      return str_to_var(builtin) as PackedInt32Array
    "PackedInt64Array":
      return str_to_var(builtin) as PackedInt64Array
    "PackedFloat32Array":
      return str_to_var(builtin) as PackedFloat32Array
    "PackedFloat64Array":
      return str_to_var(builtin) as PackedFloat64Array
    "PackedStringArray":
      return str_to_var(builtin) as PackedStringArray
    "PackedVector2Array":
      return str_to_var(builtin) as PackedVector2Array
    "PackedVector3Array":
      return str_to_var(builtin) as PackedVector3Array
    "PackedColorArray":
      return str_to_var(builtin) as PackedColorArray
    _:
      push_warning("Invalid built-in type: " + builtin_type)
      return null