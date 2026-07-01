# NodeTreeHandler can save a tree of savable nodes.
# It enumerates savable children of a node and saves them as references.

class_name JSLGNodeTreeHandler

const children_key = "+children"


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
  
  return true
