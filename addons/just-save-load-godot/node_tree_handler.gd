# NodeTreeHandler can save a tree of savable nodes.
# It enumerates savable children of a node and saves them as references.
# A savable Node can declare the model_scene property. If set, the model scene will be 
# instantiated on load and its non-savable children will be reparented to the loaded node.
# The temporarily instantiated model scene root and savable nodes will be discarded.
# Savable children will load as normal. Note the savability test applies only to *children*, not *descendants*.
# The intended use case is to achieve parity with PackedScene.instantiate() - A scene with a savable root can be
# authored, set as the model scene, saved, and loaded, even if it contains non-savable (static) data.
class_name JSLGNodeTreeHandler

const children_key = "+children"

const model_scene_property = "model_scene"


# Get the model scene for a node, if present.
static func get_model_scene(node : Node) -> PackedScene:
  if model_scene_property not in node:
    return null
  var scene = node.get(model_scene_property)
  if scene is PackedScene:
    return scene
  return null


# Get savable children of a node. Used both for reference collection and for saving.
static func get_savable_children(node : Node) -> Array:
  var savable_children = []
  for child in node.get_children():
    if JSLGObjectHandler.is_savable(child):
      savable_children.append(child)
  return savable_children


# Pack the savable children as references. This is merged into the node's saved data
# by ObjectHandler.
static func pack(collected_objects, node : Node) -> Dictionary:
  var children = get_savable_children(node)
  return {
    children_key: JSLGArray.pack(collected_objects, children)
  }


static func unpack(objects_out, object_data, uid) -> bool:
  var obj = objects_out[uid]
  if obj == null:
    push_error("Save corrupt: no object with UID " + uid + " found to unpack")
    return false
  if not obj is Node:
    # Not a node - it cannot have savable children, so there is nothing to re-parent.
    return true
  var node = obj as Node
  var node_data = object_data[uid]

  if not node_data.has(children_key):
    # No-op - node has no savable children.
    return true

  var children_data = node_data[children_key]

  # Fetch loaded children.
  var children = JSLGArray.unpack(objects_out, children_data)
  if children == null:
    push_error("Failed to load savable children for node " + uid)
    return false

  for child in children:
    if not child is Node:
      push_error("Failed to load savable child of node " + uid + ": child is not a Node!")
      return false
    node.add_child(child)

  # Unpack model scene if defined
  var model_scene = get_model_scene(node)
  if model_scene != null:
    __unpack_model_scene(node, model_scene)
  
  return true


static func __unpack_model_scene(node : Node, scene : PackedScene):
  var temp_root = scene.instantiate()
  for child in temp_root.get_children():
    if not JSLGObjectHandler.is_savable(child):
      child.set_owner(null)
      child.reparent(node)
  
  # Delete the temp node or it stays in memory forever.
  temp_root.queue_free()