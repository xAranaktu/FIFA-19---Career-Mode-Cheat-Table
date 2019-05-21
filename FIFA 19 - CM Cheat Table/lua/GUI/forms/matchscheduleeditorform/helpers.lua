function value_to_match_date(value)
    -- Convert value from the game to human readable form (format: DD/MM/YYYY)
    -- ex. 20180908 -> 08/09/2018
    local to_string = string.format('%d', value)
    return string.format(
        '%s/%s/%s',
        string.sub(to_string, 7),
        string.sub(to_string, 5, 6),
        string.sub(to_string, 1, 4)
    )
end

function match_date_to_value(match_date)
    local m_date, _ = string.gsub(match_date, '%W', '')
    if string.len(m_date) ~= 8 then
        local txt = string.format('Invalid date format: %s', match_date)
        do_log(txt, 'ERROR')
        return false
    end
    m_date = string.format(
        '%s%s%s',
        string.sub(m_date, 5),
        string.sub(m_date, 3, 4),
        string.sub(m_date, 1, 2)
    )
    return tonumber(m_date)
end

function apply_change_match_date()
    for i=0, MatchScheduleEditorForm.SchedulesScroll.ComponentCount-1 do
        local container = MatchScheduleEditorForm.SchedulesScroll.Component[i]
        for j=0, container.ComponentCount-1 do
            if string.sub(container.Component[j].Name, 0, 18) == 'MatchDateAddrLabel' then
                local new_val = match_date_to_value(
                    container[string.format('MatchDateEdit%d', i+1)].Text
                )
                if not new_val then
                    break
                end

                writeInteger(
                    tonumber(container.Component[j].Caption, 16) + 0x14,
                    new_val
                )
            end
        end
    end
    ShowMessage('Done.')
end

function clear_match_containers()
    for i=0, MatchScheduleEditorForm.SchedulesScroll.ComponentCount-1 do
        MatchScheduleEditorForm.SchedulesScroll.Component[0].destroy()
    end
end

function create_match_containers()
    local games_in_current_month = readInteger('fixturesData+8')
    if games_in_current_month == nil or games_in_current_month <= 0 then
        local txt = 'Open the in-game calendar in a month that contains matches. You can also try to exit calendar and enter there again'
        do_log(txt, 'ERROR')
        MatchScheduleExitClick(sender)
    end
    -- Fill GUI
    for i=0, games_in_current_month-1 do
        local m_index = readInteger(string.format('fixturesData+%X', 12+i*4)) * 0x28

        local fixtureList = readMultilevelPointer(readPointer('fixturesData'), {0x18, 0x58})
        local standingsList = readMultilevelPointer(readPointer('fixturesData'), {0x18, 0x80, 0x30})
        local fixture = readMultilevelPointer(fixtureList, {0x30}) + m_index
        local hometeam = standingsList + (readSmallInteger(fixture + 0x1A) * 0x28) -- HOMETEAM
        local awayteam = standingsList + (readSmallInteger(fixture + 0x1E) * 0x28) -- AWAYTEAM

        -- Container
        local panel_match_container = createPanel(MatchScheduleEditorForm.SchedulesScroll)
        panel_match_container.Name = string.format('MatchContainerPanel%d', i+1)
        panel_match_container.BevelOuter = bvNone
        panel_match_container.Caption = ''

        panel_match_container.Color = '0x00302825'
        panel_match_container.Width = 280
        panel_match_container.Height = 80
        panel_match_container.Left = 10
        panel_match_container.Top = 10 + 90*i

        -- Addr for apply changes
        local hidden_label = createLabel(panel_match_container)
        hidden_label.Name = string.format('MatchDateAddrLabel%d', i+1)
        hidden_label.Visible = false
        hidden_label.Caption = string.format('%X', fixture)


        -- Match Date Edit
        local match_date = createEdit(panel_match_container)
        match_date.Name = string.format('MatchDateEdit%d', i+1)
        match_date.Hint = 'Date format: DD/MM/YYYY'
        match_date.BorderStyle = bsNone
        match_date.Text = value_to_match_date(readInteger(fixture + 0x14))
        match_date.Color = '0x003A302C'
        match_date.Top = 0
        match_date.Left = 75
        match_date.Width = 130
        match_date.Font.Size = 14
        match_date.Font.Color = '0xFFFBF0'

        -- VS LABEL
        local vslabel = createLabel(panel_match_container)
        vslabel.Name = string.format('MatchLabel%d', i+1)
        vslabel.Caption = 'Vs.'
        vslabel.AutoSize = false
        vslabel.Width = 60
        vslabel.Height = 42
        vslabel.Left = 110
        vslabel.Top = 38
        vslabel.Font.Size = 26
        vslabel.Font.Color = '0xC0C0C0'

        -- Home Team Badge
        local badgeimg = createImage(panel_match_container)
        local ss_c = load_crest(readInteger(hometeam + 0x14))
        badgeimg.Picture.LoadFromStream(ss_c)
        ss_c.destroy()

        badgeimg.Name = string.format('MatchImageHT%d', i+1)
        badgeimg.Left = 0
        badgeimg.Top = 5
        badgeimg.Height = 75
        badgeimg.Width = 75
        badgeimg.Stretch = true

        -- Away Team Badge
        local badgeimg = createImage(panel_match_container)
        local ss_c = load_crest(readInteger(awayteam + 0x14))
        badgeimg.Picture.LoadFromStream(ss_c)
        ss_c.destroy()

        badgeimg.Name = string.format('MatchImageAT%d', i+1)
        badgeimg.Left = 205
        badgeimg.Top = 5
        badgeimg.Height = 75
        badgeimg.Width = 75
        badgeimg.Stretch = true
    end
end

function create_hotkeys_schedule_edit()

end

SCHEDULEEDIT_HOTKEYS_OBJECTS = {}
function create_hotkeys_schedule_edit()
    destroy_hotkeys_schedule_edit()
    if CFG_DATA.hotkeys.sync_with_game then
        table.insert(SCHEDULEEDIT_HOTKEYS_OBJECTS, createHotkey(MatchScheduleSyncImageClick, _G[CFG_DATA.hotkeys.sync_with_game]))
    end
end

function destroy_hotkeys_schedule_edit()
    for i=1,#SCHEDULEEDIT_HOTKEYS_OBJECTS do
        SCHEDULEEDIT_HOTKEYS_OBJECTS[i].destroy()
    end
    SCHEDULEEDIT_HOTKEYS_OBJECTS = {}
end
