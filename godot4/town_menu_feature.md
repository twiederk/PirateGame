# Town Menu Multi-Goods Feature Implementation Plan

## Current State Analysis

### TradingSystem
- **goods Dictionary**: Contains all available goods with ID as key and GoodResource as value
  ```gdscript
  goods: Dictionary = {
    1: preload("res://trading_system/good_fish.tres"),
    2: preload("res://trading_system/good_grain.tres")
  }
  ```
- **buy()**: Takes `TradingItem` and amount as parameters
- **sell()**: Takes player and town `TradingItem` instances and amount
- **get_price()**: Takes `TradingItem` and returns calculated price

### Player
- **inventory Dictionary**: Stores TradingItem instances by good ID
  ```gdscript
  inventory: Dictionary = {
    1: TradingItem.new(load("res://trading_system/good_fish.tres")),
    2: TradingItem.new(load("res://trading_system/good_grain.tres"))
  }
  ```

### Town
- **inventory Dictionary**: Should store TradingItem instances by good ID (needs initialization)
- Currently uses old `_stock` and `_cached_stock` fields that need migration

### TownMenu (Current)
- Hardcoded to display only one good (fish)
- Static `GoodRow` HBoxContainer in scene
- Outdated button handlers using old API
- No dynamic instantiation

## Implementation Plan

### Phase 1: Town Inventory Initialization

**File**: `world/town.gd`

**Changes**:
1. Initialize `inventory` dictionary in `_ready()` with all goods from TradingSystem
2. Create TradingItem instances for each good
3. Migrate from single `_stock` to per-good inventory system
4. Update `get_stock()` and related methods to work with specific good IDs

**Example**:
```gdscript
func initialize_inventory(trading_system: TradingSystem) -> void:
    for good_id in trading_system.goods:
        var good = trading_system.goods[good_id]
        inventory[good_id] = TradingItem.new(good, town_resource.stock)
```

### Phase 2: Create TradingRow Component

**New Files**:
- `gui/trading_row.gd`
- `gui/trading_row.tscn`

#### trading_row.tscn Structure
```
TradingRow (HBoxContainer)
├── GoodName (Label) - custom_minimum_size: Vector2(100, 0)
├── GoodPrice (Label) - custom_minimum_size: Vector2(50, 0)
├── PlayerAmount (Label) - custom_minimum_size: Vector2(70, 0)
├── TownAmount (Label) - custom_minimum_size: Vector2(70, 0)
├── BuyButton (Button) - text: "Kaufen"
└── SellButton (Button) - text: "Verkaufen"
```

#### trading_row.gd Responsibilities
```gdscript
class_name TradingRow
extends HBoxContainer

signal buy_requested(good_id: int, amount: int)
signal sell_requested(good_id: int, amount: int)

var good_id: int
var _trading_system: TradingSystem
var _player: Player
var _town: Town

@onready var good_name: Label = $GoodName
@onready var good_price: Label = $GoodPrice
@onready var player_amount: Label = $PlayerAmount
@onready var town_amount: Label = $TownAmount
@onready var buy_button: Button = $BuyButton
@onready var sell_button: Button = $SellButton

func init(id: int, trading_system: TradingSystem, player: Player, town: Town) -> void:
    good_id = id
    _trading_system = trading_system
    _player = player
    _town = town
    update_display()

func update_display() -> void:
    var good = _trading_system.goods[good_id]
    var player_item = _player.inventory[good_id]
    var town_item = _town.inventory[good_id]
    
    good_name.text = good.name
    good_price.text = str(_trading_system.get_price(town_item))
    player_amount.text = str(player_item.stock)
    town_amount.text = str(town_item.stock)

func _on_buy_button_pressed() -> void:
    buy_requested.emit(good_id, 1)

func _on_sell_button_pressed() -> void:
    sell_requested.emit(good_id, 1)
```

### Phase 3: Update TownMenu Scene

**File**: `gui/town_menu.tscn`

**Changes**:
1. Remove the static `GoodRow` HBoxContainer and its children
2. Keep the `Heading` HBoxContainer (header row)
3. VBoxContainer will contain:
   - TownName
   - PlayerGold
   - PlayerWeight
   - Heading
   - **(Dynamic TradingRow instances will be added here)**
   - TravelButton

### Phase 4: Update TownMenu Script

**File**: `gui/town_menu.gd`

**Changes**:

1. **Remove old node references**:
   - Remove: `good_name`, `good_price`, `player_amount`, `town_amount`, `buy_button`, `sell_button`

2. **Add new reference**:
   ```gdscript
   @onready var rows_container = $CenterContainer/VBoxContainer
   const TradingRowScene = preload("res://gui/trading_row.tscn")
   ```

3. **Create dynamic row generation**:
   ```gdscript
   func _create_trading_rows() -> void:
       # Clear existing trading rows (keep other UI elements)
       _clear_trading_rows()
       
       # Iterate over all goods in TradingSystem
       for good_id in _trading_system.goods:
           var row = TradingRowScene.instantiate()
           row.init(good_id, _trading_system, _player, _town)
           row.buy_requested.connect(_on_buy_requested)
           row.sell_requested.connect(_on_sell_requested)
           
           # Insert before TravelButton
           var travel_button_index = rows_container.get_child_count() - 1
           rows_container.add_child(row)
           rows_container.move_child(row, travel_button_index)
   ```

4. **Add signal handlers**:
   ```gdscript
   func _on_buy_requested(good_id: int, amount: int) -> void:
       var town_item = _town.inventory[good_id]
       _trading_system.buy(town_item, amount)
       _update_all_rows()
   
   func _on_sell_requested(good_id: int, amount: int) -> void:
       var player_item = _player.inventory[good_id]
       var town_item = _town.inventory[good_id]
       _trading_system.sell(player_item, town_item, amount)
       _update_all_rows()
   ```

5. **Update rows method**:
   ```gdscript
   func _update_all_rows() -> void:
       player_gold.text = "Gold: " + str(_player.gold)
       player_weight.text = "Laderaum: " + str(_player.get_used_capacity()) + " / " + str(_player.cargo_capacity)
       
       for child in rows_container.get_children():
           if child is TradingRow:
               child.update_display()
   ```

6. **Update init method**:
   ```gdscript
   func init(town: Town, player: Player, trading_system: TradingSystem) -> void:
       _town = town
       _player = player
       _trading_system = trading_system
       _create_trading_rows()
       _update_gui()
   ```

7. **Remove old button handlers**:
   - Delete: `_on_buy_fish_button_pressed()`
   - Delete: `_on_sell_fish_button_pressed()`

### Phase 5: Update TradingSystem Market Simulation

**File**: `trading_system/trading_system.gd`

**Changes**:
1. Update `update_market()` to work with town's inventory dictionary instead of single stock
2. Update production/consumption logic to iterate over goods:
   ```gdscript
   func update_market(town: Town) -> void:
       # Update prices for all goods
       for good_id in goods:
           if town.inventory.has(good_id):
               var town_item = town.inventory[good_id]
               if should_update_prices(town):
                   town_item.cached_stock = town_item.stock
       
       # Update stock based on production/consumption
       if town.inventory.has(1):  # Fish
           if "fish" in town.town_resource.produces:
               town.inventory[1].stock += 5
           if "fish" in town.town_resource.consumes:
               town.inventory[1].stock -= 3
           town.inventory[1].stock = max(1, town.inventory[1].stock)
       
       if town.inventory.has(2):  # Grain
           if "grain" in town.town_resource.produces:
               town.inventory[2].stock += 3
           if "grain" in town.town_resource.consumes:
               town.inventory[2].stock -= 2
           town.inventory[2].stock = max(1, town.inventory[2].stock)
       
       if should_update_prices(town):
           town._last_update = current_game_time
   ```

### Phase 6: Main Scene Integration

**File**: `world/main.gd` (or wherever towns are initialized)

**Changes**:
1. Initialize town inventories after TradingSystem is created:
   ```gdscript
   trading_system.init(player, towns)
   
   # Initialize town inventories
   for town in towns:
       town.initialize_inventory(trading_system)
   ```

## Testing Checklist

### Unit Tests (if using GUT)
- [ ] Test TradingRow instantiation and initialization
- [ ] Test TradingRow.update_display() with different values
- [ ] Test signal emission from TradingRow
- [ ] Test TownMenu._create_trading_rows() creates correct number of rows
- [ ] Test buy/sell operations update all rows

### Manual Testing
- [ ] Enter town and verify all goods are displayed
- [ ] Verify prices are calculated correctly for each good
- [ ] Buy fish, verify gold decreases and cargo increases
- [ ] Buy grain, verify gold decreases and cargo increases
- [ ] Sell fish, verify gold increases and cargo decreases
- [ ] Sell grain, verify gold increases and cargo decreases
- [ ] Verify cargo capacity limits work for all goods
- [ ] Verify insufficient gold prevents purchases
- [ ] Verify insufficient stock prevents purchases
- [ ] Leave town and re-enter, verify display updates correctly
- [ ] Wait for price updates, verify all goods update

## Migration Notes

### Breaking Changes
- Town now requires `initialize_inventory()` call after creation
- Old `_on_buy_fish_button_pressed()` and `_on_sell_fish_button_pressed()` handlers removed
- Static GoodRow UI elements removed from scene

### Backward Compatibility
- TradingSystem API remains unchanged (still uses TradingItem)
- Player inventory structure unchanged
- Signal-based architecture maintains loose coupling

## Future Enhancements

1. **Dynamic Good Registration**: Allow adding new goods at runtime
2. **Amount Input**: Add text field or spinner for buying/selling multiple units
3. **Tooltips**: Show good descriptions on hover
4. **Visual Indicators**: 
   - Highlight low stock items
   - Show profit margins
   - Indicate which goods town produces/consumes
5. **Sorting/Filtering**: Allow player to sort by price, name, stock
6. **Trade History**: Track recent transactions
7. **Keyboard Navigation**: Add hotkeys for buy/sell actions

## File Dependency Graph

```
TradingSystem.goods (Dictionary)
    ↓
TownMenu.init()
    ↓
TownMenu._create_trading_rows()
    ↓
For each good_id in TradingSystem.goods:
    - Get Player.inventory[good_id] → TradingItem
    - Get Town.inventory[good_id] → TradingItem
    - Instantiate TradingRow
    - TradingRow.init(good_id, trading_system, player, town)
    - TradingRow.update_display()
        ↓
    Display: good.name, price, player.stock, town.stock
```

## Estimated Implementation Order

1. ✅ Create plan document (this file)
2. 🔲 Create TradingRow scene with UI layout
3. 🔲 Create TradingRow script with display and signal logic
4. 🔲 Update Town.gd to initialize inventory dictionary
5. 🔲 Update TownMenu.tscn to remove static GoodRow
6. 🔲 Update TownMenu.gd to create dynamic rows
7. 🔲 Update TradingSystem.update_market() for multi-good support
8. 🔲 Update main scene initialization
9. 🔲 Test all trading operations
10. 🔲 Polish and optimize

## Notes

- Keep signal-based architecture for loose coupling
- TradingRow is self-contained and reusable
- All goods defined in TradingSystem.goods are automatically supported
- No hardcoded good references in UI code
- Easy to add new goods by adding to TradingSystem.goods dictionary
