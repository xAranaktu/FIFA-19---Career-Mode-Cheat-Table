
require 'lua/GUI/forms/settingsform/helpers';
-- MainForm Events

local new_cfg_data = {}

local HAS_UNSAVED_SETTINGS_CHANGES = false
-- Make window dragable
function SettingsFormTopPanelMouseDown(sender, button, x, y)
    SettingsForm.dragNow()
end

function SettingsFormShow(sender)
    new_cfg_data = deepcopy(CFG_DATA)
    -- Fill General
    SettingsForm.SelectCacheDirectoryDialog.InitialDir = string.gsub(CACHE_DIR, "/","\\")
    SettingsForm.CacheFilesDirEdit.Hint = CACHE_DIR
    SettingsForm.CacheFilesDirEdit.Text = CACHE_DIR
    SettingsForm.GUIOpacityEdit.Text = CFG_DATA.gui.opacity

    -- Fill Player Editor
    SettingsForm.SyncWithGameHotkeyEdit.Text = CFG_DATA.hotkeys.sync_with_game

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
    local scripts_ids = {1666}  -- Always expand 'Scripts'
    for i=0, SettingsForm.CTTreeview.Items.Count-1 do
        local is_selected = SettingsForm.CTTreeview.Items[i].MultiSelected
        if is_selected then
            table.insert(scripts_ids, SettingsForm.CTTreeview.Items[i].Data)
        end
    end

    new_cfg_data.auto_activate = scripts_ids
    save_changes_in_settingsform(new_cfg_data)
    showMessage('Settings has been saved.')
end

-- Editables

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

function SyncWithGameHotkeyEditChange(sender)
    new_cfg_data.hotkeys.sync_with_game = sender.Text
end
