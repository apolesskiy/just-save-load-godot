# Just Save and Load, Please!

Godot makes it a bit hard to save and load game state. There are many tutorials out there on how to do it, but no obvious, standardized means. This is not surprising,. Deciding what data to save (or not) is individual to each game, and restoring a highly interlinked game state is also not trivial.

This plugin is another layer of duct tape to this problem. It provides a modular, (relatively) simple way to save and load arbitrary objects.

## Features

* Save and load arbitrary Godot objects, including Node trees.
* Full control: explicitly declare what properties you want saved.
* Register stand-alone packers for classes that don't implement the interface (like 3p plugins).
* Automatically load mixed savable/static scenes.
* Explicit allowlist on loadable built-in types and no autoloading scripts - solves PackedScene distribution ACE.

### This is useful if...
* You want to save a custom class without making it a Resource.
* You want to save portions of the scene tree. It is still *highly* recommended to separate your data/models from your views.
* You plan on people sharing the data you are saving.

### This is not useful if...
* You're trying to store other data like textures, etc in your save file. You can still use the plugin to store object data, but you probably want store resource-shaped things alongside in a zip file and load it separately.
* You're trying to outright replace Resources. Godot does some very smart things with resources that this plugin does not do. Resources are still recommended for assets to be packed with the game.

## Usage

JSLG exposes a small static API:

* `JSLG.save(object) -> String` — serialize an object, and everything it references, to a JSON string.
* `JSLG.load(string) -> Object` — rebuild the object graph and return the root object.
* `JSLG.register_packer(packer, example)` — register a packer for a class (see [Packer Trait](#packer-trait)).

### Quick Start

Make a class savable by giving it a `class_name` and a `save_properties()` method that lists the properties to persist:

```gdscript
class_name PlayerData extends Resource

var display_name := "Hero"
var health := 100
var inventory := []

# Required: return the names of the properties to save.
func save_properties() -> Array:
    return ["display_name", "health", "inventory"]
```

Then save and load through the `JSLG` static class:

```gdscript
var player := PlayerData.new()
player.health = 42

# save() returns a JSON string you can store anywhere.
var data := JSLG.save(player)
FileAccess.open("user://save.json", FileAccess.WRITE).store_string(data)

# load() rebuilds the object from that string.
var text := FileAccess.open("user://save.json", FileAccess.READ).get_as_text()
var loaded: PlayerData = JSLG.load(text)
print(loaded.health) # 42
```

Only the properties you list are saved. They may be built-in types, arrays/dictionaries, other savable objects (stored as references), or resources. Resources either need to be savable themselves, or be loaded from a `res://` file (have a resource path, stored by UID).

### Savable Trait

An object is *savable* when it meets two requirements:

1. Its script declares a `class_name` (it must be a registered global class).
2. It implements `save_properties() -> Array`, returning the names of the properties to save.

It may also implement these optional lifecycle hooks:

* `pre_save()` — called on the object just before it is serialized.
* `post_load()` — called after the object *and everything it references* have been loaded. Use it to rebuild transient state.

```gdscript
class_name Enemy extends Node2d

var hp := 10
var _sprite: Sprite2D # transient - not listed in save_properties()

func save_properties() -> Array:
    return ["transform", "hp"]

func pre_save() -> void:
    # Runs before serialization.
    pass

func post_load() -> void:
    # Runs once all objects are loaded and references resolved.
    _sprite = $Sprite2D
```

References between savable objects — including reference cycles — are preserved. A savable resource loaded from `res://` is stored as a UID reference; a resource you create at runtime is stored as an object.

**C#** is supported with PascalCase method names: `SaveProperties()`, `PreSave()`, `PostLoad()`. Mark the class `[GlobalClass]`.

```csharp
[GlobalClass]
public partial class Enemy : Node
{
    public int Hp { get; set; } = 10;

    public Godot.Collections.Array<string> SaveProperties()
        => new() { nameof(Hp) };

    public void PostLoad() { /* rebuild transient state */ }
}
```

### Packer Trait

Use a *packer* to save a class that does not implement the savable trait itself — for example a third-party class you cannot modify. A packer is a separate class that describes how to save the target class using **static** methods that receive the object being saved:

```gdscript
# ThirdPartyThing has a class_name and data we want to persist, but does not
# implement save_properties() itself. The packer describes how to save it:
class_name ThirdPartyThingPacker

# Required: static, takes the object being saved.
static func save_properties(obj) -> Array:
    return ["some_value", "another_value"]

# Optional lifecycle hooks - also static, and taking the object:
static func pre_save(obj) -> void:
    pass

static func post_load(obj) -> void:
    pass
```

Register the packer once before saving or loading — for example in an autoload's `_ready()`. Pass an example instance so JSLG can identify the target class:

```gdscript
JSLG.register_packer(ThirdPartyThingPacker, ThirdPartyThing.new())
```

An instance (`.new()`) is required because Godot objects actually have two types: an engine class (like Node2D, Resource, etc), and a Script class (the class_name defined in its Script). These are not related, and both need to be known to instantiate the object and initialize its script.

Notes:

* The target class must still be a global class (`class_name`) so it can be re-instantiated on load.
* If a class implements the savable trait itself, that is used and any registered packer is ignored.
* Packers work for C# too, using the static PascalCase methods `SaveProperties`/`PreSave`/`PostLoad`.

### Nodes

A savable Node automatically saves its savable children. References to savable children in the Node's properties are also preserved. On load, those children are re-created and re-parented under the node. Children that are not savable are skipped.

```gdscript
class_name Room extends Node

var room_name := ""

func save_properties() -> Array:
    return ["room_name"]

# Savable child nodes (e.g. the Enemy above) are saved and restored
# automatically. Non-savable children (decorations, effects, ...) are ignored.
```

#### Static content with `model_scene`

Scenes often mix dynamic, savable data with static content: meshes, collision shapes, decorations. Declare a `model_scene: PackedScene` property pointing to a full scene contianing both. This is typically the scene you use to instantiate the object itself (like a Room scene with Enemies, a NavigationRegion2D, and so on). You can either hardcode the scene (`var model_scene : PackedScene = "uid://1234"` or add it to `save_properties`, where it will be saved by UID). On load, JSLG instantiates the model scene and re-parents its non-savable (static) children onto the loaded node, restoring the static content from the scene instead of the save file.

```gdscript
class_name Room extends Node

@export var model_scene: PackedScene
var room_name := ""

func save_properties() -> Array:
    # Since it's not hardcoded, model_scene must be saved so it is available when children are restored.
    return ["room_name", "model_scene"]
```

When the node loads:

* Savable children are restored from the save file (with their saved state).
* Non-savable ("static") children come from a fresh instance of `model_scene`.
* The model scene's own root and its savable children are discarded.

The end result is that the same scene can be used for `PackedScene.instantiate()` and as `model_scene`.

Note: Only savable **children** are discarded. Savable **descendants** (e.g. a savable grandchild of a non-savable child) will be instantiated as if it was static data!

## Setup

### GodotEnv (Recommended)
It is highly recommended to use [GodotEnv](https://github.com/chickensoft-games/GodotEnv) to manage your project's addons.

* Add the following to `addons.jsonc`:
```
"just-save-load-godot": {
      "url": "git@github.com:apolesskiy/just-save-load-godot",
      "subfolder": "addons/just-save-load-godot"
}
```

### Manual
* Copy `addons/just-save-load-godot` to your addons folder.

## How It Works

### Built-in Types
Built-ins are saved using str_to_var/var_to_str. However, the type of the builtin is checked against known permitted types before deserialization.

### Objects
JSLG traverses an object's property tree, finds any other savable objects, and adds them to an object catalog. For Nodes, it also traverses children. Then, the loader goes through the catalog, saving all of the objects' properties and replacing references to other objects with reference markers. The output of this operation is a dictionary that is serialized to JSON.

Loading is done in three phases: parses the object catalog from the dictionary, and instantiates empty copies of each object. It then initializes all savable properties, replacing object reference markers with objects from the catalog. It then returns the root object that was passed into the save() method.

### Resources
Resources packaged with the game are saved as their UID. On load, the property value is set to the resource reference in ResourceLoader. This is true even for resources that are savable - that is, a savable resource loaded from a path is saved by UID, but a savable resource created dynamically (or with Resource.duplicate()) will be saved as an object.

### Arrays and Dictionaries
Arrays and dictionaries are both stored as JSON arrays to support Godot's arbitrary dictionary types. Values within a dictionary/array are stored like any other property.

## Lifecycle

Save:
1. Collect objects to save.
2. Run pre_save() on all objects.
3. Pack and serialize.

Load:
1. Deserialize JSON.
2. Instantiate all objects to load. Each object's `init()` is run with no args. 
3. Unpack each object's properties, resolving references with instances from step 2.
4. Reparent Node children and instantiate model_scenes.
5. Run post_load() on all objects.

## Why not...

### Resources?
"Resources considered harmful" for data that changes often or is exposed to players.
* Loading resources from outside of res:// is a known ACE vector (https://github.com/godotengine/godot-proposals/issues/4925).
* Renaming variables in resource scripts causes data loss that is difficult to recover from (https://github.com/godotengine/godot-proposals/issues/3152).
* Resources do not support reference loops (https://github.com/godotengine/godot-proposals/issues/2657).

### ConfigFile?
* It has the same ACE issue as resources. The underlying issue is that str_to_var can load any object, which includes `script` or objects containing `script`. JSON lets you disallow objects during deserialization.

### Plain JSON?
* Doesn't give control over what to save and what not to save.
* Doesn't save objects unless you turn it on explicitly, at which point it is exposed to the same ACE as everything else.