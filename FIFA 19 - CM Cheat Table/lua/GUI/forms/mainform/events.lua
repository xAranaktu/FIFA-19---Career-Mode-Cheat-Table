require 'lua/GUI/consts';
require 'lua/GUI/forms/mainform/consts';
require 'lua/GUI/forms/mainform/helpers';
-- MainForm Events

-- Make window dragable
function MainTopPanelMouseDown(sender, button, x, y)
    MainWindowForm.dragNow()
end

-- OnShow -> MainMenuForm
function MainMenuFormShow(sender)
    -- Load Img if attached to the game process
    if BASE_ADDRESS then
        local stream = load_headshot(
            tonumber(ADDR_LIST.getMemoryRecordByID(CT_MEMORY_RECORDS['PLAYERID']).Value),
            tonumber(ADDR_LIST.getMemoryRecordByID(CT_MEMORY_RECORDS['HEADTYPECODE']).Value),
            tonumber(ADDR_LIST.getMemoryRecordByID(CT_MEMORY_RECORDS['HAIRCOLORCODE']).Value)
        )
        MainWindowForm.PlayersEditorImg.Picture.LoadFromStream(stream)
        stream.destroy()
    end
end

function MainFormRemoveLoadingPanel()
    MainWindowForm.LoadingPanel.Visible = false

    -- load headshot
    local stream = load_headshot(
        tonumber(ADDR_LIST.getMemoryRecordByID(CT_MEMORY_RECORDS['PLAYERID']).Value),
        tonumber(ADDR_LIST.getMemoryRecordByID(CT_MEMORY_RECORDS['HEADTYPECODE']).Value),
        tonumber(ADDR_LIST.getMemoryRecordByID(CT_MEMORY_RECORDS['HAIRCOLORCODE']).Value)
    )
    MainWindowForm.PlayersEditorImg.Picture.LoadFromStream(stream)
    stream.destroy()
end


-- Minimize
function MainMinimizeClick(sender)
    MainWindowForm.WindowState = "wsMinimized" 
end

-- Close
function MainExitClick(sender)
    -- Deactivate scripts on Exit while in DEBUG MODE
    if DEBUG_MODE then
        deactive_all(getAddressList().getMemoryRecordByDescription('Scripts'))
    end

    -- Deactivate "GUI" script
    ADDR_LIST.getMemoryRecordByID(CT_MEMORY_RECORDS['GUI_SCRIPT']).Active = false
end

-- Show Settings Form
function MainSettingsClick(sender)
    SETTINGS_INDEX = 0
    SettingsForm.show()
end

-- Show Players Editor Form
function PlayersEditorBtnClick(sender)
    MainWindowForm.hide()
    PlayersEditorForm.show()
end
function PlayersEditorLabelClick(sender)
    MainWindowForm.hide()
    PlayersEditorForm.show()
end
function PlayersEditorImgClick(sender)
    MainWindowForm.hide()
    PlayersEditorForm.show()
end

-- Patreon Button
function PatreonClick(sender)
    shellExecute("https://www.patreon.com/xAranaktu")
end

-- Discord Button
function DiscordClick(sender)
    shellExecute("https://discordapp.com/invite/cbQePsR")
end
