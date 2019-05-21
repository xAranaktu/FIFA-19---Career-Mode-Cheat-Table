require 'lua/helpers';
require 'lua/GUI/consts';
require 'lua/GUI/helpers';
require 'lua/GUI/forms/matchscheduleeditorform/helpers'

-- Make window dragable
function MatchScheduleTopPanelMouseDown(sender, button, x, y)
    MatchScheduleEditorForm.dragNow()
end

-- EVENTS

function MatchScheduleMinimizeClick(sender)
    MatchScheduleEditorForm.WindowState = "wsMinimized" 
end
function MatchScheduleExitClick(sender)
    clear_match_containers()
    MatchScheduleEditorForm.close()
    MainWindowForm.show()
end
function MatchScheduleSyncImageClick(sender)
    clear_match_containers()
    create_match_containers()
end
function MatchScheduleSettingsClick(sender)
    SettingsForm.show()
end

function ScheduleEditorApplyChangesBtnClick(sender)
    apply_change_match_date()
end
function ScheduleEditorApplyChangesLabelClick(sender)
    apply_change_match_date()
end

function MatchScheduleFormClose(sender)
    destroy_hotkeys_schedule_edit()
    return caHide
end

function MatchScheduleFormShow(sender)
    if not ADDR_LIST.getMemoryRecordByID(CT_MEMORY_RECORDS['SCHEDULEEDITOR_SCRIPT']).Active then
        local txt = string.format(
            'To use schedule editor you need to activate %s script first',
            ADDR_LIST.getMemoryRecordByID(CT_MEMORY_RECORDS['SCHEDULEEDITOR_SCRIPT']).Description
        )
        do_log(txt, 'ERROR')
        MatchScheduleExitClick(sender)
        return
    end

    clear_match_containers()
    create_match_containers(games_in_current_month)
    -- Create Hotkeys
    create_hotkeys_schedule_edit()
end