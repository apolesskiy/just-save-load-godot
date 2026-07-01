# A packer for JSLGTestPackerNode (a Node that does not implement the trait).
# Register with: JSLG.register_packer(JSLGTestNodePacker, JSLGTestPackerNode.new())
class_name JSLGTestNodePacker

static func save_properties(obj) -> Array:
  return ["int_prop"]
