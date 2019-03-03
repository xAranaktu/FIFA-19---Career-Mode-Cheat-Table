--- This script will Randomize age, attributes, potential of all players.
--- New attribute will be a value between 21 and 99
--- New potential will be a value between 21 and 99 (but not lower that player ovr)
--- New Age can be lower than current age by 10 years to higher than current age by 10 years
--- It may take a few mins. Cheat Engine will stop responding and it's normal behaviour. Wait until you get 'Done' message.

--- HOW TO USE:
--- https://i.imgur.com/xZMqzTc.gifv
--- 1. Open Cheat table as usuall and enter your career.
--- 2. In Cheat Engine click on "Memory View" button.
--- 3. Press "CTRL + L" to open lua engine
--- 4. Then press "CTRL + O" and open this script
--- 5. Click on 'Execute' button to execute script and wait for 'done' message box.

--- AUTHOR: ARANAKTU

require 'lua/GUI/forms/playerseditorform/consts';

local comp_desc = get_components_description_player_edit()

-- list of attributes
local attributes_to_randomize = {
    "Potential",
    "Crossing",
    "Finishing",
    "HeadingAccuracy",
    "ShortPassing",
    "Volleys",
    "Marking",
    "StandingTackle",
    "SlidingTackle",
    "Dribbling",
    "Curve",
    "FreeKickAccuracy",
    "LongPassing",
    "BallControl",
    "GKDiving",
    "GKHandling",
    "GKKicking",
    "GKPositioning",
    "GKReflex",
    "ShotPower",
    "Jumping",
    "Stamina",
    "Strength",
    "LongShots",
    "Acceleration",
    "SprintSpeed",
    "Agility",
    "Reactions",
    "Balance",
    "Aggression",
    "Composure",
    "Interceptions",
    "AttackPositioning",
    "Vision",
    "Penalties",
}

-- players table
local sizeOf = 100 -- Size of one record in players database table (0x64)

-- iterate over all players in 'players' database table
local i = 0
local current_playerid = 0
while true do
    local playerid_record = ADDR_LIST.getMemoryRecordByID(CT_MEMORY_RECORDS['PLAYERID'])
    local current_playerid = bAnd(bShr(readInteger(string.format('[%s]+%X', 'firstPlayerDataPtr', playerid_record.getOffset(0)+(i*sizeOf))), playerid_record.Binary.Startbit), (bShl(1, playerid_record.Binary.Size) - 1))
    if current_playerid == 0 then
        break
    end

    writeQword('playerDataPtr', readPointer('firstPlayerDataPtr') + i*sizeOf)
    
    -- get ovr_formula for player primiary position
    local ovr_formula = deepcopy(OVR_FORMULA[ADDR_LIST.getMemoryRecordByID(comp_desc['PreferredPosition1CB']['id']).Value])
    
    -- Randomize Attributes
    local new_ovr = 0
    for j=1, #attributes_to_randomize do
        local new_attr_val = math.random(19, 98)
        local attr_name = attributes_to_randomize[j] .. 'Edit'
        for attr, perc in pairs(ovr_formula) do
            if attr == attr_name then
                new_ovr = new_ovr + (new_attr_val * perc)
            end
        end
        ovr_formula[attr_name] = nil

        ADDR_LIST.getMemoryRecordByID(comp_desc[attr_name]['id']).Value = new_attr_val
    end
    
    -- Update OVR
    new_ovr = math.floor(new_ovr)
    ADDR_LIST.getMemoryRecordByID(comp_desc['OverallEdit']['id']).Value = new_ovr
    
    -- Keep potential higher than ovr
    local new_pot = tonumber(ADDR_LIST.getMemoryRecordByID(comp_desc['PotentialEdit']['id']).Value)
    if new_pot < new_ovr then
        if new_ovr >= 94 then
            ADDR_LIST.getMemoryRecordByID(comp_desc['PotentialEdit']['id']).Value = 99
        else
            ADDR_LIST.getMemoryRecordByID(comp_desc['PotentialEdit']['id']).Value = new_ovr + 5
        end
    end
    
    -- Randomize Age
    local bd_record = ADDR_LIST.getMemoryRecordByID(CT_MEMORY_RECORDS['BIRTHDATE'])
    local current_age = tonumber(bd_record.Value)
    if math.random() >= 0.50 then
        -- younger
        bd_record.Value = current_age + (math.random(0, 10) * 365)
    else
        -- older
        bd_record.Value = current_age - (math.random(0, 10) * 365)
    end

    i = i + 1
end

showMessage("Done")