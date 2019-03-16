--- This script will make every player in your career 16. Make a backup save before you apply this just to be safe. Join this discord for help: https://discord.gg/QFyHUxe
--- It may take a few mins. Cheat Engine will stop responding and it's normal behaviour. Wait until you get 'Done' message.

--- How do you change which age gets applied to everyone? Just edit "locale new_bd_value = 152991" change the value (152991) to whatever age you want. 
---    Age codes can be found here: https://www.fifermods.com/fifa-19-age-codes and an age calculator can be found here: https://www.timeanddate.com/date/durationresult.html?y1=1582&m1=10&d1=15&y2=2017&m2=9&d2=29&ti=on

--- HOW TO USE:
--- https://i.imgur.com/xZMqzTc.gifv
--- 1. Open Cheat table as usuall and enter your career.
--- 2. In Cheat Engine click on "Memory View" button.
--- 3. Press "CTRL + L" to open lua engine
--- 4. Then press "CTRL + O" and open this script
--- 5. Click on 'Execute' button to execute script and wait for 'done' message box. It may take a few minutes, and the cheat engine will stop responding.

--- AUTHOR: FIFER

require 'lua/GUI/forms/playerseditorform/consts';

-- EDIT THIS. CHANGE 0 (or the value next to locale season =) TO THE SEASON YOU ARE IN (0 being first, 1 being second, etc)
local season = 0

local comp_desc = get_components_description_player_edit()

-- players table
local sizeOf = 100 -- Size of one record in players database table (0x64)

-- iterate over all players in 'players' database table
local i = 0
local current_playerid = 0
local new_bd_value = 152991 + (season * 365)
while true do
    local playerid_record = ADDR_LIST.getMemoryRecordByID(CT_MEMORY_RECORDS['PLAYERID'])
    local current_playerid = bAnd(bShr(readInteger(string.format('[%s]+%X', 'firstPlayerDataPtr', playerid_record.getOffset(0)+(i*sizeOf))), playerid_record.Binary.Startbit), (bShl(1, playerid_record.Binary.Size) - 1))
    if current_playerid == 0 then
        break
    end

    writeQword('playerDataPtr', readPointer('firstPlayerDataPtr') + i*sizeOf)
    ADDR_LIST.getMemoryRecordByID(comp_desc['AgeEdit']['id']).Value = new_bd_value

    i = i + 1
end

showMessage("Done. All players should now be 16.")