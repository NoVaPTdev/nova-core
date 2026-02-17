# NOVA Framework - Core

A modern, optimized framework for FiveM RP servers.

Built with a focus on **performance**, **security** (server-side validations), **modularity**, and **ease of use**.

---

## Table of Contents

- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Exports - Server](#exports---server)
- [Exports - Client](#exports---client)
- [Events](#events)
- [Callbacks](#callbacks)
- [Player Object (Server)](#player-object-server)
- [Shared Utilities](#shared-utilities)
- [Systems](#systems)
- [Needs (Hunger/Thirst)](#needs-hungerthirst)
- [Weather/Time Sync](#weathertime-sync)
- [World Control](#world-control)
- [Vehicle Keys](#vehicle-keys)
- [Permissions](#permissions)
- [Jobs & Gangs](#jobs--gangs)
- [Creating a Script with NOVA](#creating-a-script-with-nova)
- [Localization](#localization)
- [Database Schema](#database-schema)

---

## Quick Start

### Requirements

- FiveM Server (latest recommended)
- [oxmysql](https://github.com/overextended/oxmysql)
- MySQL/MariaDB

### Installation

1. Place `nova_core` inside your `resources/[nova]/` folder.
2. Import the SQL schema: `nova_core/sql/nova.sql`
3. Add to your `server.cfg`:

```cfg
ensure oxmysql
ensure nova_core
```

4. Configure `config/main.lua` to your liking.

### Accessing the Framework

**Server-side:**

```lua
-- Method 1: Full object access
local Nova = exports['nova_core']:GetObject()

-- Method 2: Direct export calls (recommended for simple operations)
local player = exports['nova_core']:GetPlayer(source)
exports['nova_core']:AddPlayerMoney(source, 'bank', 5000)
```

**Client-side:**

```lua
-- Method 1: Full object access
local Nova = exports['nova_core']:GetObject()

-- Method 2: Direct export calls
local playerData = exports['nova_core']:GetPlayerData()
local isLoaded = exports['nova_core']:IsPlayerLoaded()
```

---

## Configuration

All configuration is in `config/main.lua`. Key settings:

| Setting | Description | Default |
|---------|-------------|---------|
| `NovaConfig.ServerName` | Server display name | `'NOVA RP'` |
| `NovaConfig.Debug` | Enable debug logging | `false` |
| `NovaConfig.Locale` | Language (`'pt'` or `'en'`) | `'pt'` |
| `NovaConfig.IdentifierType` | Player ID type | `'license'` |
| `NovaConfig.MaxCharacters` | Max characters per player | `3` |
| `NovaConfig.DefaultSpawn` | Default spawn coordinates | Legion Square |
| `NovaConfig.MoneyTypes` | Money types with defaults | cash, bank, black_money |
| `NovaConfig.Needs.enabled` | Enable hunger/thirst | `true` |
| `NovaConfig.Weather.enabled` | Enable weather sync | `true` |
| `NovaConfig.AutoSave.interval` | Auto-save interval (ms) | `300000` (5 min) |

---

## Exports - Server

All server exports use Auth Gating for security. They are safe to call from any resource.

### Player Management

| Export | Parameters | Returns | Description |
|--------|-----------|---------|-------------|
| `GetPlayer(source)` | `source: number` | `Player\|nil` | Get player object by server ID |
| `GetPlayerByCitizenId(citizenId)` | `citizenId: string` | `Player\|nil` | Get player by CitizenID |
| `GetPlayers()` | — | `table[]` | Get all loaded players |
| `IsPlayerLoaded(source)` | `source: number` | `boolean` | Check if player is loaded |
| `LoginPlayer(source, userData, charData)` | `source, userData, charData` | `table\|nil` | Manually login a player |
| `LogoutPlayer(source)` | `source: number` | — | Logout a player |

### Economy

| Export | Parameters | Returns | Description |
|--------|-----------|---------|-------------|
| `AddPlayerMoney(source, type, amount)` | `source: number, type: string, amount: number` | `boolean` | Add money to player |
| `RemovePlayerMoney(source, type, amount, silent?)` | `source: number, type: string, amount: number, silent?: boolean` | `boolean` | Remove money from player |

**Money types:** `'cash'`, `'bank'`, `'black_money'`

### Metadata

| Export | Parameters | Returns | Description |
|--------|-----------|---------|-------------|
| `SetPlayerMetadata(source, key, value)` | `source: number, key: string, value: any` | `boolean` | Set player metadata |

### Permissions

| Export | Parameters | Returns | Description |
|--------|-----------|---------|-------------|
| `HasPermission(source, group)` | `source: number, group: string` | `boolean` | Check if player has permission group |
| `HasPermissionNode(source, perm)` | `source: number, perm: string` | `boolean` | Check specific permission node |
| `IsAdmin(source)` | `source: number` | `boolean` | Check if player is admin |

### Jobs & Gangs

| Export | Parameters | Returns | Description |
|--------|-----------|---------|-------------|
| `GetJobs()` | — | `table` | Get all loaded jobs |
| `GetGangs()` | — | `table` | Get all loaded gangs |
| `GetJobConfig(jobName)` | `jobName: string` | `table\|nil` | Get job configuration |
| `GetGangConfig(gangName)` | `gangName: string` | `table\|nil` | Get gang configuration |
| `GetPlayerJobConfig(source)` | `source: number` | `table\|nil` | Get player's job config |
| `GetPlayerGangConfig(source)` | `source: number` | `table\|nil` | Get player's gang config |
| `GetPlayerJobVehicles(source)` | `source: number` | `table` | Get player's job vehicles |

### Notifications

| Export | Parameters | Returns | Description |
|--------|-----------|---------|-------------|
| `Notify(source, message, type, duration?)` | `source: number, message: string, type: string, duration?: number` | — | Send notification |

**Notification types:** `'success'`, `'error'`, `'info'`, `'warning'`

### Callbacks

| Export | Parameters | Returns | Description |
|--------|-----------|---------|-------------|
| `CreateCallback(name, handler)` | `name: string, handler: function` | — | Register a server callback |

### Weather (Server)

| Export | Parameters | Returns | Description |
|--------|-----------|---------|-------------|
| `GetCurrentWeather()` | — | `string` | Get current weather type |
| `GetCurrentTime()` | — | `number, number` | Get current hour and minute |
| `SetWeather(type)` | `type: string` | — | Force weather change |
| `SetTime(hour, minute?)` | `hour: number, minute?: number` | — | Force time change |

### Vehicle Keys (Server)

| Export | Parameters | Returns | Description |
|--------|-----------|---------|-------------|
| `GiveKeys(source, plate)` | `source: number, plate: string` | — | Give vehicle keys to player |
| `RemoveKeys(source, plate)` | `source: number, plate: string` | — | Remove vehicle keys |
| `HasKeys(source, plate)` | `source: number, plate: string` | `boolean` | Check if player has keys |
| `LoadPlayerKeys(source)` | `source: number` | — | Load keys from database |

### Utility

| Export | Parameters | Returns | Description |
|--------|-----------|---------|-------------|
| `IsFrameworkReady()` | — | `boolean` | Check if framework is initialized |
| `GetObject()` | — | `table` | Get the full Nova object |
| `GetConfig()` | — | `table` | Get NovaConfig |
| `GetItems()` | — | `table` | Get NovaItems |

---

## Exports - Client

### Player State

| Export | Parameters | Returns | Description |
|--------|-----------|---------|-------------|
| `IsPlayerLoaded()` | — | `boolean` | Check if player is loaded |
| `GetPlayerData()` | — | `table` | Get local player data |
| `IsFrameworkReady()` | — | `boolean` | Check if framework is ready |

### Communication

| Export | Parameters | Returns | Description |
|--------|-----------|---------|-------------|
| `TriggerCallback(name, cb, ...)` | `name: string, cb: function, ...` | — | Trigger a server callback |
| `ClientNotify(message, type, duration?)` | `message: string, type: string, duration?: number` | — | Show local notification |

### Vehicle Keys (Client)

| Export | Parameters | Returns | Description |
|--------|-----------|---------|-------------|
| `HasKey(plate)` | `plate: string` | `boolean` | Check if player has key |
| `GetMyKeys()` | — | `table` | Get all player keys |

---

## Events

### Server Events (listen with `AddEventHandler`)

| Event | Parameters | Description |
|-------|-----------|-------------|
| `nova:server:onFrameworkReady` | — | Framework fully initialized |
| `nova:server:onPlayerLoaded` | `source, player` | Player character loaded |
| `nova:server:onPlayerLogout` | `source, citizenid` | Player logged out |
| `nova:server:onPlayerDropped` | `source, citizenid, reason` | Player disconnected |
| `nova:server:onPlayerDeath` | `source` | Player died (client reported) |
| `nova:server:onMoneyChange` | `source, moneyType, action` | Money changed (`action`: `'add'`/`'remove'`) |
| `nova:server:onJobChange` | `source, newJob, oldJob` | Job changed |
| `nova:server:onGangChange` | `source, newGang, oldGang` | Gang changed |
| `nova:server:onDutyChange` | `source, isOnDuty` | Duty status changed |
| `nova:server:onMetadataChange` | `source, key` | Metadata key changed |
| `nova:server:onItemAdd` | `source, itemName` | Item added to inventory |
| `nova:server:onItemRemove` | `source, itemName` | Item removed from inventory |

### Client Events (listen with `AddEventHandler`)

| Event | Parameters | Description |
|-------|-----------|-------------|
| `nova:client:playerLoaded` | `playerData` | Character loaded on client |
| `nova:client:onLogout` | — | Player logged out |
| `nova:client:onPlayerDataUpdate` | `dataType, data` | Player data updated |
| `nova:client:onPlayerDeath` | — | Player died locally |
| `nova:client:onRevive` | — | Player was revived |

### Server Events (trigger with `TriggerServerEvent`)

| Event | Parameters | Description |
|-------|-----------|-------------|
| `nova:server:loadCharacter` | `citizenId` | Request character load |
| `nova:server:createCharacter` | `charData` | Request character creation |
| `nova:server:deleteCharacter` | `citizenId` | Request character deletion |
| `nova:server:updatePosition` | `{x, y, z, w}` | Update player position |
| `nova:server:updateMetadata` | `{hunger, thirst, ...}` | Update metadata from client |

---

## Callbacks

Callbacks provide async server-client communication. The server processes the request and returns data.

### Registering a Callback (Server)

```lua
-- Using the Nova object
Nova.Functions.CreateCallback('myresource:getData', function(source, cb, someArg)
    -- Do something async (DB query, calculations, etc.)
    local result = { foo = 'bar', value = someArg * 2 }
    cb(result) -- Send result back to client
end)

-- Using export
exports['nova_core']:CreateCallback('myresource:getData', function(source, cb, someArg)
    cb({ foo = 'bar' })
end)
```

### Triggering a Callback (Client)

```lua
-- Async (with callback function)
Nova.Functions.TriggerCallback('myresource:getData', function(result)
    print(result.foo) -- 'bar'
end, 42) -- 42 is passed as someArg

-- Sync (blocks thread - use with caution)
local result = Nova.Functions.TriggerCallbackSync('myresource:getData', 42)
print(result.foo) -- 'bar'

-- Using export
exports['nova_core']:TriggerCallback('myresource:getData', function(result)
    print(result.foo)
end, 42)
```

### Built-in Callbacks

| Name | Returns | Description |
|------|---------|-------------|
| `nova:server:getPlayerData` | `table` | Full player data |
| `nova:server:getCharacters` | `table[]` | Player's character list |
| `nova:server:getJobs` | `table` | All available jobs |
| `nova:server:getGangs` | `table` | All available gangs |

---

## Player Object (Server)

When you get a player via `GetPlayer(source)`, you get an OOP object with these methods:

### Getters

```lua
local player = exports['nova_core']:GetPlayer(source)

player:GetData()         -- Full data table
player:GetFullName()     -- "Firstname Lastname"
player:GetSource()       -- Server ID
player:GetCitizenId()    -- "ABC12345"
player:GetMoney('bank')  -- Bank balance (number)
player:GetJob()          -- Job table {name, label, grade, ...}
player:GetGang()         -- Gang table {name, label, grade, ...}
player:GetInventory()    -- Inventory table
player:HasItem('bread', 1)   -- Has at least 1 bread? (boolean)
player:GetItemCount('bread') -- How many breads? (number)
player:GetMetadata('hunger') -- Specific metadata value
player:GetMetadata()         -- All metadata
player:GetPosition()         -- vector4
```

### Setters

```lua
player:AddMoney('cash', 500, 'Job payment')     -- true/false
player:RemoveMoney('bank', 100, 'Store purchase') -- true/false
player:SetMoney('cash', 1000)                    -- true/false

player:SetJob('police', 2)     -- true/false
player:SetGang('ballas', 0)    -- true/false
player:ToggleDuty()            -- Toggle on/off duty

player:AddItem('bread', 5)           -- true/false
player:RemoveItem('bread', 2)        -- true/false

player:SetMetadata('stress', 50)
player:SetPosition(vector4(x, y, z, w))
```

### Actions

```lua
player:Save()                  -- Save to database
player:Logout()                -- Save + logout
player:Notify('Hello!', 'success', 5000)
player:Kick('AFK too long')
player:Ban('Cheating')
player:Revive()
player:Heal()                  -- Full heal + reset needs
player:UpdateClient('money')   -- Sync specific data to client
player:UpdateClient('all')     -- Sync all data to client
```

---

## Shared Utilities

Available on both client and server via the `Nova` object:

```lua
Nova.Debug('message')              -- Print debug (only if NovaConfig.Debug = true)
Nova.Print('message')              -- Print framework message
Nova.Error('message')              -- Print error
Nova.Warn('message')               -- Print warning
Nova.Lang('key', ...)              -- Get translated string (alias for _L)
Nova.DeepCopy(table)               -- Deep clone a table
Nova.TableContains(table, value)   -- Check if table contains value
Nova.TableCount(table)             -- Count elements (works with non-sequential)
Nova.TableMerge(dest, source)      -- Deep merge two tables
Nova.GenerateId(8)                 -- Random alphanumeric ID
Nova.GenerateCitizenId()           -- "ABC12345" format
Nova.FormatMoney(50000)            -- "50.000"
Nova.FormatTime(3661)              -- "1h 1m 1s"
Nova.GetItem('bread')              -- Item data from NovaItems
Nova.ItemExists('bread')           -- boolean
```

---

## Systems

### Needs (Hunger/Thirst)

Configured in `NovaConfig.Needs`. When enabled:
- Hunger and thirst decrease over time (configurable rate and interval).
- When either reaches 0, the player takes 1 HP damage per tick.
- Values sync to server metadata and are saved automatically.
- A modern HUD displays bars in the bottom-right corner with color-coded states.

**HUD Behavior:**
- **Green/Blue** (>60%): Normal state, semi-transparent when both >75%.
- **Orange/Dark Blue** (30-60%): Medium warning.
- **Red** (<30%): Low warning.
- **Pulsing** (<20%): Critical state with animation.

### Weather/Time Sync

Server-authoritative weather and time system. Configured in `NovaConfig.Weather`.

**Features:**
- Automatic weather cycle through configurable weather types.
- Configurable time speed (default: 10s real = 1min in-game).
- Smooth weather transitions.
- All clients synced automatically every 5 seconds.
- New players receive current state on spawn.

**Admin Commands:**
- `/setweather [type]` — Force weather (CLEAR, RAIN, THUNDER, CLOUDS, OVERCAST, FOGGY, EXTRASUNNY, etc.)
- `/settime [hour] [minute]` — Force time (0-23, 0-59)
- `/freezetime` — Toggle time freeze

**Using from other resources:**

```lua
-- Server-side
local weather = exports['nova_core']:GetCurrentWeather()
local hour, minute = exports['nova_core']:GetCurrentTime()
exports['nova_core']:SetWeather('RAIN')
exports['nova_core']:SetTime(22, 30) -- 10:30 PM
```

### World Control

Automatic NPC and traffic control (`client/world.lua`):
- Removes all NPC vehicles (density set to 0).
- Removes police NPCs and disables wanted levels.
- Keeps walking pedestrians (configurable density).
- Periodic cleanup threads for NPCs that slip through.

### Vehicle Keys

Key management system for vehicles:
- Keys given on vehicle purchase/takeout.
- Lock/unlock with `L` key (with animation + sound).
- Server-side key ownership tracked in `PlayerKeys` table.
- Exports for other resources to manage keys.

### Permissions

O(1) cached permission system with ACE bridge:
- Groups: `user`, `mod`, `admin`, `superadmin`, `god`
- Permission nodes for granular control.
- Automatic cache refresh on changes.

### Jobs & Gangs

Full job and gang system:
- Database-driven with cache.
- Multiple grades per job/gang.
- Boss grade flag for management access.
- Duty system with toggle.
- Automatic salary payments (configurable).
- Job vehicles and equipment on duty.

---

## Creating a Script with NOVA

Here's a complete example of a simple shop resource:

### fxmanifest.lua

```lua
fx_version 'cerulean'
game 'gta5'

name 'my_shop'
dependencies { 'nova_core' }

server_scripts { 'server.lua' }
client_scripts { 'client.lua' }
```

### server.lua

```lua
-- Register a callback for buying items
exports['nova_core']:CreateCallback('myshop:buyItem', function(source, cb, itemName, price)
    local player = exports['nova_core']:GetPlayer(source)
    if not player then cb(false) return end

    -- Check if player has enough money
    if player:GetMoney('cash') < price then
        player:Notify('Not enough money!', 'error')
        cb(false)
        return
    end

    -- Process purchase
    if player:RemoveMoney('cash', price, 'Shop purchase: ' .. itemName) then
        player:AddItem(itemName, 1)
        cb(true)
    else
        cb(false)
    end
end)
```

### client.lua

```lua
local Nova = exports['nova_core']:GetObject()

-- When near the shop, show prompt
CreateThread(function()
    local shopCoords = vector3(25.0, -1346.0, 29.0)

    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local dist = #(playerCoords - shopCoords)

        if dist < 2.0 then
            -- Draw 3D text
            Nova.Functions.DrawText3D(shopCoords, '[E] Open Shop')

            if IsControlJustPressed(0, 38) then -- E key
                -- Ask server to buy bread for $10
                Nova.Functions.TriggerCallback('myshop:buyItem', function(success)
                    if success then
                        Nova.Functions.Notify('Purchased bread!', 'success')
                    end
                end, 'bread', 10)
            end

            Wait(0)
        else
            Wait(1000)
        end
    end
end)
```

---

## Localization

NOVA supports multiple languages. Currently included:
- **Portuguese** (`pt`) — Default
- **English** (`en`)

### Switching Language

In `config/main.lua`, change:

```lua
NovaConfig.Locale = 'en'  -- or 'pt'
```

### Adding a New Language

Create `config/locales/xx.lua`:

```lua
NovaLocale.RegisterLocale('xx', {
    ['framework_started'] = 'Your translation here v%s',
    ['player_loaded'] = 'Your translation here',
    -- ... all keys from pt.lua
})
```

Add to `fxmanifest.lua` shared_scripts:

```lua
'config/locales/xx.lua',
```

---

## Database Schema

NOVA uses the following tables (auto-created from `sql/schema.sql`):

| Table | Description |
|-------|-------------|
| `nova_users` | User accounts (identifier, group, ban status) |
| `nova_characters` | Character data (charinfo, money, job, gang, inventory, metadata, skin, position) |
| `nova_vehicles` | Owned vehicles (citizenid, vehicle, plate, state, fuel, body, engine, mods) |
| `nova_jobs` | Job definitions with grades (JSON) |
| `nova_gangs` | Gang definitions with grades (JSON) |

---

## License

NOVA Framework is proprietary software. All rights reserved.
