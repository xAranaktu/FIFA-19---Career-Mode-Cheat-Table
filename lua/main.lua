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
require 'lua/GUI/forms/settingsform/events';

-- LOGGER
LOGGER = init_logger()
do_log('New session started', 'INFO')


-- DEFAULT GLOBALS, better leave it as is

FIFA_SETTINGS_DIR = string.format(
    "%s/Users/%s/Documents/FIFA %s/",
    os.getenv('HOMEDRIVE'), os.getenv('USERNAME'), FIFA
);
DATA_DIR = FIFA_SETTINGS_DIR .. 'Cheat Table/data/';
CONFIG_FILE_PATH = DATA_DIR .. 'config.ini'; --> 'path to config.ini file 
OFFSETS_FILE_PATH = DATA_DIR .. 'offsets.ini'; --> 'path to offsets.ini file
FORMS = {
    MainWindowForm, PlayersEditorForm, SettingsForm
}
SETTINGS_INDEX = 0

-- DEFAULT GLOBALS, may be overwritten in load_cfg()
CACHE_DIR = FIFA_SETTINGS_DIR .. 'Cheat Table/cache/';
DEBUG_MODE = false

-- end

-- start code
-- Activate "GUI" script
ADDR_LIST.getMemoryRecordByID(CT_MEMORY_RECORDS['GUI_SCRIPT']).Active = true

-- Check version of Cheat Table and Cheat Engine
check_ce_version()
check_ct_version()

AOB_DATA = load_aobs()
CFG_DATA = load_cfg()
OFFSETS_DATA = load_offsets()

if getOpenedProcessID() == 0 then
    MainWindowForm.bringToFront()
    AutoAttachTimer = createTimer(nil)
    timer_onTimer(AutoAttachTimer, auto_attach_to_process)
    timer_setInterval(AutoAttachTimer, 1000)
    timer_setEnabled(AutoAttachTimer, true)
else
    do_log('Restart required, getOpenedProcessID != 0', 'ERROR')
    update_status_label("Restart FIFA and Cheat Engine.")
end
-- end

-- After attach
function start()
    update_status_label("Attached to the game process.")
    -- update_offsets()
    -- save_cfg()
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
