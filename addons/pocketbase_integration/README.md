# Godot PocketBase Integration Plugin

**Status:** Work in Progress 🚧

This plugin provides seamless integration between Godot Engine and PocketBase, allowing you to easily connect your Godot projects to a PocketBase backend.

## Features
- Simple SDK-like API for accessing any PocketBase collection
- Global singleton for all data operations
- User authentication and token management
- Debug mode for API requests and responses
- No need to predefine models—access any collection dynamically


## Example Usage
### Using the new Collection class (Godot 4.x, await syntax)
```gdscript
# Add the Collection node to the scene tree before using
var users = Collection.new("users")
add_child(users)

# Get all records (async/await)
var result = await users.getList()
if result[0]:
    print("Records:", result[1])
else:
    print("Error:", result[1])

# Create a new record
var create_result = await users.create({"name": "John", "email": "john@example.com"})
if create_result[0]:
    print("Created:", create_result[1])

# Update a record
var update_result = await users.update("record_id", {"points": 42})
if update_result[0]:
    print("Updated:", update_result[1])

# Authenticate user (see UserAuth singleton)
UserAuth.AuthWithPassword("user@example.com", "password123")
```

## Setup
1. Install the plugin in your Godot project.
2. Activate it in the Project > Project Settings > Plugins menu.
3. Configure your PocketBase server URL in Project Settings under `pocketbase/base_url`.
4. (Optional) Enable debug logging with `pocketbase/debug_api_requests`.


## Roadmap
- [x] Add support for POST, PATCH, DELETE operations
- [x] Async/await API for collections (Godot 4.x)
- [ ] Improve error handling and documentation
- [ ] More authentication methods
- [ ] Example scenes and demos

---

This plugin is under active development. Contributions, feedback, and issue reports are welcome!
