# Trading Game Prototype (4 Cities)

## 🧱 1. Data Structures

### Good
```json
Good {
    id: string
    basePrice: float
}
```

### MarketItem
```json
MarketItem {
    goodId: string
    supply: float
    demand: float
    stock: float
}
```

### City
```json
City {
    id: string
    name: string
    position: (x, y)

    produces: [goodId]
    consumes: [goodId]

    market: [MarketItem]
}
```

### Player
```json
Player {
    gold: float
    cargoCapacity: float
    inventory: [
        { goodId: string, amount: float }
    ]
    currentCityId: string
}
```

---

## 🔹 Example Setup (4 Cities)

### Goods
- Grain (basePrice: 10)
- Iron (basePrice: 20)
- Wood (basePrice: 15)
- Fish (basePrice: 12)

### Cities

**CoastTown**  
produces: Fish  
consumes: Grain, Wood

**MountainTown**  
produces: Iron  
consumes: Grain

**ForestTown**  
produces: Wood  
consumes: Iron

**FarmTown**  
produces: Grain  
consumes: Fish

---

## 💰 2. Price Calculation Model

### Formula
```text
Price = basePrice × (1 + k × (demand - supply) / max(1, stock))
```

Recommended:
```text
k = 0.5
```

### Clamping
```text
Price = clamp(Price, basePrice * 0.5, basePrice * 3)
```

---

## 🔁 Market Update (per tick)

```pseudo
for each marketItem:
    if good in produces:
        stock += random(5, 10)

    if good in consumes:
        stock -= random(3, 8)

    stock = max(stock, 1)

    demand = targetDemand - stock
    supply = stock
```

---

## 🚚 3. Gameplay Loop

### High Level

```text
[1] Player in city
     ↓
[2] Analyze market
     ↓
[3] Buy goods
     ↓
[4] Travel (land/sea)
     ↓
[5] Events (optional)
     ↓
[6] Arrive at destination
     ↓
[7] Sell goods
     ↓
[8] Profit
     ↓
[9] Upgrade / plan next route
     ↓
→ repeat
```

---

### Technical Loop

```pseudo
while gameRunning:

    currentCity = player.currentCity

    displayMarket(currentCity)

    playerAction = choose:
        - buy goods
        - travel
        - wait

    if buy:
        updatePlayerInventory()
        decreaseCityStock()

    if travel:
        targetCity = chooseDestination()

        travelTime = distance / speed
        wait(travelTime)

        triggerRandomEvents()

        player.currentCity = targetCity

    if sell:
        calculatePrice()
        increasePlayerGold()
        increaseCityStock()
```

---

## 🧭 Example Gameplay

1. Start in CoastTown
2. Fish is cheap → buy fish
3. Travel to FarmTown
4. Sell fish for profit
5. Buy grain
6. Travel and repeat trade loop

---

## ⚖️ Balancing Tips

✅ Different starting stock levels  
✅ Randomized production  
✅ Noticeable travel time  

❌ Avoid static prices  
❌ Avoid single optimal route

---

## 🚀 Minimal Playable Version

- 4 cities
- 4 goods
- Fixed travel times
- Price formula implemented
- Market updates every few seconds

→ Fully playable trading prototype
