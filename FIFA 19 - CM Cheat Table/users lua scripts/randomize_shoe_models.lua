--- This script will edit players shoes. 
--- By default only Black/White shoes will be replaced by a random shoe model from the "shoe_id_list" with random color.
--- You can set 'randomize_all' variable to true if you want to randoize all shoes. 
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

local shoe_id_list = {
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    28,
    29,
    30,
    31,
    32,
    33,
    34,
    35,
    36,
    37,
    38,
    39,
    40,
    41,
    42,
    43,
    44,
    45,
    46,
    47,
    48,
    49,
    50,
    51,
    52,
    53,
    54,
    55,
    56,
    57,
    58,
    59,
    60,
    61,
    62,
    63,
    64,
    65,
    66,
    67,
    68,
    69,
    70,
    71,
    72,
    73,
    74,
    75,
    76,
    77,
    78,
    79,
    80,
    81,
    82,
    83,
    84,
    85,
    86,
    87,
    88,
    89,
    90,
    91,
    92,
    93,
    94,
    95,
    96,
    97,
    98,
    99,
    100,
    101,
    102,
    103,
    104,
    105,
    106,
    107,
    108,
    109,
    110,
    111,
    112,
    113,
    114,
    115,
    116,
    117,
    118,
    119,
    120,
    121,
    122,
    123,
    124,
    125,
    126,
    127,
    128,
    130,
    131,
    132,
    133,
    134,
    135,
    136,
    137,
    138,
    139,
    140,
    141,
    142,
    165,
    166,
    167,
    168,
    169,
    170,
    171,
    172,
    173,
    174,
    175,
    176,
    177,
    178,
    179,
    180,
    181,
    182,
    183,
    184,
    185,
    186,
    192,
    193,
    194,
    195,
    197,
    198,
    199,
    200,
    201,
    204,
    205,
    206,
    209,
    210,
    211,
    216,
    217,
    218,
    219,
    220,
    227,
    228,
    231,
    232,
    233,
    234,
    235,
    237,
    238,
    239,
    255,
    256,
    257,
    258,
    259,
    260,
    261,
    262,
    263,
    264,
    265,
    266,
    267,
    271,
    272,
    275,
    276,
    277,
    278,
    279,
    280,
    282,
    283,
    284,
    285,
    338,
    339,
    340,
    341,
    342,
    343,
    344,
    345,
    346,
    347,
    348,
    349,
    350,
    351,
    352,
    353,
    354
}

function inTable(tbl, item)
    for key, value in pairs(tbl) do
        if value == item then return key end
    end
    return false
end

-- players table
local sizeOf = 100 -- Size of one record in players database table (0x64)

-- iterate over all players in 'players' database table
local i = 0
local current_playerid = 0

-- false - Randomize only Black/White Boots
-- true  - Randomize all shoes
local randomize_all = false
while true do
    local playerid_record = ADDR_LIST.getMemoryRecordByID(CT_MEMORY_RECORDS['PLAYERID'])
    local current_playerid = bAnd(bShr(readInteger(string.format('[%s]+%X', 'firstPlayerDataPtr', playerid_record.getOffset(0)+(i*sizeOf))), playerid_record.Binary.Startbit), (bShl(1, playerid_record.Binary.Size) - 1))
    if current_playerid == 0 then
        break
    end

    writeQword('playerDataPtr', readPointer('firstPlayerDataPtr') + i*sizeOf)
    
    local current_shoe = tonumber(ADDR_LIST.getMemoryRecordByID(comp_desc['shoetypeEdit']['id']).Value)
    
    if randomize_all or not inTable(shoe_id_list, current_shoe) then
        -- Random Shoe
        local new_shoe_id = shoe_id_list[math.random(#shoe_id_list)]

        -- Random shoecolorcode1
        local new_color_one = math.random(0, 31)
        
        -- Random shoecolorcode2
        local new_color_two = math.random(0, 31)
        
        ADDR_LIST.getMemoryRecordByID(comp_desc['shoedesignEdit']['id']).Value = 0
        ADDR_LIST.getMemoryRecordByID(comp_desc['shoetypeEdit']['id']).Value = new_shoe_id
        ADDR_LIST.getMemoryRecordByID(comp_desc['shoecolorEdit1']['id']).Value = new_color_one
        ADDR_LIST.getMemoryRecordByID(comp_desc['shoecolorEdit2']['id']).Value = new_color_two
       
    end

    i = i + 1
end

showMessage("Done")