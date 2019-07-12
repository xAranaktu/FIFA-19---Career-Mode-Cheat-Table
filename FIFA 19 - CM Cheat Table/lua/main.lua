-- requirements section

-- Lua INI Parser
-- https://github.com/Dynodzzo/Lua_INI_Parser
LIP = require 'lua/requirements/LIP';


-- CONSTS
require 'lua/consts';

-- Helper functions
require 'lua/helpers';

-- GUI Events
require 'lua/GUI/forms/mainform/events';
require 'lua/GUI/forms/playerseditorform/events';
require 'lua/GUI/forms/matchscheduleeditorform/events';
require 'lua/GUI/forms/settingsform/events';
require 'lua/GUI/forms/transferplayersform/events';
require 'lua/GUI/forms/updateform/events';

-- Check Updates
require 'lua/GUI/forms/updateform/helpers';

do_log('New session started', 'INFO')

-- DEFAULT GLOBALS, better leave it as is
HOMEDRIVE = os.getenv('HOMEDRIVE') or os.getenv('SystemDrive') or 'C:'

FIFA_SETTINGS_DIR = string.format(
    "%s/Users/%s/Documents/FIFA %s/",
    HOMEDRIVE, os.getenv('USERNAME'), FIFA
);
DATA_DIR = FIFA_SETTINGS_DIR .. 'Cheat Table/data/';
CONFIG_FILE_PATH = DATA_DIR .. 'config.ini'; --> 'path to config.ini file 
OFFSETS_FILE_PATH = DATA_DIR .. 'offsets.ini'; --> 'path to offsets.ini file
FORMS = {
    MainWindowForm, PlayersEditorForm, MatchScheduleEditorForm, SettingsForm, TransferPlayersForm, UpdateForm
}
SETTINGS_INDEX = 0
-- DEFAULT GLOBALS, better leave it as is


-- DEFAULT GLOBALS, may be overwritten in load_cfg()
CACHE_DIR = FIFA_SETTINGS_DIR .. 'Cheat Table/cache/';
DEBUG_MODE = false

-- end

-- start code
-- Activate "GUI" script
MainWindowForm.LoadingPanel.Visible = true
MainWindowForm.LoadingPanel.Caption = 'Loading data...'
update_status_label("Waiting for FIFA 19...")
ADDR_LIST.getMemoryRecordByID(CT_MEMORY_RECORDS['GUI_SCRIPT']).Active = true

-- Check version of Cheat Table and Cheat Engine
check_ce_version()
check_ct_version()

AOB_DATA = load_aobs()
CFG_DATA = load_cfg()
OFFSETS_DATA = load_offsets()

CHECK_CT_UPDATE = check_for_ct_update()

if CHECK_CT_UPDATE then
    function newMainOnShow(sender)
        pcall(DEFAULT_ON_SHOW, sender)
        UpdateForm.FormStyle = "fsSystemStayOnTop"
    end

    DEFAULT_ON_SHOW = getMainForm().OnShow
    getMainForm().OnShow = newMainOnShow
    UpdateForm.show()
else
    before_start()
end

-- After attach
function start()
    update_status_label("Attached to the game process.")
    -- "FIFA19.exe"+06267F98
    -- MM_TAB_HOME
    -- MM_TAB_PLAY
    -- MM_TAB_ONLINE
    local screenid_aob = tonumber(get_validated_address('AOB_screenID'), 16)
    SCREEN_ID_PTR = byteTableToDword(readBytes(screenid_aob+4, 4, true)) + screenid_aob + 8
    logScreenID()

    -- Don't activate too early
    do_log("Waiting for valid screen")
    -- if getScreenID() == nil then
    --     print("Cheat Engine is waiting until you enter main menu in game. It may stop responding until you do that. Please, don't report this problem. It's working that way on purpose")
    --     sleep(5000)
    -- end
    
    while getScreenID() == nil do
        ShowMessage('You are not in main menu in game. Enter there and close this window')
        sleep(1500)
    end
    logScreenID()

    -- update_offsets()
    save_cfg()
    autoactivate_scripts()
    
    for i = 1, #FORMS do
        local form = FORMS[i]
        -- remove borders
        form.BorderStyle = bsNone

        -- update opacity
        form.AlphaBlend = true
        form.AlphaBlendValue = CFG_DATA.gui.opacity or 255
    end
    MainFormRemoveLoadingPanel()
    do_log('Ready to use.', 'INFO')
    update_status_label("Program is ready to use.")
end
-- end
