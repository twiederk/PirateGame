# Test-Driven Development (TDD) with GDScript and GUT

## Overview

This guide covers implementing Test-Driven Development (TDD) using **GDScript** as the programming language and **GUT** (Godot Unit Test) as the testing framework.

## Tech Stack

### Core Dependencies

| Tool | Version | Purpose |
|------|---------|---------|
| **Godot** | 4.x | Game engine with built-in GDScript support |
| **GDScript** | 2.0+ | Godot's native scripting language |
| **GUT** | 9.x | Unit testing framework for Godot |

### Installing GUT

GUT can be installed from the Godot Asset Library or manually:

1. **Via Asset Library** (Recommended):
   - Open Godot Editor
   - Go to AssetLib tab
   - Search for "GUT"
   - Download and install

2. **Manual Installation**:
   - Download from [GitHub](https://github.com/bitwes/Gut)
   - Extract to `addons/gut/` in your project

3. **Enable the Plugin**:
   - Project → Project Settings → Plugins
   - Enable "Gut" plugin

## Project Structure

```
godot_project/
├── project.godot
├── addons/
│   └── gut/
│       └── [GUT plugin files]
├── src/
│   ├── counter.gd
│   ├── player.gd
│   └── [Your game scripts]
└── test/
    ├── test_counter.gd
    ├── test_player.gd
    └── [Your test scripts]
```

## TDD Workflow

### 1. Red Phase (Write Failing Test)
```gdscript
extends GutTest

func test_increment_counter():
    # arrange
    var counter = Counter.new()
    
    # act
    counter.increment()
    
    # assert
    assert_eq(counter.get_count(), 1, "Counter should be 1 after increment")
```

### 2. Green Phase (Write Minimal Code)
```gdscript
extends Node
class_name Counter

var count: int = 0

func increment() -> void:
    count += 1

func get_count() -> int:
    return count
```

### 3. Refactor Phase
- Improve code quality
- Optimize performance
- Maintain test coverage

## GUT Test Lifecycle

### Test Methods and Hooks

| Method | Purpose |
|--------|---------|
| `test_*()` | Test methods must start with `test_` prefix |
| `before_each()` | Runs before each test (setup) |
| `after_each()` | Runs after each test (teardown) |
| `before_all()` | Runs once before all tests |
| `after_all()` | Runs once after all tests |

### Example Test Setup

```gdscript
extends GutTest

var counter: Counter

func before_each():
    counter = Counter.new()

func after_each():
    counter.free()

func test_initialize_counter_with_zero():
    # arrange - counter already created in before_each
    
    # act
    var result = counter.get_count()
    
    # assert
    assert_eq(result, 0, "Counter should initialize at zero")
```

## GUT Assertions

### Common Assertions

#### Equality
```gdscript
assert_eq(actual, expected, "Optional message")
assert_ne(actual, unexpected, "Optional message")
```

#### Boolean Checks
```gdscript
assert_true(condition, "Optional message")
assert_false(condition, "Optional message")
```

#### Null Checks
```gdscript
assert_null(value, "Optional message")
assert_not_null(value, "Optional message")
```

#### Numeric Comparisons
```gdscript
assert_gt(actual, threshold, "actual should be greater than threshold")
assert_lt(actual, threshold, "actual should be less than threshold")
assert_between(actual, lower, upper, "actual should be between bounds")
```

#### Approximate Equality (for floats)
```gdscript
assert_almost_eq(actual, expected, delta, "Optional message")
assert_almost_ne(actual, unexpected, delta, "Optional message")
```

#### String Checks
```gdscript
assert_string_contains(text, substring, "Optional message")
assert_string_starts_with(text, prefix, "Optional message")
assert_string_ends_with(text, suffix, "Optional message")
```

#### Collections
```gdscript
assert_has(array, element, "Optional message")
assert_does_not_have(array, element, "Optional message")
```

#### Type Checks
```gdscript
assert_is(instance, ClassType, "Optional message")
```

#### Signals
```gdscript
watch_signals(object)
assert_signal_emitted(object, "signal_name")
assert_signal_not_emitted(object, "signal_name")
assert_signal_emit_count(object, "signal_name", count)
```

## Example Test Class

```gdscript
extends GutTest

var counter: Counter

func before_each():
    counter = Counter.new()

func after_each():
    counter.free()

func test_initialize_counter_with_zero():
    # arrange - counter created in before_each
    
    # act
    var result = counter.get_count()
    
    # assert
    assert_eq(result, 0, "Counter should start at zero")

func test_increment_counter():
    # arrange - counter created in before_each
    
    # act
    counter.increment()
    
    # assert
    assert_eq(counter.get_count(), 1, "Counter should be 1 after increment")

func test_increment_counter_multiple_times():
    # arrange - counter created in before_each
    
    # act
    counter.increment()
    counter.increment()
    counter.increment()
    
    # assert
    assert_eq(counter.get_count(), 3, "Counter should be 3 after three increments")

func test_reset_counter():
    # arrange
    counter.increment()
    counter.increment()
    
    # act
    counter.reset()
    
    # assert
    assert_eq(counter.get_count(), 0, "Counter should be 0 after reset")
```

## Example Implementation

```gdscript
extends Node
class_name Counter

var count: int = 0

func increment() -> void:
    count += 1

func reset() -> void:
    count = 0

func get_count() -> int:
    return count
```

## GUT Configuration

### Creating a Test Runner Scene

1. Create a new scene with a Control node as root
2. Add a GutPanel node (from addons/gut)
3. Configure the panel:
   - **Test Directory**: `test/`
   - **Test Prefix**: `test_`
   - **File Extension**: `.gd`

### .gutconfig.json

Create a configuration file in your project root:

```json
{
  "dirs": ["res://test/"],
  "prefix": "test_",
  "suffix": ".gd",
  "should_maximize": false,
  "compact_mode": false,
  "log_level": 1,
  "ignore_pause": true,
  "hide_orphans": false
}
```

## Running Tests

### Via Godot Editor
1. Open the GUT panel scene
2. Click "Run All" or select specific tests
3. View results in the panel

### Via Command Line
```bash
# Run all tests
godot --path . --headless --script addons/gut/gut_cmdln.gd

# Run specific test directory
godot --path . --headless --script addons/gut/gut_cmdln.gd -gdir=test/

# Run specific test file
godot --path . --headless --script addons/gut/gut_cmdln.gd -gdir=test/ -gtest=test_counter.gd

# Exit after tests complete
godot --path . --headless --script addons/gut/gut_cmdln.gd -gexit
```

### Continuous Integration
```yaml
# Example GitHub Actions workflow
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: chickensoft-games/setup-godot@v1
        with:
          version: 4.2.0
      - name: Run tests
        run: godot --path . --headless --script addons/gut/gut_cmdln.gd -gexit
```

## Best Practices

### 1. Test Naming
- Prefix all test methods with `test_`
- Use descriptive names: `test_<feature>_<scenario>`

```gdscript
func test_player_takes_damage_when_hit():
    pass

func test_player_dies_when_health_reaches_zero():
    pass
```

### 2. Arrange-Act-Assert Pattern
```gdscript
func test_player_movement():
    # arrange - setup test data
    var player = Player.new()
    var initial_position = player.position
    
    # act - execute the code under test
    player.move(Vector2(10, 0))
    
    # assert - verify the result
    assert_eq(player.position.x, initial_position.x + 10, "Player should move right")
```

### 3. One Assertion Focus
- Each test should focus on one behavior
- Use multiple related assertions when testing compound state

```gdscript
func test_player_initialization():
    # arrange - player created in before_each or here
    var player = Player.new()
    
    # act - none needed for initialization test
    
    # assert
    assert_eq(player.health, 100, "Player should start with 100 health")
    assert_eq(player.speed, 200, "Player should have speed of 200")
    assert_true(player.is_alive(), "Player should be alive initially")
```

### 4. DRY Principle
- Use `before_each()` for common setup
- Create test fixtures and helper methods

```gdscript
var player: Player

func before_each():
    player = Player.new()

func after_each():
    player.free()
```

### 5. Test Organization
- Group related tests in separate files
- Use descriptive file names

```
test/
├── test_player_movement.gd
├── test_player_combat.gd
├── test_inventory_system.gd
└── test_quest_manager.gd
```

### 6. Memory Management
- Always free objects in `after_each()` or when done
- Use `autofree()` for automatic cleanup

```gdscript
func test_with_autofree():
    # arrange
    var node = autofree(Node.new())
    
    # act & assert
    # node will be freed automatically after test
```

## Testing Godot-Specific Features

### Testing Signals

```gdscript
func test_player_emits_damage_signal():
    # arrange
    var player = autofree(Player.new())
    watch_signals(player)
    
    # act
    player.take_damage(10)
    
    # assert
    assert_signal_emitted(player, "health_changed")
    assert_signal_emit_count(player, "health_changed", 1)
```

### Testing Scenes

```gdscript
func test_scene_initialization():
    # arrange
    var scene = load("res://src/player.tscn").instantiate()
    add_child_autofree(scene)
    
    # act - none needed for initialization
    
    # assert
    assert_not_null(scene.get_node("Sprite2D"), "Scene should have Sprite2D")
    assert_eq(scene.health, 100, "Scene should initialize with correct health")
```

### Testing Input

```gdscript
func test_player_responds_to_input():
    # arrange
    var player = autofree(Player.new())
    var input_event = InputEventKey.new()
    input_event.keycode = KEY_RIGHT
    input_event.pressed = true
    
    # act
    player._input(input_event)
    
    # assert
    assert_true(player.is_moving_right, "Player should move right on right key")
```

### Testing with Doubles (Mocks/Stubs)

```gdscript
func test_with_double():
    # arrange
    var double = double(Player).new()
    stub(double, "get_health").to_return(50)
    
    # act
    var result = double.get_health()
    
    # assert
    assert_eq(result, 50, "Double should return stubbed value")
```

### Testing Async Code

```gdscript
func test_async_operation():
    # arrange
    var obj = autofree(MyAsyncObject.new())
    watch_signals(obj)
    
    # act
    obj.start_async_operation()
    await wait_for_signal(obj.operation_complete, 5.0)
    
    # assert
    assert_signal_emitted(obj, "operation_complete")
```

## Parameterized Tests

```gdscript
func test_damage_calculations():
    # arrange
    var test_cases = [
        {"damage": 10, "armor": 5, "expected": 5},
        {"damage": 20, "armor": 10, "expected": 10},
        {"damage": 100, "armor": 0, "expected": 100},
    ]
    
    # act & assert
    for case in test_cases:
        var result = calculate_damage(case.damage, case.armor)
        assert_eq(result, case.expected, 
            "Damage %d with armor %d should result in %d" % [case.damage, case.armor, case.expected])
```

## Debugging Tests

### Enable Detailed Output
```gdscript
# In your test file
func before_all():
    gut.log_level = gut.LOG_LEVEL_ALL_ASSERTS
```

### Print Debugging
```gdscript
func test_with_debug_output():
    # arrange
    var value = calculate_something()
    print("Calculated value: ", value)
    
    # act & assert
    assert_eq(value, expected)
```

### Using the Debugger
- Set breakpoints in test code
- Run tests from editor (not headless mode)
- Step through execution

## Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| Tests not found | Ensure test files start with `test_` prefix and extend `GutTest` |
| "Cannot call method on null" | Check object initialization in `before_each()` |
| Memory leaks | Use `autofree()` or manually free objects in `after_each()` |
| Signal not detected | Ensure `watch_signals()` is called before emitting |
| Scene loading fails | Use full `res://` path when loading scenes |

## GUT Command Line Options

```bash
# Commonly used options
-gdir=<path>          # Set test directory
-gtest=<filename>     # Run specific test file
-gexit                # Exit after tests complete
-glog=<level>         # Set log level (0-3)
-gcompact             # Use compact output mode
-gignore_pause        # Ignore pause before quit
```

## Integration with IDE

### VS Code
- Install "godot-tools" extension
- Configure tasks.json for running tests:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Run GUT Tests",
      "type": "shell",
      "command": "godot",
      "args": [
        "--path",
        ".",
        "--headless",
        "--script",
        "addons/gut/gut_cmdln.gd",
        "-gexit"
      ],
      "group": "test"
    }
  ]
}
```

## Additional Resources

- [GUT GitHub Repository](https://github.com/bitwes/Gut)
- [GUT Documentation](https://github.com/bitwes/Gut/wiki)
- [GDScript Official Documentation](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html)
- [Godot Unit Testing Best Practices](https://godotengine.org/article/testing-godot)

## Summary

TDD with GDScript and GUT provides:

✅ **Native Integration**: GUT works seamlessly with Godot Engine
✅ **Rich Assertions**: Comprehensive assertion methods for all needs
✅ **Signal Testing**: Built-in support for testing Godot signals
✅ **Scene Testing**: Easy testing of instantiated scenes
✅ **Memory Management**: Tools like `autofree()` prevent leaks
✅ **CI/CD Ready**: Command-line support for automated testing
✅ **Mocking/Doubling**: Built-in support for test doubles

This tech stack is ideal for building maintainable, well-tested games with Godot Engine.
