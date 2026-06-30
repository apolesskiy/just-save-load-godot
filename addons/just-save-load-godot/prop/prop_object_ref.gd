# References to other objects.
class_name JSLGObjectRef

# This key marks a dictionary as a reference to another object.
const ref_key : String = "+ref"

# Object UID - this is the save game's unique ID for the object.
const uid_key : String = "+uid"

static func is_packed_object_ref(obj) -> bool:
  return obj is Dictionary and ref_key in obj


# Get a UID from a packed reference.
static func uid_from_ref(ref: Dictionary):
  return ref.get(ref_key, "")



static func pack(obj : Object) -> Dictionary:
  return {
    ref_key: JSLGObjectHandler.get_savable_uid(obj)
  }


static func unpack(uid_to_object_map, ref) -> Object:
  if not is_packed_object_ref(ref):
    return null
  var obj = uid_to_object_map.get(ref.get(ref_key, null), null)
  if obj == null:
    print("Bad reference: Object " + str(ref) + " not found in save!")
  return obj
