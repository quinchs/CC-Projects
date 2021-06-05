## Turtle Miner

These scripts are for an auto miner with the digital miner from Mekanism.

### Config

#### Script configuration

You can change how the turtle behaves by editing the `AutoMining.lua` file and changing the first set of variables.

```lua
-- The channel for the QIO importer to import on. This is the channel that the resources mined from the digital miner will be sent into.
local depoChannel = "Mining depo"

-- The Quantum Entangloporter channel for the turtle to refuel on.
local fuelChannel = "Coal"

-- The Quantum Entangloporter channel for the power.
local powerChannel = "Power"

-- The channel of the server to send commands to this turtle (Currently doesnt do anything but in the future this could be used to change the filter file and the configs.)
local serverChannel = 1400

-- The channel for this miner (used for the reply to channel.)
local clientChannel = 1400 + os.getComputerID()

-- the default miner filters file.
local optionsFile = "filters.json"
```

#### Miner config

You can specify the filter and configuration for the digital miner in the `filter.json` file.

```json
{
    "silkTouch": true, // whether or not to use silk touch
    "radius": 32, // The radius for the digital miner
    "minY": 0, // the minimum Y value for the digital miner
    "maxY": 100, // the maximum Y value for the digital miner
    "filters": [
        // A collection of filters for the digital miner
        {
            "replaceItem": "minecraft:air", // the replacement item for the digital miner
            "requireReplace": false, // whether or not the miner should replace the block.
            "tag": "forge:ores", // the tag for this filter
            "type": "MINER_TAG_FILTER" // the type of the filter
        }
    ]
}
```
