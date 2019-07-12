
require 'lua/GUI/forms/settingsform/helpers';
require 'lua/GUI/forms/mainform/helpers';
-- MainForm Events

local new_cfg_data = {}

local HAS_UNSAVED_SETTINGS_CHANGES = false
-- Make window dragable
function SettingsFormTopPanelMouseDown(sender, button, x, y)
    SettingsForm.dragNow()
end


function SettingsAlwaysOnTopOnClick(sender)
    if sender.FormStyle == "fsNormal" then
        sender.AlwaysOnTop.Visible = false
        sender.AlwaysOnTopOn.Visible = true
        sender.FormStyle = "fsSystemStayOnTop"
    else
        sender.AlwaysOnTop.Visible = true
        sender.AlwaysOnTopOn.Visible = false
        sender.FormStyle = "fsNormal"
    end
end
function SettingsResizeMouseDown(sender, button, x, y)

end
function SettingsResizeMouseMove(sender, x, y)

end
function SettingsResizeMouseUp(sender, button, x, y)

end

function SettingsFormShow(sender)
    new_cfg_data = deepcopy(CFG_DATA)
    -- Fill General
    SettingsForm.SelectCacheDirectoryDialog.InitialDir = string.gsub(CACHE_DIR, "/","\\")
    SettingsForm.CacheFilesDirEdit.Hint = CACHE_DIR
    SettingsForm.CacheFilesDirEdit.Text = CACHE_DIR
    SettingsForm.GUIOpacityEdit.Text = CFG_DATA.gui.opacity

    SettingsForm.SyncWithGameHotkeyEdit.Text = CFG_DATA.hotkeys.sync_with_game
    SettingsForm.SearchPlayerByIDHotkeyEdit.Text = CFG_DATA.hotkeys.search_player_by_id

    if CFG_DATA.flags then
        if CFG_DATA.flags.hide_ce_scanner == nil then
            CFG_DATA.flags.hide_ce_scanner = true
        end

        if CFG_DATA.flags.hide_ce_scanner then
            SettingsForm.HideCEMemScannerCB.State = 1
        end

        if CFG_DATA.flags.check_for_update == nil then
            CFG_DATA.flags.check_for_update = true
            
        end

        if CFG_DATA.flags.check_for_update then
            SettingsForm.SettingsCheckForUpdateCB.State = 1
        end

        if CFG_DATA.flags.only_check_for_free_update == nil then
            CFG_DATA.flags.only_check_for_free_update = false
        end

        if CFG_DATA.flags.only_check_for_free_update then
            SettingsForm.SettingsCheckForFreeUpdateCB.State = 1
        end
    end

    -- Fill Auto Activation
    SettingsForm.CTTreeview.Items.clear()
    local root = SettingsForm.CTTreeview.Items.Add('Scripts')
    root.hasChildren = true
    root.Expanded = true
    FillScriptsTree(ADDR_LIST.getMemoryRecordByDescription('Scripts'), root)

    -- Show correct panel
    ActivateSection(SETTINGS_INDEX)
end

function SettingsSectionsListBoxSelectionChange(sender, user)
    ActivateSection(sender.getItemIndex())
end
function CacheFilesDirEditClick(sender)
    SettingsForm.SelectCacheDirectoryDialog.execute()
end


function SettingsMinimizeClick(sender)
    SettingsForm.WindowState = "wsMinimized" 
end
function SettingsExitClick(sender)
    SettingsForm.hide()
end
function SettingsSaveSettingsClick(sender)
    -- Auto activate script ids
    local scripts_ids = {2995}  -- Always expand 'Scripts'
    for i=0, SettingsForm.CTTreeview.Items.Count-1 do
        local is_selected = SettingsForm.CTTreeview.Items[i].MultiSelected
        if is_selected then
            table.insert(scripts_ids, SettingsForm.CTTreeview.Items[i].Data)
        end
    end

    new_cfg_data.auto_activate = scripts_ids

    new_cfg_data.hotkeys.sync_with_game = SettingsForm.SyncWithGameHotkeyEdit.Text
    new_cfg_data.hotkeys.search_player_by_id = SettingsForm.SearchPlayerByIDHotkeyEdit.Text

    new_cfg_data.flags.hide_ce_scanner = SettingsForm.HideCEMemScannerCB.State == 1

    new_cfg_data.flags.check_for_update = SettingsForm.SettingsCheckForUpdateCB.State == 1
    new_cfg_data.flags.only_check_for_free_update = SettingsForm.SettingsCheckForFreeUpdateCB.State == 1

    save_changes_in_settingsform(new_cfg_data)
    showMessage('Settings has been saved.')
end

-- Editables
function update_unsaved_settings(sender)
    HAS_UNSAVED_SETTINGS_CHANGES = true
end

function SelectCacheDirectoryDialogShow(sender)
    HAS_UNSAVED_SETTINGS_CHANGES = true
    local dir = string.gsub(SettingsForm.SelectCacheDirectoryDialog.FileName, '\\', '/')
    SettingsForm.CacheFilesDirEdit.Hint = dir
    SettingsForm.CacheFilesDirEdit.Text = dir

    new_cfg_data.directories.cache_dir = dir .. '/'
end

function GUIOpacityEditChange(sender)
    HAS_UNSAVED_SETTINGS_CHANGES = true
    local opacity = tonumber(sender.Text)
    if not opacity then return end

    if opacity < 100 then
        opacity = 100
        sender.Text = opacity
    elseif opacity > 255 then
        opacity = 255
        sender.Text = opacity
    end

    for i = 1, #FORMS do
        local form = FORMS[i]

        -- Update opacity of all forms
        form.AlphaBlend = true
        form.AlphaBlendValue = opacity
    end

    new_cfg_data.gui.opacity = opacity
end

-- CheckBox
function HideCEMemScannerCBChange(sender)
    if sender.State == 1 then
        HIDE_CE_SCANNER = true
    else 
        HIDE_CE_SCANNER = false
    end
    set_ce_mem_scanner_state()
end

-- Buttons
function RestoreDefaultSettingsButtonClick(sender)
    if messageDialog("Are you sure you want to restore default settings?\nThis will also clear your cached files\nCheat Table and FIFA restart will be required.", mtInformation, mbYes,mbNo) == mrNo then
        return
    end
    do_log('Restore Default Settings')
    delete_directory(string.gsub(DATA_DIR, "/","\\"):sub(1,-2))
    delete_directory(string.gsub(CACHE_DIR, "/","\\"):sub(1,-2))
    showMessage('Default settings restored. Please, restart FIFA and Cheat Engine.')
end

function ClearCacheButtonClick(sender)
    if messageDialog("Are you sure you want to delete all cached files?", mtInformation, mbYes,mbNo) == mrNo then
        return
    end
    do_log('Clear Cached Files')
    delete_directory(string.gsub(CACHE_DIR, "/","\\"):sub(1,-2))

    create_dirs()

    showMessage('All cached files has been deleted.')
end