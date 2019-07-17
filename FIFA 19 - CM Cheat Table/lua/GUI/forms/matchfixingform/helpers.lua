-- Match fixing
function clear_match_fixing_containers()
    for i=0, MatchFixingForm.MatchFixingScroll.ComponentCount-1 do
        MatchFixingForm.MatchFixingScroll.Component[0].destroy()
    end
end

function need_match_fixing_sync()
    if readInteger("arr_fixedGamesData") == MatchFixingForm.MatchFixingScroll.ComponentCount then
        return false
    end
    return true
end

local CallAfterDeleteFixedMatchTimer = createTimer(nil)
function call_after_delete_fixed_match()
    timer_setEnabled(CallAfterDeleteFixedMatchTimer, false)
    clear_match_fixing_containers()
    create_match_fixing_containers()
end

function delete_match_fix(sender)
    if need_match_fixing_sync() then
        ShowMessage("Close this and try again after 2s.")
        timer_onTimer(CallAfterDeleteFixedMatchTimer, call_after_delete_fixed_match)
        timer_setInterval(CallAfterDeleteFixedMatchTimer, 250)
        timer_setEnabled(CallAfterDeleteFixedMatchTimer, true)
        return
    end

    if messageDialog("Are you sure you want to delete this match fix?", mtInformation, mbYes,mbNo) == mrNo then
        return
    end

    local num_of_fixed_fixtures = readInteger("arr_fixedGamesData")
    local id, _ = string.gsub(sender.Name, "%D", '')
    id = tonumber(id)

    local bytecount = ((num_of_fixed_fixtures - id) * 16) + 16
    local bytes = readBytes(string.format('arr_fixedGamesData+%s', string.format('%X', id * 16 + 4)), bytecount, true)
    writeBytes(string.format('arr_fixedGamesData+%s', string.format('%X', (id-1) * 16 + 4)), bytes)

    writeInteger("arr_fixedGamesData", num_of_fixed_fixtures-1)
    timer_onTimer(CallAfterDeleteFixedMatchTimer, call_after_delete_fixed_match)
    timer_setInterval(CallAfterDeleteFixedMatchTimer, 250)
    timer_setEnabled(CallAfterDeleteFixedMatchTimer, true)
end


function create_match_fixing_container(i)
    local max_in_row = 3
    -- Container
    local caption = ""
    local row = i//max_in_row
    local row_i = (i - max_in_row * row)

    local match_fix_container = createPanel(MatchFixingForm.MatchFixingScroll)
    match_fix_container.Name = string.format('MatchFixContainerPanel%d', i+1)
    match_fix_container.BevelOuter = bvNone
    match_fix_container.Caption = ''

    match_fix_container.Color = '0x00302825'
    match_fix_container.Width = 250
    match_fix_container.Height = 125
    match_fix_container.Left = 10 + 250*row_i
    match_fix_container.Top = 60 + 125*row
    match_fix_container.OnClick = delete_match_fix

    -- Home Team Badge
    local home_teamid = readInteger(string.format('arr_fixedGamesData+%s', string.format('%X', i * 16 + 4)))

    local home_badgeimg = createImage(match_fix_container)
    local ss_c = load_crest(home_teamid)
    home_badgeimg.Picture.LoadFromStream(ss_c)
    ss_c.destroy()

    home_badgeimg.Name = string.format('FixingHomeTeamImage%d', i+1)
    home_badgeimg.Left = 10
    home_badgeimg.Top = 10
    home_badgeimg.Height = 75
    home_badgeimg.Width = 75
    home_badgeimg.Stretch = true
    home_badgeimg.OnClick = delete_match_fix

    -- Home TeamID Label
    local home_teamid_label = createLabel(match_fix_container)

    if home_teamid == 4294967295 then
        caption = 'Any'
    else
        caption = home_teamid
    end
    home_teamid_label.Name = string.format('FixingHomeTeamIDLabel%d', i+1)
    home_teamid_label.Visible = true
    home_teamid_label.Caption = caption
    home_teamid_label.AutoSize = false
    home_teamid_label.Width = 75
    home_teamid_label.Height = 19
    home_teamid_label.Left = 10
    home_teamid_label.Top = 95
    home_teamid_label.Font.Size = 11
    home_teamid_label.Font.Color = '0xC0C0C0'
    home_teamid_label.Alignment = 'taCenter'
    home_teamid_label.OnClick = delete_match_fix

    -- Away Team Badge
    local away_teamid = readInteger(string.format('arr_fixedGamesData+%s', string.format('%X', i * 16 + 8)))

    local away_badgeimg = createImage(match_fix_container)
    local ss_c = load_crest(away_teamid)
    away_badgeimg.Picture.LoadFromStream(ss_c)
    ss_c.destroy()

    away_badgeimg.Name = string.format('FixingAwayTeamImage%d', i+1)
    away_badgeimg.Left = 165
    away_badgeimg.Top = 10
    away_badgeimg.Height = 75
    away_badgeimg.Width = 75
    away_badgeimg.Stretch = true
    away_badgeimg.OnClick = delete_match_fix

    -- Away TeamID Label
    local away_teamid_label = createLabel(match_fix_container)
    if away_teamid == 4294967295 then
        caption = 'Any'
    else
        caption = away_teamid
    end
    
    away_teamid_label.Name = string.format('FixingAwayTeamIDLabel%d', i+1)
    away_teamid_label.Visible = true
    away_teamid_label.Caption = caption
    away_teamid_label.AutoSize = false
    away_teamid_label.Width = 75
    away_teamid_label.Height = 19
    away_teamid_label.Left = 165
    away_teamid_label.Top = 95
    away_teamid_label.Font.Size = 11
    away_teamid_label.Font.Color = '0xC0C0C0'
    away_teamid_label.Alignment = 'taCenter'
    away_teamid_label.OnClick = delete_match_fix

    -- Score Label
    local home_goals = readInteger(string.format('arr_fixedGamesData+%s', string.format('%X', i * 16 + 12)))
    local away_goals = readInteger(string.format('arr_fixedGamesData+%s', string.format('%X', i * 16 + 16)))
    local score_label = createLabel(match_fix_container)
    score_label.Name = string.format('FixingScoreResultLabel%d', i+1)
    score_label.Visible = true
    score_label.Caption = string.format("%d:%d", home_goals, away_goals)
    score_label.AutoSize = false
    score_label.Width = 60
    score_label.Height = 19
    score_label.Left = 95
    score_label.Top = 40
    score_label.Font.Size = 12
    score_label.Font.Color = '0xC0C0C0'
    score_label.Alignment = 'taCenter'
    score_label.OnClick = delete_match_fix
end

function create_match_fixing_containers()
    local num_of_fixed_fixtures = readInteger("arr_fixedGamesData")

    if num_of_fixed_fixtures <= 0 then
        return
    end

    for i=0, num_of_fixed_fixtures-1 do
        create_match_fixing_container(i)
    end
end

-- Fav Teams

function clear_fav_teams_containers()
    for i=0, MatchFixingForm.MatchFixingFavScroll.ComponentCount-1 do
        MatchFixingForm.MatchFixingFavScroll.Component[0].destroy()
    end
end

local CallAfterDeleteTimer = createTimer(nil)
function call_after_delete()
    timer_setEnabled(CallAfterDeleteTimer, false)
    clear_fav_teams_containers()
    create_fav_teams_containers()
    do_log("Deleted team for favourite teams", "INFO")
end

function delete_fav_team(sender)
    if messageDialog("Are you sure you want to delete this team from your favourite teams?", mtInformation, mbYes,mbNo) == mrNo then
        return
    end

    local fav_teams = readInteger("arr_fixedGamesAlwaysWin")
    local id, _ = string.gsub(sender.Name, "%D", '')
    id = tonumber(id)

    if type(CFG_DATA.fav_teams) == 'table' then
        local tid = tonumber(
            MatchFixingForm.MatchFixingFavScroll[string.format('FavTeamContainerPanel%d', id)][string.format('FavTeamIDLabel%d', id)].Caption
        )
        local new_fav_teams = {}
        for i, val in ipairs(CFG_DATA.fav_teams) do
            if val ~= tid then
                table.insert(new_fav_teams, val)
            end
        end
        CFG_DATA.fav_teams = new_fav_teams
        save_cfg()
    end

    local bytecount = ((fav_teams - id) * 4) + 4
    local bytes = readBytes(string.format('arr_fixedGamesAlwaysWin+%s', string.format('%X', id * 4 + 4)), bytecount, true)
    writeBytes(string.format('arr_fixedGamesAlwaysWin+%s', string.format('%X', id * 4)), bytes)

    writeInteger("arr_fixedGamesAlwaysWin", fav_teams-1)
    timer_onTimer(CallAfterDeleteTimer, call_after_delete)
    timer_setInterval(CallAfterDeleteTimer, 250)
    timer_setEnabled(CallAfterDeleteTimer, true)
end

function create_fav_teams_container(i, teamid)
    local max_in_row = 8
    -- Container
    local row = i//max_in_row
    local row_i = (i - max_in_row * row)

    local fav_team_container = createPanel(MatchFixingForm.MatchFixingFavScroll)
    fav_team_container.Name = string.format('FavTeamContainerPanel%d', i+1)
    fav_team_container.BevelOuter = bvNone
    fav_team_container.Caption = ''

    fav_team_container.Color = '0x00302825'
    fav_team_container.Width = 100
    fav_team_container.Height = 100
    fav_team_container.Left = 10 + 100*row_i
    fav_team_container.Top = 60 + 110*row
    fav_team_container.OnClick = delete_fav_team

    -- Team Badge
    if teamid == nil then
        teamid = readInteger(string.format('arr_fixedGamesAlwaysWin+%s', string.format('%X', i * 4 + 4)))
    end

    local badgeimg = createImage(fav_team_container)
    local ss_c = load_crest(teamid)
    badgeimg.Picture.LoadFromStream(ss_c)
    ss_c.destroy()

    badgeimg.Name = string.format('FavTeamImage%d', i+1)
    badgeimg.Left = 12
    badgeimg.Top = 0
    badgeimg.Height = 75
    badgeimg.Width = 75
    badgeimg.Stretch = true
    badgeimg.OnClick = delete_fav_team

    -- TeamID
    local teamid_label = createLabel(fav_team_container)
    teamid_label.Name = string.format('FavTeamIDLabel%d', i+1)
    teamid_label.Visible = true
    teamid_label.Caption = teamid
    teamid_label.AutoSize = false
    teamid_label.Width = 100
    teamid_label.Height = 19
    teamid_label.Left = 0
    teamid_label.Top = 80
    teamid_label.Font.Size = 11
    teamid_label.Font.Color = '0xC0C0C0'
    teamid_label.Alignment = 'taCenter'
    teamid_label.OnClick = delete_fav_team
end
function create_fav_teams_containers()
    local fav_teams = readInteger("arr_fixedGamesAlwaysWin")

    if fav_teams <= 0 then
        return
    end

    for i=0, fav_teams-1 do
        create_fav_teams_container(i)
    end
end
