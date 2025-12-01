class_name JSLGResourceUID

# Marker for resource UID references.
const ruid_key : String = "+res"

static func is_exported_resource(obj) -> bool:
  return obj is Resource \
    and obj.resource_path != "" \
    and ResourceLoader.get_resource_uid(obj.resource_path) != ResourceUID.INVALID_ID


static func make_exported_resource(prop) -> Dictionary:
  if not is_exported_resource(prop):
    return {}
  return {ruid_key: ResourceUID.id_to_text(ResourceLoader.get_resource_uid(prop.resource_path))}


static func get_exported_resource(obj):
  if not obj is Dictionary:
    return null
  if ruid_key not in obj:
    return null
  var ruid = ResourceUID.text_to_id(obj[ruid_key])
  var res = ResourceLoader.load(ResourceUID.get_id_path(ruid))
  if res == null:
    print("Warning: failed to load exported resource with UID " + ruid)
  return res
