# The reference collector traverses the reference graph to determine which objects to save.
class_name JSLGReferenceCollector

# Add a reference to save to the UID map.
# Non-savable references and references that already exist in the map are ignored.
static func __collect_one_reference(collected_objects, obj):
  if not JSLGObjectHandler.is_savable(obj):
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
    if JSLGObjectHandler.is_savable(elem):
      to_collect.append(elem)
    elif elem is Array:
      to_collect.append_array(__collect_array(collected_objects, elem))
    elif elem is Dictionary:
      to_collect.append_array(__collect_dictionary(collected_objects, elem))

  return to_collect


static func __collect_dictionary(collected_objects, dict : Dictionary):
  return __collect_array(collected_objects, dict.keys()) + __collect_array(collected_objects, dict.values())
  

static func collect_references(obj : Object) -> Dictionary:
  # Note: collect is different from save/load in that it is implemented iteratively.
  # We expect reference chains to be arbitrarily long/cyclic, while nested dicts/arrays
  # will be shallow enough to be handled recursively.
  # For example, it is unlikely to see array[array[...until overflow...]].

  if not JSLGObjectHandler.is_savable(obj):
    return {}
  var collected_objects = {}
  var collect_queue = [obj]
  # Use the engine's built-in ID because why not, it's guaranteed unique in context.
  while collect_queue.size() > 0:
    var next_obj = collect_queue.pop_front()
    __collect_one_reference(collected_objects, next_obj)
    var props = JSLGObjectHandler.get_savable_properties(next_obj)
    for prop in props:
      var prop_val = next_obj.get(prop)

      # Handle savable objects, arrays, and dicts. Everything else can't be a ref so is not relevant.
      if JSLGObjectHandler.is_savable(prop_val):
        collect_queue.append(prop_val)
      elif prop_val is Array:
       collect_queue.append_array(__collect_array(collected_objects, prop_val))
      elif prop_val is Dictionary:
        collect_queue.append_array(__collect_dictionary(collected_objects, prop_val))

  return collected_objects
