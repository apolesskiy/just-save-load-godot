using System;
using Godot;

[GlobalClass]
public partial class JSLGTestObjectCSharp : Resource
{

    [Export]
    public Godot.Collections.Dictionary DictProp { get; set; } = new Godot.Collections.Dictionary();

    [Export]
    public Godot.Collections.Array ArrayProp { get; set; } = new Godot.Collections.Array();

    [Export]
    public Godot.Collections.Array<int> TypedArrayProp { get; set; } = new Godot.Collections.Array<int>();

    [Export]
    public Godot.Collections.Dictionary<string, int> TypedDictProp { get; set; } = new Godot.Collections.Dictionary<string, int>();

    [Export]
    public int IntProp { get; set; } = 0;

    [Export]
    public String StringProp { get; set; } = string.Empty;

    [Export]
    public Vector2 Vector2Prop { get; set; } = new Vector2();

    [Export]
    public Vector2I Vector2iProp { get; set; } = new Vector2I();

    [Export]
    public Resource ExportedResourceRef { get; set; }

    public bool WasLoaded { get; set; } = false;

    public Godot.Collections.Array<string> SaveProperties()
    {
        return new Godot.Collections.Array<string>
        {
            nameof(DictProp),
            nameof(ArrayProp),
            nameof(TypedArrayProp),
            nameof(TypedDictProp),
            nameof(IntProp),
            nameof(StringProp),
            nameof(Vector2Prop),
            nameof(Vector2iProp),
            nameof(ExportedResourceRef)
        };
    }

    public void OnLoadComplete()
    {
        WasLoaded = true;
    }
}