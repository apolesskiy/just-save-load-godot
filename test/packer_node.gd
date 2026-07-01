# A plain Node that does NOT implement the JSLGSavable trait. It is made savable by
# registering JSLGTestNodePacker as its packer, so it can be saved as a savable child.
class_name JSLGTestPackerNode extends Node

var int_prop = 0
