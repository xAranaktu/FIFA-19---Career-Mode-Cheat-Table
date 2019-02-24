PlayerTeamContext = {}


function check_if_has_unapplied_player_changes()
    if HAS_UNAPPLIED_PLAYER_CHANGES then
        if messageDialog("You have some unapplied changes in player editor\nDo you want to apply them?", mtInformation, mbYes,mbNo) == mrYes then
            ApplyChanges()
        else
            HAS_UNAPPLIED_PLAYER_CHANGES = false
        end
    end
end

function FillHeadTypeCB(args)
    -- Update data in HeadTypeGroupCB and HeadTypeCodeCB
    local head_type_code = tonumber(ADDR_LIST.getMemoryRecordByID(COMPONENTS_DESCRIPTION_PLAYER_EDIT['HeadTypeCodeCB']['id']).Value)

    local i = 0
    local found = false
    for key, value in pairs(HEAD_TYPE_GROUPS) do
        local group = string.gsub(key, '_', ' ')
        PlayersEditorForm.HeadTypeGroupCB.items.add(group)
        
        if found ~= true then
            PlayersEditorForm.HeadTypeCodeCB.clear()
            for j = 1, #value do
                PlayersEditorForm.HeadTypeCodeCB.items.add(value[j])
                if value[j] == head_type_code then
                    PlayersEditorForm.HeadTypeGroupCB.ItemIndex = i
                    PlayersEditorForm.HeadTypeCodeCB.ItemIndex = j-1
                    found = true
                end
            end
            i = i + 1
        end
    end
end

PLAYEREDIT_HOTKEYS_OBJECTS = {}
function create_hotkeys()
    destroy_hotkeys()
    if CFG_DATA.hotkeys.sync_with_game then
        table.insert(PLAYEREDIT_HOTKEYS_OBJECTS, createHotkey(SyncImageClick, _G[CFG_DATA.hotkeys.sync_with_game]))
    end
    if CFG_DATA.hotkeys.search_player_by_id then
        table.insert(PLAYEREDIT_HOTKEYS_OBJECTS, createHotkey(SearchPlayerByIDClick, _G[CFG_DATA.hotkeys.search_player_by_id]))
    end
end

function destroy_hotkeys()
    for i=1,#PLAYEREDIT_HOTKEYS_OBJECTS do
        PLAYEREDIT_HOTKEYS_OBJECTS[i].destroy()
    end
    PLAYEREDIT_HOTKEYS_OBJECTS = {}
end

function reset_components()
    for i=0, PlayersEditorForm.ComponentCount-1 do
        local component = PlayersEditorForm.Component[i]
        local component_class = component.ClassName
        -- clear
        if component_class == 'TCEEdit' then
            component.Text = ''
            component.OnChange = nil
        elseif component_class == 'TCETrackBar' then
            component.OnChange = nil
            component.Position = 1
            component.SelEnd = 1
        elseif component_class == 'TCEComboBox' then
            component.clear()
        end
    end
end

function roll_random_attributes(components)
    HAS_UNAPPLIED_PLAYER_CHANGES = true
    for i=1, #components do
        -- tmp disable onchange event
        local onchange_event = PlayersEditorForm[components[i]].OnChange
        PlayersEditorForm[components[i]].OnChange = nil
        PlayersEditorForm[components[i]].Text = math.random(ATTRIBUTE_BOUNDS['min'], ATTRIBUTE_BOUNDS['max'])
        PlayersEditorForm[components[i]].OnChange = onchange_event
    end
    update_trackbar(PlayersEditorForm[components[1]])
    recalculate_ovr(true)
end

-- Recalculate OVR
-- update_ovr_edit - bool. If true then value in OverallEdit will be updated
function recalculate_ovr(update_ovr_edit)
    local preferred_position_id = PlayersEditorForm.PreferredPosition1CB.ItemIndex
    if preferred_position_id == 1 then return end -- ignore SW

    -- top 3 values will be put in "Best At"
    local unique_ovrs = {}
    local top_ovrs = {}

    local calculated_ovrs = {}
    for posid, attributes in pairs(OVR_FORMULA) do
        local sum = 0
        for attr, perc in pairs(attributes) do
            local attr_val = tonumber(PlayersEditorForm[attr].Text)
            if attr_val == nil then
                return
            end
            sum = sum + (attr_val * perc)
        end
        sum = math.floor(sum)
        unique_ovrs[sum] = sum

        calculated_ovrs[posid] = sum
    end
    if update_ovr_edit then
        PlayersEditorForm.OverallEdit.Text = calculated_ovrs[string.format("%d", preferred_position_id)]
    end

    for k,v in pairs(unique_ovrs) do
        table.insert(top_ovrs, k)
    end

    table.sort(top_ovrs, function(a,b) return a>b end)

    -- Fill "Best At"
    local position_names = {
        ['1'] = {
            short = {},
            long = {},
            showhint = false
        },
        ['2'] = {
            short = {},
            long = {},
            showhint = false
        },
        ['3'] = {
            short = {},
            long = {},
            showhint = false
        }
    }
    -- remove useless pos
    local not_show = {
        4,6,9,11,13,15,17,19
    }
    for posid, ovr in pairs(calculated_ovrs) do
        for i = 1, #not_show do
            if tonumber(posid) == not_show[i] then
                goto continue
            end
        end
        for i = 1, 3 do
            if ovr == top_ovrs[i] then
                if #position_names[string.format("%d", i)]['short'] <= 2 then
                    table.insert(position_names[string.format("%d", i)]['short'], PlayersEditorForm.PreferredPosition1CB.Items[tonumber(posid)])
                elseif #position_names[string.format("%d", i)]['short'] == 3 then
                    table.insert(position_names[string.format("%d", i)]['short'], '...')
                    position_names[string.format("%d", i)]['showhint'] = true
                end
                table.insert(position_names[string.format("%d", i)]['long'], PlayersEditorForm.PreferredPosition1CB.Items[tonumber(posid)])
            end
        end
        ::continue::
    end

    for i = 1, 3 do
        PlayersEditorForm[string.format("BestPositionLabel%d", i)].Caption = string.format("- %s: %d ovr", table.concat(position_names[string.format("%d", i)]['short'], '/'), top_ovrs[i])
        if position_names[string.format("%d", i)]['showhint'] then
            PlayersEditorForm[string.format("BestPositionLabel%d", i)].Hint = string.format("- %s: %d ovr", table.concat(position_names[string.format("%d", i)]['long'], '/'), top_ovrs[i])
            PlayersEditorForm[string.format("BestPositionLabel%d", i)].ShowHint = true
        else
            PlayersEditorForm[string.format("BestPositionLabel%d", i)].ShowHint = false
        end
    end
end

function find_player_by_id(playerid)
    if type(playerid) == 'string' then
        playerid = tonumber(playerid)
    end

    -- return dict with playerid and teams
    if playerid <= 0 then
        do_log("Playerid must be higer than 0", 'ERROR')
        return false 
    elseif readPointer('firstPlayerDataPtr') == nil then
        do_log("firstPlayerDataPtr not initialized", 'ERROR')
        return false
    elseif readPointer('ptrFirstTeamplayerlinks') == nil then
        do_log("ptrFirstTeamplayerlinks not initialized", 'ERROR')
        return false
    end
    
    -- measure time
    local start_time = os.time()
    
    -- players table
    local sizeOf = 100 -- Size of one record in players database table (0x64)
    local player_addr = find_record_in_game_db(0, CT_MEMORY_RECORDS['PLAYERID'], playerid, sizeOf, 'firstPlayerDataPtr')['addr']
    
    
    if player_addr then
        -- Update in Cheat Table
        writeQword('playerDataPtr', player_addr)

        -- find team-player links
        playerid_record_id = 2775    -- PlayerID in teamplayerlinks table
        sizeOf = 16 -- Size of one record in teamplayerlinks database table (0x10)

        PlayerTeamContext = {}
        local start = 0
        local team_ids = {}
        while true do
            local teamplayerlink = find_record_in_game_db(start, playerid_record_id, playerid, sizeOf, 'ptrFirstTeamplayerlinks')
            if teamplayerlink['addr'] == nil then break end
            start = start + teamplayerlink['index'] + 1

            writeQword('ptrTeamplayerlinks', teamplayerlink['addr'])
            local teamid = tonumber(ADDR_LIST.getMemoryRecordByID(CT_MEMORY_RECORDS['TEAMID']).Value) + 1
            table.insert(team_ids, teamid)
            -- find league-team link
            -- local ltl_teamid_record_id = 2913 -- TeamID in leagueteamlinks table
            -- local ltl_sizeOf = 28 -- Size of one record in leagueteamlinks database table (0x1C)
            -- local leagueteamlink_addr = find_record_in_game_db(0, ltl_teamid_record_id, teamid, ltl_sizeOf, 'firstleagueteamlinksDataPtr')['addr']
            -- if leagueteamlink_addr == nil then break end

            -- writeQword('leagueteamlinksDataPtr', leagueteamlink_addr)
            
            PlayerTeamContext[teamid] = {
                addr = teamplayerlink['addr']
            }

            -- local leagueid = ADDR_LIST.getMemoryRecordByID(2902).Value
            -- if leagueid == 76 then
            --     -- MLS ALL STARS/ADIDAS 

            -- elseif leagueid == 78 or leagueid == 2136 then
            --     teams['NationalTeam'] = {
            --         addr = teamplayerlink['addr']
            --     }
            -- else
            --     teams['Club'] = {
            --         addr = teamplayerlink['addr']
            --     }
            -- end
        end
        -- set first team in CT
        writeQword('ptrTeamplayerlinks', PlayerTeamContext[team_ids[1]]['addr'])
    else
        do_log(string.format("Unable to find player with ID: %d.", playerid), 'ERROR')
    end
end

function birthdate_to_age(args)
    local comp_desc = args['comp_desc']
    local str_current_date = string.format("%d", 20080101 + (tonumber(ADDR_LIST.getMemoryRecordByID(CT_MEMORY_RECORDS['CURRDATE']).Value) or 0))

    local current_date = os.time{
        year=tonumber(string.sub(str_current_date, 1, 4)),
        month=tonumber(string.sub(str_current_date, 5, 6)),
        day=tonumber(string.sub(str_current_date, 7, 8))
    }

    local birthdate = convert_from_days(ADDR_LIST.getMemoryRecordByID(CT_MEMORY_RECORDS['BIRTHDATE']).Value)

    return math.floor(os.difftime(current_date, birthdate) / (24*60*60*365.25))
end

function update_trackbar(sender)
    local trackBarName = string.format("%sTrackBar", COMPONENTS_DESCRIPTION_PLAYER_EDIT[sender.Name]['group'])
    local valueLabelName = string.format("%sValueLabel", COMPONENTS_DESCRIPTION_PLAYER_EDIT[sender.Name]['group'])

    -- recalculate ovr of group of attrs
    local onchange_func = PlayersEditorForm[trackBarName].OnChange
    PlayersEditorForm[trackBarName].OnChange = nil

    local calc = AttributesTrackBarVal({
        component_name = trackBarName,
    })

    PlayersEditorForm[trackBarName].Position = calc
    PlayersEditorForm[trackBarName].SelEnd = calc
    PlayersEditorForm[valueLabelName].Caption = calc

    PlayersEditorForm[trackBarName].OnChange = onchange_func

end

function AttributesTrackBarVal(args)
    local component_name = args['component_name']

    local comp_desc = COMPONENTS_DESCRIPTION_PLAYER_EDIT[component_name]

    local sum_attr = 0
    local items = 0

    if comp_desc['depends_on'] then
        for i=1, #comp_desc['depends_on'] do
            items = items + 1
            if PlayersEditorForm[comp_desc['depends_on'][i]].Text == '' then
                local r = COMPONENTS_DESCRIPTION_PLAYER_EDIT[comp_desc['depends_on'][i]]
                PlayersEditorForm[comp_desc['depends_on'][i]].Text = tonumber(ADDR_LIST.getMemoryRecordByID(r['id']).Value) + r['modifier']
            end
            sum_attr = sum_attr + tonumber(PlayersEditorForm[comp_desc['depends_on'][i]].Text)
        end
    end

    local result = math.ceil(sum_attr/items)
    if result > ATTRIBUTE_BOUNDS['max'] then
        result = ATTRIBUTE_BOUNDS['max']
    elseif result < ATTRIBUTE_BOUNDS['min'] then
        result = ATTRIBUTE_BOUNDS['min']
    end

    return result
end

-- Fill fields in Player Edit Form
function FillPlayerEditForm(playerid)

    if playerid ~= nil then
        find_player_by_id(playerid)
    end

    local new_val = 0
    for i=0, PlayersEditorForm.ComponentCount-1 do
        local component = PlayersEditorForm.Component[i]
        local component_name = component.Name
        local comp_desc = COMPONENTS_DESCRIPTION_PLAYER_EDIT[component_name]
        if comp_desc == nil then goto continue end

        local component_class = component.ClassName
        if component_class == 'TCEEdit' then
            -- clear
            component.OnChange = nil

            -- Update value of all edit fields
            if comp_desc['valFromFunc'] then
                component.Text = comp_desc['valFromFunc']({
                    comp_desc = comp_desc,
                })
            else
                component.Text = tonumber(ADDR_LIST.getMemoryRecordByID(comp_desc['id']).Value) + comp_desc['modifier']
            end

            if comp_desc['events'] then
                for key, value in pairs(comp_desc['events']) do
                    component[key] = value
                end
            else
                component.OnChange = CommonEditOnChange
            end
        elseif component_class == 'TCETrackBar' then
            if comp_desc['events'] then
                for key, value in pairs(comp_desc['events']) do
                    component[key] = value
                end
            end
        elseif component_class == 'TCEComboBox' then
            -- clear
            if not comp_desc['already_filled'] then
                component.clear()

                if comp_desc['valFromFunc'] then
                    comp_desc['valFromFunc']()
                else
                    local dropdown = ADDR_LIST.getMemoryRecordByID(comp_desc['id'])
                    local dropdown_items = dropdown.DropDownList
                    local dropdown_selected_value = dropdown.Value
                    for j = 0, dropdown_items.Count-1 do
                        local val, desc = string.match(dropdown_items[j], "(%d+): '(.+)'")
        
                        -- Fill combobox in GUI with values from memory record dropdown
                        component.items.add(desc)
        
                        -- Set active item & update hint
                        if dropdown_selected_value == val then
                            component.ItemIndex = j
                            component.Hint = desc
                        end
                    end
                end
            end

            -- Add events
            if comp_desc['events'] then
                for key, value in pairs(comp_desc['events']) do
                    component[key] = value
                end
            else
                component.OnChange = CommonCBOnChange
                component.OnDropDown = CommonCBOnDropDown
                component.OnMouseEnter = CommonCBOnMouseEnter
                component.OnMouseLeave = CommonCBOnMouseLeave
            end
        elseif component_class == 'TCECheckBox' then
            -- Set checkbox state
            component.State = tonumber(ADDR_LIST.getMemoryRecordByID(comp_desc['id']).Value)
        end
        ::continue::
    end


    -- Update trackbars
    local trackbars = {
        'AttackTrackBar',
        'DefendingTrackBar',
        'SkillTrackBar',
        'GoalkeeperTrackBar',
        'PowerTrackBar',
        'MovementTrackBar',
        'MentalityTrackBar',
    }
    for i=1, #trackbars do
        update_trackbar(PlayersEditorForm[trackbars[i]])
    end

    -- Load Img
    local ss_hs = load_headshot(
        tonumber(PlayersEditorForm.PlayerIDEdit.Text),
        tonumber(ADDR_LIST.getMemoryRecordByID(COMPONENTS_DESCRIPTION_PLAYER_EDIT['HeadTypeCodeCB']['id']).Value),
        tonumber(ADDR_LIST.getMemoryRecordByID(COMPONENTS_DESCRIPTION_PLAYER_EDIT['HairColorCB']['id']).Value)
    )
    PlayersEditorForm.Headshot.Picture.LoadFromStream(ss_hs)
    ss_hs.destroy()
    PlayersEditorForm.Headshot.stretch=true

    local ss_c = load_crest(tonumber(PlayersEditorForm.TeamIDEdit.Text))
    PlayersEditorForm.Crest64x64.Picture.LoadFromStream(ss_c)
    ss_c.destroy()
    PlayersEditorForm.Crest64x64.stretch=true


end

function age_to_birthdate(args)
    local comp_desc = args['comp_desc']
    local str_current_date = string.format("%d", 20080101 + (tonumber(ADDR_LIST.getMemoryRecordByID(CT_MEMORY_RECORDS['CURRDATE']).Value) or 0))

    local current_date = os.time{
        year=tonumber(string.sub(str_current_date, 1, 4)),
        month=tonumber(string.sub(str_current_date, 5, 6)),
        day=tonumber(string.sub(str_current_date, 7, 8))
    }
    local component = args['component']
    local age = tonumber(component.Text)
    local new_birthdate = convert_to_days(os.time{
        year=tonumber(string.sub(str_current_date, 1, 4)) - age,
        month=tonumber(string.sub(str_current_date, 5, 6)),
        day=tonumber(string.sub(str_current_date, 7, 8))
    })

    return new_birthdate 
end

-- From GUI to CT
function ApplyChangesToDropDown(dropdown, component)
    local dropdown_items = dropdown.DropDownList
    local dropdown_selected_value = dropdown.Value

    for j = 0, dropdown_items.Count-1 do
        local val, desc = string.match(dropdown_items[j], "(%d+): '(.+)'")
        if component.Items[component.ItemIndex] == desc then
            dropdown.Value = tonumber(val)
            return
        end
    end
end

function ApplyChanges()
    -- verify playerid 
    if ADDR_LIST.getMemoryRecordByID(CT_MEMORY_RECORDS['PLAYERID']).Value ~= PlayersEditorForm.PlayerIDEdit.Text then
        do_log(
            string.format("GUI was not synchronized with the game. playerid in GUI:%s playerid in game:%s .To prevent your save from damage, changes hasn't been applied", ADDR_LIST.getMemoryRecordByID(CT_MEMORY_RECORDS['PLAYERID']).Value, PlayersEditorForm.PlayerIDEdit.Text),
            'ERROR'
        )
        HAS_UNAPPLIED_PLAYER_CHANGES = false
        return
    end

    for i=0, PlayersEditorForm.ComponentCount-1 do
        local component = PlayersEditorForm.Component[i]
        local component_name = component.Name
        local comp_desc = COMPONENTS_DESCRIPTION_PLAYER_EDIT[component_name]
        if comp_desc == nil then goto continue end
        if comp_desc['id'] == nil then goto continue end

        local component_class = component.ClassName
        
        if component_class == 'TCEEdit' then
            if comp_desc['onApplyChanges'] then
                ADDR_LIST.getMemoryRecordByID(comp_desc['id']).Value = comp_desc['onApplyChanges']({
                    component = component,
                    comp_desc = comp_desc,
                })
            else
                ADDR_LIST.getMemoryRecordByID(comp_desc['id']).Value = tonumber(component.Text) - comp_desc['modifier']
            end

        elseif component_class == 'TCEComboBox' then
            ApplyChangesToDropDown(ADDR_LIST.getMemoryRecordByID(comp_desc['id']), component)
        elseif component_class == 'TCECheckBox' then
            ADDR_LIST.getMemoryRecordByID(comp_desc['id']).Value = tonumber(component.State)
        end
        ::continue::
    end
    HAS_UNAPPLIED_PLAYER_CHANGES = false
    showMessage("Player edited.")
end

