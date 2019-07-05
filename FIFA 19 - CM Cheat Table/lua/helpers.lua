require 'lua/commons';
-- helpers

function execute_cmd(cmd)
    do_log(string.format('execute cmd -  %s', cmd))
    do_log(string.format('execute cmd result - %s', io.popen(cmd):read'*l'))
end

-- Check Cheat Engine Version
function check_ce_version()
    local ce_version = getCEVersion()
    do_log(string.format('Cheat engine version: %f', ce_version))
    -- if(ce_version < 6.8) then
    --     do_log('Cheat Table requires Cheat Engine version 6.8 or above', "WARNING")
    --     # assert(false, 'Cheat Table requires Cheat Engine version 6.8.3 or above')
    -- end
    MainWindowForm.LabelCEVer.Caption = ce_version
end

-- Check Cheat Table Version
function check_ct_version()
    local ver = string.gsub(ADDR_LIST.getMemoryRecordByID(2794).Description, 'v', '')

    do_log(string.format('Cheat table version: %s', ver))
    MainWindowForm.LabelCTVer.Caption = ver -- update version in GUI
end

function create_dirs()
    local cmds = {
        "mkdir " .. '"' .. string.gsub(DATA_DIR, "/","\\") .. '"',
        "ECHO A | xcopy cache " .. '"' .. string.gsub(FIFA_SETTINGS_DIR .. 'Cheat Table/cache', "/","\\") .. '" /E /i',
    }
    for i=1, #cmds do
        execute_cmd(cmds[i])
    end

end

local time = os.date("*t")
function do_log(text, level)
    if level == nil then
        level = 'INFO'
    end

    if DEBUG_MODE then
        print(string.format("[ %s ] %s - %s", level, os.date("%c", os.time()), text))
    else
        if level == 'ERROR' then
            showMessage(text)
        end
        logger, err = io.open("logs/log_".. string.format("%02d-%02d-%02d", time.year, time.month, time.day) .. ".txt", "a+")
        if logger == nil then
            -- log in console if file can't be open
            DEBUG_MODE = true
            print(io.popen"cd":read'*l')
            print(string.format("[ %s ] %s - %s", level, os.date("%c", os.time()), 'Error opening file: ' .. err))
        else
            logger:write(string.format("[ %s ] %s - %s\n", level, os.date("%c", os.time()), text))
            io.close(logger)
        end
    end
end

function setup_internal_calls()
    getBaseScriptsPtr()
    getIntFunctionsAddrs()
end

function getBaseScriptsPtr()
    local base_aob = tonumber(get_validated_address('AOB_SCRIPTS_BASE_PTR'), 16)
    writeQword(
        "ptrBaseScripts",
        byteTableToDword(readBytes(base_aob+10, 4, true)) + base_aob + 14
    )
end

function getIntFunctionsAddrs()
    local funcGenReport_aob = tonumber(get_validated_address('AOB_F_GEN_REPORT'), 16)
    writeQword(
        "funcGenReport",
        byteTableToDword(readBytes(funcGenReport_aob+4, 4, true)) + funcGenReport_aob + 8
    )
end

function readMultilevelPointer(base_addr, offsets)
    if base_addr == 0 then
        return 0
    end

    for i=1, #offsets do
        base_addr = readPointer(base_addr+offsets[i])
        if base_addr == 0 then
            return 0
        end
    end
    return base_addr
end

function get_offset(base_addr, addr)
    return string.format('%X',tonumber(addr, 16) - base_addr)
end

function get_address_with_offset(base_addr, offset)
    -- Offset saved in file may contains only numbers. We want to have string
    if type(offset) == 'number' then
        offset = tostring(offset)
    end
    return string.format('%X',tonumber(offset, 16) + base_addr)
end

function get_validated_address(name, module_name, section)
    if name == nil then return end

    if module_name then
        name = string.format('%s.AOBS.%s', section, name)
        local res = AOBScanModule(
            getfield(string.format('AOB_DATA.%s', name)),
            module_name,
            module_size
        )
        return res[0]
    end
    
    check_process()  -- Check if we are correctly attached to the game

    local inject_at = nil
    if getfield(string.format('OFFSETS_DATA.offsets.%s', name)) ~= nil then
        inject_at = verify_offset(name)
    end
    if not inject_at then
        if not update_offset(name, true) then assert(false, string.format('Could not find valid offset for', name)) end
        inject_at = get_address_with_offset(BASE_ADDRESS, getfield(string.format('OFFSETS_DATA.offsets.%s', name)))
    end
    
    return inject_at
end

-- obsolete
function get_md5_version()
    if CFG_DATA.game.md5 ~= nil then
        return CFG_DATA.game.md5
    else
        return md5memory(BASE_ADDRESS, FIFA_MODULE_SIZE)
    end
end

-- Check game version
-- obsolete
function game_version_has_changed()
    local md5 = get_md5_version()
    if CFG_DATA.game.md5 == nil then
        CFG_DATA.game.md5 = md5
        save_cfg()
        return false
    end

    local new_md5 = md5memory(BASE_ADDRESS, FIFA_MODULE_SIZE)
    if new_md5 ~= md5 then
        showMessage("Game version has changed")
        CFG_DATA.game.md5 = new_md5
        save_cfg()
        return true
    else
        return false
    end
end

-- AOBScanModule
-- https://www.cheatengine.org/forum/viewtopic.php?p=5621132&sid=c4dd9b1a4d0ddabf23f99b8f9bfe5f4e
function AOBScanModule(aob, module_name, module_size)
    if module_name == nil then
        module_name = FIFA_PROCESS_NAME
    end

    if module_size == nil then
        module_size = FIFA_MODULE_SIZE
    end

    local memscan = createMemScan() 
    local foundlist = createFoundList(memscan) 
    local start = getAddress(module_name)
    local stop = start + module_size

    memscan.firstScan( 
      soExactValue, vtByteArray, rtRounded, 
      aob, nil, start, stop, "*X*W", 
      fsmNotAligned, "1", true, false, false, false
    )
    memscan.waitTillDone() 
    foundlist.initialize() 
    memscan.Destroy()

    return foundlist
end

-- Validate offset
-- Return address if offset is valid, otherwise return False
function verify_offset(name)
    do_log(string.format("Veryfing %s offset", name), 'INFO')
    local aob = getfield(string.format('AOB_DATA.%s', name))
    local aob_len = math.floor(string.len(string.gsub(aob, "%s+", ""))/2)
    local addres_to_check = get_address_with_offset(BASE_ADDRESS, getfield(string.format('OFFSETS_DATA.offsets.%s', name)))
    do_log(string.format("addres_to_check %s, aob: %s", addres_to_check, aob), 'INFO')
    local temp_bytes = readBytes(addres_to_check, aob_len, true)
    local bytes_to_verify = {}
    -- convert to hex
    for i =1,aob_len do
        bytes_to_verify[i] = string.format('%02X', temp_bytes[i])
    end
    
    local index = 1
    for b in string.gmatch(aob, "%S+") do
        if b == "??" then
            -- Ignore wildcards
        elseif b ~= bytes_to_verify[index] then
            do_log(string.format("Veryfing %s offset failed", name), 'WARNING')
            do_log(string.format("Bytes in memory: %s != %s: %s", table.concat(bytes_to_verify, ' '), name, aob), 'WARNING')
            if bytes_to_verify[1] == 'E9' then
                do_log('jmp already set. This happen when you close and reopen Cheat Table without deactivating scripts. Now, restart FIFA and Cheat Engine to fix this problem', 'ERROR')
                assert(false, 'jmp already set, restart required')
            end
            return false
        end
        index = index + 1
    end
    do_log(string.format("Veryfing %s offset success", name), 'INFO')
    return addres_to_check
end

-- Update offset
-- Return true if success
function update_offset(name, save, module_name, module_size, section)
    local res_offset = nil
    local valid_i = {}
    local base_addr = BASE_ADDRESS

    if module_name then
        name = string.format('%s.AOBS.%s', section, name)
        base_addr = getAddress(module_name)
    end
    
    do_log(string.format("AOBScanModule %s", name), 'INFO')
    local res = AOBScanModule(
        getfield(string.format('AOB_DATA.%s', name)),
        module_name,
        module_size
    )
    local res_count = res.getCount()
    if res_count == 0 then 
        do_log(string.format("%s AOBScanModule error. Try to restart FIFA and Cheat Engine", name), 'ERROR')
        return false
    elseif res_count > 1 then
        do_log(string.format("%s AOBScanModule multiple matches - %i found", name, res_count), 'WARNING')
        for i=0, res_count-1, 1 do
            res_offset = tonumber(res[i], 16)
            do_log(string.format("offset %i - %X", i+1, res_offset), 'WARNING')
            valid_i[#valid_i+1] = i
        end
        if #valid_i >= 1 then
            do_log(string.format("picking offset at index - %i", valid_i[1]), 'WARNING')
            setfield(string.format('OFFSETS_DATA.offsets.%s', name), get_offset(base_addr, res[valid_i[1]]))
        else
            do_log(string.format("%s AOBScanModule error", name), 'ERROR')
            return false
        end
    else
        local offset = get_offset(base_addr, res[0])
        setfield(string.format('OFFSETS_DATA.offsets.%s', name), offset)
        do_log(string.format("New Offset for %s - %s", name, offset), 'INFO')
    end
    res.destroy()
    if save then save_offsets() end
    return true
end

-- Update all offsets (may take a few minutes)
function update_offsets()
    for k,v in pairs(AOB_DATA) do
        if type(v) == 'string' then
            -- main FIFA module
            update_offset(k, false)
        else
            -- DLC Module
            local module_name = v['MODULE_NAME']
            local module_size = getModuleSize(module_name)
            for kk, vv in pairs(v['AOBS']) do
                update_offset(kk, false, module_name, module_size, k)
            end
        end
    end

    save_offsets()
end

function check_process() 
    if FIFA_PROCESS_NAME == nil then 
        do_log('Check process has failed. FIFA_PROCESS_NAME is nil. Did you allowed CE to execute lua script at starup? ', 'ERROR')
        assert(false, 'Not initialized')
    end
    local pCurrentPID = getProcessIDFromProcessName(FIFA_PROCESS_NAME) 
    
    if pCurrentPID == nil or pCurrentPID ~= getOpenedProcessID() then
        do_log('Invalid PID. Restart FIFA and Cheat Engine is required', 'ERROR')
        assert(false, "Restart FIFA and Cheat Engine")
    else
        return true
    end
end 

function auto_attach_to_process()
    -- ONLY FOR GUI TESTS
    -- timer_setEnabled(AutoAttachTimer, false)
    -- start()
    -- ONLY FOR GUI TESTS
    
    
    local ProcessName = CFG_DATA.game.name
    local ProcIDNormal = getProcessIDFromProcessName(ProcessName)
    
    -- Trial when FIFA is from Origin Access
    local ProcessName_Trial = CFG_DATA.game.name_trial
    local ProcIDTrial = getProcessIDFromProcessName(ProcessName_Trial)
    
    
    if ProcIDNormal ~= nil then
        openProcess(ProcessName)
    elseif ProcIDTrial ~= nil then
        openProcess(ProcessName_Trial)
    end

    local attached_to = getOpenedProcessName()

    local pid = getOpenedProcessID()
    if pid > 0 and attached_to ~= nil then
        timer_setEnabled(AutoAttachTimer, false)
        do_log(string.format("Attached to %s", attached_to), 'INFO')
        FIFA_PROCESS_NAME = getOpenedProcessName()
        BASE_ADDRESS = getAddress(FIFA_PROCESS_NAME)
        FIFA_MODULE_SIZE = getModuleSize(FIFA_PROCESS_NAME)
        start()
    end
end

function can_autoactivate(script_id)
    local not_allowed_to_aa = {
        2998  -- "Generate new report" script, it's internal call and will cause crash when activated in Main Menu
    }

    for i=1, #not_allowed_to_aa do
        if not_allowed_to_aa[i] == script_id then
            return false
        end
    end
    return true
end

function autoactivate_scripts()
    -- Always activate database tables script
    -- And globalAllocs
    local always_activate = {
        2995, 1667, 1668, 2058
    }

    for i=1, #always_activate do
        local script_id = always_activate[i]
        local script_record = ADDR_LIST.getMemoryRecordByID(script_id)
        do_log(string.format('Activating %s (%d)', script_record.Description, script_id), 'INFO')
        script_record.Active = true
    end

    for i=1, #CFG_DATA.auto_activate do
        local script_id = CFG_DATA.auto_activate[i]
        if can_autoactivate(script_id) then
            local script_record = ADDR_LIST.getMemoryRecordByID(script_id)
            if script_record then
                do_log(string.format('Activating %s (%d)', script_record.Description, script_id), 'INFO')
                if not script_record.Active then
                    script_record.Active = true
                end
            end
        end
    end
    initPtrs()
end

-- find record in game database and update pointer in CT
function find_record_in_game_db(start, memrec_id, value_to_find, sizeOf, first_ptrname, to_exit)
    local ct_record = ADDR_LIST.getMemoryRecordByID(memrec_id)  -- Record in Cheat Table
    local offset = ct_record.getOffset(0)     -- int

    -- Assuming we are dealing with Binary Type
    local bitstart = ct_record.Binary.Startbit
    local binlen = ct_record.Binary.Size
    
    local i = start
    local current_value = 0

    if not to_exit then
        to_exit = 1
    end
    local zeros = 0
    while true do
        current_value = bAnd(bShr(readInteger(string.format('[%s]+%X', first_ptrname, offset+(i*sizeOf))), bitstart), (bShl(1, binlen) - 1))
        if current_value == value_to_find then
            return {
                index = i,
                addr = (readPointer(first_ptrname) + i*sizeOf),
            }
        elseif current_value == 0 then
            zeros = zeros + 1
            if zeros >= to_exit then break end
        end
        i = i + 1
    end
    
    return {}
end

function find_record_and_update_CT(memrec_id, value_to_find, sizeOf, first_ptrname, ptrname_to_update)
    local record = ADDR_LIST.getMemoryRecordByID(memrec_id)  -- Record in Cheat Table
    local offset = record.getOffset(0)     -- int
    
    -- Assuming we are dealing with Binary Type
    local bitstart = record.Binary.Startbit
    local binlen = record.Binary.Size
    
    local i = 0
    local current_value = 0
    local bFound = false
    while true do
        current_value = bAnd(bShr(readInteger(string.format('[%s]+%X', first_ptrname, offset+(i*sizeOf))), bitstart), (bShl(1, binlen) - 1))
        if current_value == value_to_find then
            -- update ptr in CT
            writeQword(ptrname_to_update, (readPointer(first_ptrname) + i*sizeOf))

            bFound = true
            break
        elseif current_value == 0 then
            break
        end
        i = i + 1
    end
    
    return bFound
end

function getScreenID()
    return readString(readPointer(SCREEN_ID_PTR))
end

function logScreenID()
    local screen_id = getScreenID()
    if not screen_id then 
        do_log('Current Screen: nil')
    else
        do_log('Current Screen: ' .. screen_id)
    end
end

function initPtrs()
    local codeGameDB = tonumber(get_validated_address('AOB_codeGameDB'), 16)
    local base_ptr = readPointer(byteTableToDword(readBytes(codeGameDB+4, 4, true)) + codeGameDB + 8)

    local DB_One_Tables_ptr = readMultilevelPointer(base_ptr, {0x10, 0x390})
    local DB_Two_Tables_ptr = readMultilevelPointer(base_ptr, {0x10, 0x3C0})

    -- Players Table
    local players_firstrecord = readMultilevelPointer(DB_One_Tables_ptr, {0xA8, 0x28, 0x30})
    writeQword("firstPlayerDataPtr", players_firstrecord)
    writeQword("playerDataPtr", players_firstrecord)

    -- Teamplayerlinks Table
    local teamplayerlinks_firstrecord = readMultilevelPointer(DB_One_Tables_ptr, {0x120, 0x28, 0x30})
    writeQword("ptrFirstTeamplayerlinks", teamplayerlinks_firstrecord)
    writeQword("ptrTeamplayerlinks", teamplayerlinks_firstrecord)

    -- LeagueTeamLinks Table
    local leagueteamlinks_firstrecord = readMultilevelPointer(DB_One_Tables_ptr, {0x148, 0x28, 0x30})
    writeQword("leagueteamlinksDataFirstPtr", leagueteamlinks_firstrecord)
    writeQword("leagueteamlinksDataPtr", leagueteamlinks_firstrecord)

    -- career_calendar Table
    local careercalendar_firstrecord = readMultilevelPointer(DB_Two_Tables_ptr, {0xC0, 0x28, 0x30})
    writeQword("ptrCareerCalendar", careercalendar_firstrecord)

    -- BASE PTR FOR STAMINA & INJURES
    local code = tonumber(get_validated_address('AOB_BASE_STAMINA_INJURES'), 16)
    tmp = byteTableToDword(readBytes(code+10, 4, true)) + code + 14
    autoAssemble([[ 
        globalalloc(basePtrStaminaInjures, 8, $tmp)
    ]])
    writeQword("basePtrStaminaInjures", tmp)

    -- BASE PTR FOR FORM & MORALE
    local code = tonumber(get_validated_address('AOB_BASE_FORM_MORALE'), 16)
    tmp = byteTableToDword(readBytes(code+8, 4, true)) + code + 12
    autoAssemble([[ 
        globalalloc(basePtrTeamFormMorale, 8, $tmp)
    ]])
    writeQword("basePtrTeamFormMorale", tmp)


    setup_internal_calls()
end

-- end

-- load AOBs
function load_aobs()
    return {
        AOB_CMSETTINGS = '48 8B 6C 24 58 0F 95 C0 40',
        AOB_codeGameDB = '48 0F 44 2D ?? ?? ?? ?? 8B 4D 08',
        AOB_screenID = '4C 0F 45 35 ?? ?? ?? ?? 49 8B FF 48 FF C7 41 80 3C',
        AOB_Form_Settings = '89 86 F8 00 00 00 B8',
        AOB_CreatePlayerMax = '83 FF 1E 7C 36',
        AOB_AltTab = '48 83 EC 48 4C 8B 0D ?? ?? ?? ?? 4D 85 C9 0F 84',
        AOB_DatabaseRead = '48 ?? ?? 4C 03 46 30 E8',
        AOB_ManagerHead = '40 48 8B 03 44 8B C6 48',
        AOB_UniqueDribble = '81 FA 18 FD 02 00',
        AOB_UniqueSprint = '89 B1 48 5B 00 00',
        AOB_IsEditPlayerUnlocked = '49 8B CB E8 ?? ?? ?? ?? 85 C0 75 ?? 48 8B 46 08 40 ?? ?? 48 8B 80 B8 0F 00 00',
        AOB_EditPlayerName = 'C6 44 24 20 01 45 33 C9 4C 8D 85 D0 06',
        AOB_PlayerInjury = '8B 43 24 89 47 14',
        AOB_UnlimitedTraining = '45 8B 76 44 49 8B 4D 08',
        AOB_MoreEfficientTraining = '66 0F 6E 5E 1C 45',
        AOB_TrainingEveryDay = '83 6B 44 01 0F 89 ?? ?? ?? ?? C7 43 44 07 00 00 00',
        AOB_SimA = '44 8B F8 4C 8D 45 C0',
        AOB_BoardIni = '89 44 24 50 41 8B FE',
        AOB_ManagerRating = '89 83 70 05 00 00 48 83 C4 20',
        AOB_EditCareerUsers = '8B 03 89 45 90 8B',
        AOB_TransferBudget = '44 8B 48 08 44 8B C3 48 8D 55',
        AOB_EditReleaseClause = '8B 48 08 83 F9 FF 74 06 89 8B',
        AOB_AllowTransferAppThTxt = 'E8 ?? ?? ?? ?? 8B D8 83 F8 0E ?? ?? B8 65 65 00 00 0F A3 D8',
        AOB_AllowTransferAppBtnClick = '41 FF 91 E0 00 00 00 8B F0',
        AOB_NegStatusCheck = '49 8B CE FF 90 F8 00 00 00 89',
        AOB_ContractNeg = '89 08 48 8B 43 18 89',
        AOB_HireScout = '41 8B 01 89 45 48',
        AOB_JobOfferINI = '89 45 3B B8 FF FF FF FF',
        AOB_IntJobOffer = '48 8B 81 90 01 00 00 48 2B 81',
        AOB_ClubJobOffer = '48 8B 86 D0 00 00 00 8B 34',
        AOB_UnlimitedPlayerRelease = '39 46 54 40 0F 9C C7',
        AOB_ReleasePlayerMsgBox = '4C 8B E0 85 FF 0F',
        AOB_ReleasePlayerFee = '8B D8 48 8B 45 77',
        AOB_TransfersIni = '41 89 87 D0 01 00 00 41',
        AOB_TransferIni = '89 83 A0 01 00 00 33 D2',
        AOB_GtnRevealPlayerData = '85 C0 75 0C 4C 8D 86 8C 02 00 00',
        AOB_DisableMorale = '0F 95 C1 88 4F 10',
        AOB_BetterMorale = '41 B8 FF FF FF FF 89 47 1C',
        AOB_SideManipulator = '48 8B 84 CB 18 01 00 00 83',
        AOB_YouthAcademyMoreYouthPlayers = '89 06 FF C7 48 83 C6 04 83 FF 02',
        AOB_YouthAcademyRevealPotAndOvr = '89 07 FF C3 48 83 C7 04 83 FB 06',
        AOB_YouthAcademyPrimAttr = '43 89 44 F7 30',
        AOB_YouthAcademySecAttr = '43 89 44 F7 68',
        AOB_YouthAcademyMinAgeForPromotion = '41 B8 03 00 00 00 89 85 E4',
        AOB_YouthAcademyPlayerAgeRange = '41 B8 04 00 00 00 41 89 07',
        AOB_YouthAcademyYouthPlayersRetirement = '41 FF C4 89 03',
        AOB_YouthAcademyPlayerPotential = '89 06 48 8D 76 04 83 FF 02 ?? ?? 4C 8B 7C 24 48',
        AOB_YouthAcademyWeakFootChance = 'FF C3 89 07 48 8D 7F 04 83 FB 06',
        AOB_YouthAcademyAllCountriesAvailable = '89 4C 24 30 B9 04 00 00 00',
        AOB_YouthAcademySkillMoveChance = '89 B5 7C 01 00 00 4C',
        AOB_YouthAcademyGeneratePlayer = 'F6 48 8B 3D ?? ?? ?? ?? 48 8B 9C 24 80 00 00 00',
        AOB_CountryIsBeingScouted = '80 FB 01 75 0C 4C',
        AOB_NoPlayerRegens = '41 BF 10 00 00 00 48 8B CE',
        AOB_NoPlayerGrowth = '48 89 45 B8 48 85 C0 0F 84 FC',
        AOB_ChangeStadium = '41 8B 9D E4 13 00 00',
        AOB_MatchHalfLength = '45 8B 87 08 14 00 00 33',
        AOB_MatchWeather = '83 F8 FF 0F 44 C6 EB',
        AOB_SimMaxCards = '89 87 5C 01 00 00 B8',
        AOB_SimMaxInjuries = '89 87 24 01 00 00 B8 FF',
        AOB_SimFatigueBase = '41 B8 FF FF FF FF 89 47 10',
        AOB_MatchScore = '0F 11 41 20 48 8B 40 30 48 89 41 30 41 8B 54',
        AOB_DisableSubstitutions = '42 8B BC 2B E4 96 00 00 46',
        AOB_IngameStamina = '8B 43 68 41 89 82 78 03 00 00',
        AOB_MatchTimer = '8B 41 50 89 46 10',
        AOB_UnlimitedSubstitutions = '8B 84 01 D4 8E 00 00 C3',
        AOB_TODDisplay = '4C 8B 13 C7 44 24 30 01 00 00 00 C6',
        AOB_TODReal = '4C 8B CE 49 8B C5',
        AOB_CustomTransfers = 'FF 50 10 EB 2B 48',

        -- PAP
        AOB_AgreeTransferRequest = "44 8B F0 89 84 24 90 00 00 00",
        AOB_EditPlayerBid = "41 B8 43 D9 FF FF",
        AOB_PAPBirthYear = "C0 BA CD 07 00 00",
        AOB_BDRanges = "8B 49 78 3B D1",
        AOB_PAPAccompl = "8B 84 A9 18 07 00 00",

        -- FREE CAM
        AOB_CAM_TARGET = "0F 11 AB 00 0B 00 00",
        AOB_CAM_ROTATE = "F3 0F 11 83 C8 05 00 00",
        AOB_CAM_V_ROTATE_SPEED_MUL = "F3 0F 5E C7 F3 0F 11 83 50 0B 00 00",
        AOB_CAM_H_ROTATE_SPEED_MUL = "F3 0F 11 83 4C 0B 00 00",
        AOB_CAM_Z_ROTATE_SPEED_MUL = "F3 0F 11 83 54 0B 00 00 F3",
        AOB_STADIUM_BOUNDARY = "0F 28 C3 0F C6 C0 00 0F 5C C8 0F 28 C4",
        AOB_CAM_Z_BOUNDARY = "F3 0F 6F 12 0F 28 C3",
        AOB_FULL_ANGLE_ROTV = "F3 0F 10 40 60 F3 0F 58 83 B4",

        AOB_GENERATE_NEW_YA_REPORT = "8D 43 0E 89 44 24 3C",

        -- "ScriptManager::ScriptFunctions"
        AOB_SCRIPTS_BASE_PTR = "48 8B 46 10 4C 89 2A",

        -- "Internal functions"
        AOB_F_GEN_REPORT = "48 8B CB E8 ?? ?? ?? ?? 48 8B CB 48 8B 5C 24 38 48 8B 74 24 40",

        -- Base Ptr for stamina/injures
        AOB_BASE_STAMINA_INJURES = "0F 4F C2 85 C0 75 B2 48 8B 1D ?? ?? ?? ?? 48 8D 0D",

        -- Base Ptr form & Morale
        -- And release clauses too...
        AOB_BASE_FORM_MORALE = "E8 ?? ?? ?? ?? 48 89 35 ?? ?? ?? ?? 41 B8 01 00 00 00",

        -- FootballCompEng_Win64_retail.dll
        FootballCompEng = {
            MODULE_NAME = 'FootballCompEng_Win64_retail.dll',
            AOBS = {
                AOB_Calendar = "33 D2 48 89 54 24 48",
            }
        }
    }
end

-- load content from .ini files
function load_cfg()
    if file_exists(CONFIG_FILE_PATH) then
        do_log(string.format('Loading CFG_DATA from %s', CONFIG_FILE_PATH), 'INFO')
        local cfg = LIP.load(CONFIG_FILE_PATH);

        if not cfg.new_dirs then
            local def_cfg = default_cfg()
            cfg.new_dirs = def_cfg.new_dirs
        end

        -- Create new dirs
        local created = false
        local save_required = false
        for k,v in pairs(cfg.new_dirs) do
            if not v then
                if not created then
                    created = true
                    save_required = true
                    create_dirs()
                end
                cfg.new_dirs[k] = true
            end
        end

        if cfg.directories then
            CACHE_DIR = cfg.directories.cache_dir
        end

        if cfg.flags then
            if cfg.flags.hide_ce_scanner == nil then
                cfg.flags.debug_mode = false
            end

            DEBUG_MODE = cfg.flags.debug_mode

            if cfg.flags.hide_ce_scanner == nil then
                cfg.flags.hide_ce_scanner = true
            end

            HIDE_CE_SCANNER = cfg.flags.hide_ce_scanner
        end

        return cfg
    else
        do_log(string.format('cfg file not found at %s - loading default data', CONFIG_FILE_PATH), 'INFO')
        local data = default_cfg()
        create_dirs()

        local status, err = pcall(LIP.save, CONFIG_FILE_PATH, data)

        if not status then
            do_log(string.format('LIP.SAVE FAILED for %s with err: ', CONFIG_FILE_PATH, err))
            CACHE_DIR = 'cache/'
            OFFSETS_FILE_PATH = 'offsets.ini'
        end

        return data
    end
end

function default_cfg()
    local data = {
        flags = {
            debug_mode = DEBUG_MODE,
            deactive_on_close = false,
            hide_ce_scanner = true
        },
        directories = {
            cache_dir = CACHE_DIR,
        },
        game =
        {
            name = string.format('FIFA%s.exe', FIFA),
            name_trial = string.format('FIFA%s_TRIAL.exe', FIFA)
        },
        gui = {
            opacity = 255
        },
        auto_activate = {
            2995, 1667, 1668, 2058
        },
        hotkeys = {
            sync_with_game = 'VK_F5',
            search_player_by_id = 'VK_RETURN'
        },
        new_dirs = {
            ut = false,
            flags = false,
        },
        other = {
            something = 'something'
        }
    };

    return data
end

function save_cfg()
    if CFG_DATA == nil then 
        do_log('CFG_DATA is nil - save_cfg failed', 'WARNING')
        return 
    end
    do_log(string.format('Saving CFG_DATA to %s', CONFIG_FILE_PATH), 'INFO')
    LIP.save(CONFIG_FILE_PATH, CFG_DATA);
end

function load_offsets()
    if file_exists(OFFSETS_FILE_PATH) then
        do_log(string.format('Loading OFFSETS_DATA from %s', OFFSETS_FILE_PATH), 'INFO')
        return LIP.load(OFFSETS_FILE_PATH);
    else
        do_log(string.format('offsets file not found at %s - loading default data', OFFSETS_FILE_PATH), 'INFO')
        local data =
        {
            offsets =
            {
                AOB_AltTab = nil,
            },
        };
        LIP.save(OFFSETS_FILE_PATH, data);
        return data
    end

end

function save_offsets()
    if OFFSETS_DATA == nil then 
        do_log('OFFSETS_DATA is nil - save_offsets failed', 'WARNING')
        return 
    end
    LIP.save(OFFSETS_FILE_PATH, OFFSETS_DATA);
end
-- end