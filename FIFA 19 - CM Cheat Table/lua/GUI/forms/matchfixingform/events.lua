require 'lua/helpers';
require 'lua/GUI/consts';
require 'lua/GUI/helpers';
require 'lua/GUI/forms/matchfixingform/helpers'

-- Make window dragable
function MatchFixingTopPanelMouseDown(sender, button, x, y)
    MatchFixingForm.dragNow()
end

-- EVENTS
function MatchFixingMinimizeClick(sender)
    MatchFixingForm.WindowState = "wsMinimized" 
end
function MatchFixingExitClick(sender)
    MatchFixingForm.close()
    MainWindowForm.show()
end
function MatchFixingSettingsClick(sender)
    SettingsForm.show()
end

function MatchFixingFormClose(sender)
    return caHide
end

function MatchFixingSyncImageClick(sender)
    clear_fav_teams_containers()
    clear_match_fixing_containers()
    create_fav_teams_containers()
    create_match_fixing_containers()
end

function MatchFixingFormShow(sender)
    if not ADDR_LIST.getMemoryRecordByID(CT_MEMORY_RECORDS['MATCHFIXING_SCRIPT']).Active then
        ADDR_LIST.getMemoryRecordByID(CT_MEMORY_RECORDS['MATCHFIXING_SCRIPT']).Active = true
    end

    if readInteger("arr_fixedGamesAlwaysWin") == nil then
        MatchFixingForm.close()
        MainWindowForm.show()
        return
    end
    clear_fav_teams_containers()
    clear_match_fixing_containers()
    create_fav_teams_containers()
    create_match_fixing_containers()

    MatchFixingForm.FixingTypeListBox.setItemIndex(0)
    FixingTypeListBoxSelectionChange(MatchFixingForm.FixingTypeListBox)
end

function MatchFixingAddFavTeamLabelClick(sender)
    MatchFixingAddFavTeamBtnClick(sender)
end
function MatchFixingAddFavTeamBtnClick(sender)
    local fav_teams = readInteger("arr_fixedGamesAlwaysWin")
    if fav_teams >= 60 then
        do_log("Add Fav team\nReach maximum number of favourite teams. 60 is the limit.", 'ERROR')
        return
    end

    local teamid = inputQuery("Add Fav team", "Enter teamid:", "0")
    if not teamid or tonumber(teamid) <= 0 then
        do_log(string.format("Add Fav team\nEnter Valid TeamID\n %s is invalid.", teamid), 'ERROR')
        return
    end
    do_log(string.format("New fav team: %s", teamid), 'INFO')

    writeInteger("arr_fixedGamesAlwaysWin", fav_teams + 1)

    writeInteger(
        string.format('arr_fixedGamesAlwaysWin+%s', string.format('%X', (fav_teams) * 4 + 4)),
        teamid
    )

    create_fav_teams_container(fav_teams, teamid)

    if type(CFG_DATA.fav_teams) == 'table' then
        table.insert(CFG_DATA.fav_teams, tonumber(teamid))
    else
        CFG_DATA.fav_teams = { tonumber(teamid) }
    end
    save_cfg()

    do_log(string.format("Success ID: %d", fav_teams + 1), 'INFO')
end

function MatchFixingNewMatchFixLabelClick(sender)
    MatchFixingNewMatchFixBtnClick(sender)
end
function MatchFixingNewMatchFixBtnClick(sender)
    if need_match_fixing_sync() then
        ShowMessage("Close this and try again after 2s.")
        clear_match_fixing_containers()
        create_match_fixing_containers()
        return
    end

    local fixed_games = readInteger("arr_fixedGamesData")
    if fixed_games >= 60 then
        do_log("Add Fixed Match\nReach maximum number of fixed games. 60 is the limit.", 'ERROR')
        return
    end

    local home_teamid = inputQuery("Match Fixing", "Enter home teamid:\nLeave 0 for any team.", "0")
    if (home_teamid == "0" or home_teamid == '') then
        home_teamid = 4294967295
    elseif tonumber(home_teamid) == nil then
        do_log(string.format("Value must be a number, %s is invalid", home_teamid), 'ERROR')
        return
    end

    local away_teamid = inputQuery("Match Fixing", "Enter away teamid:\nLeave 0 for any team.", "0")
    if (away_teamid == "0" or away_teamid == '') then
        away_teamid = 4294967295
    elseif tonumber(away_teamid) == nil then
        do_log(string.format("Value must be a number, %s is invalid", away_teamid), 'ERROR')
        return
    end

    local home_score = inputQuery("Match Fixing", "Enter num of goals scored by home team", "0")
    if tonumber(home_score) == nil then
        do_log(string.format("Value must be a number, %s is invalid", home_score), 'ERROR')
        return
    end

    local away_score = inputQuery("Match Fixing", "Enter num of goals scored by away team", "0")
    if tonumber(away_score) == nil then
        do_log(string.format("Value must be a number, %s is invalid", away_score), 'ERROR')
        return
    end

    do_log(string.format("New match fixing: %s %s:%s %s", home_teamid, home_score, away_score, away_teamid), 'INFO')

    writeInteger("arr_fixedGamesData", fixed_games + 1)

    writeInteger(
        string.format('arr_fixedGamesData+%s', string.format('%X', (fixed_games) * 16 + 4)),
        home_teamid
    )
    writeInteger(
        string.format('arr_fixedGamesData+%s', string.format('%X', (fixed_games) * 16 + 8)),
        away_teamid
    )
    writeInteger(
        string.format('arr_fixedGamesData+%s', string.format('%X', (fixed_games) * 16 + 12)),
        home_score
    )
    writeInteger(
        string.format('arr_fixedGamesData+%s', string.format('%X', (fixed_games) * 16 + 16)),
        away_score
    )
    create_match_fixing_container(fixed_games)
    do_log(string.format("Success ID: %d", fixed_games + 1), 'INFO')
end

function FixingTypeListBoxSelectionChange(sender, user)
    local Panels = {
        'MatchFixingContainer',
        'MatchFixingFavContainer',
    }
    for i=1, #Panels do
        if sender.ItemIndex == i-1 then
            MatchFixingForm[Panels[i]].Visible = true
        else
            MatchFixingForm[Panels[i]].Visible = false
        end
    end
end

function MatchFixingFavTeamHelpClick(sender)
ShowMessage([[
Favourite teams

Teams defined as a favourite will always win their games by 3:0.

If you got more than one favourite team and these teams will meet each other then the home team will always win.

You can only define 60 favourite teams at this moment.
]])
end