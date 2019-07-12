function ActivateSection(index)
    local Panels = {
        'GeneralSettingsPanel',
        'PlayerEditorSettingsPanel',
        'AutoActivationSettingsPanel',
        'CTUpdatesSettingsPanel'
    }
    SettingsForm.SettingsSectionsListBox.setItemIndex(index)
    for i=1, #Panels do
        if index == i-1 then
            SettingsForm[Panels[i]].Visible = true
        else
            SettingsForm[Panels[i]].Visible = false
        end
    end
end

function FillScriptsTree(record, tn)
    local next_node = nil
    for i=0, record.Count-1 do
        if record.Child[i].Type == 0 or record.Child[i].Type == 11 then
            -- print(record.Child[i].Description)
            next_node = tn.add(record.Child[i].Description)
            next_node.Data = record.Child[i].ID
            if record.Child[i].Active then
                next_node.MultiSelected = true
            end
        else
            next_node = tn
        end
        if record.Child[i].Count > 0 then
            next_node.hasChildren = true
            if record.Child[i].Active then
                next_node.Expanded = true
            end
            FillScriptsTree(record.Child[i], next_node)
        end
    end
end

function save_changes_in_settingsform(new_cfg_data)
    CFG_DATA = new_cfg_data

    if new_cfg_data.directories.cache_dir ~= CACHE_DIR then
        local old_cache = string.gsub(CACHE_DIR, "/","\\"):sub(1,-2)
        local copy_cmd = string.format(
            'xcopy /s "%s" "%s"', 
            old_cache,
            string.gsub(new_cfg_data.directories.cache_dir, "/","\\"):sub(1,-2)
        )

        execute_cmd(copy_cmd)
        delete_directory(old_cache)
    end
    
    save_cfg()
end