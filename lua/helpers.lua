require 'lua/commons';
-- helpers

function os_execute(cmd)
    do_log(string.format('os_execute %s', cmd))
    os.execute(cmd)
end

-- Check Cheat Engine Version
function check_ce_version()
    local ce_version = getCEVersion()
    do_log(string.format('Cheat engine version: %f', ce_version))
    if(ce_version < 6.81) then
        ShowMessage('Warning. Recommended Cheat Engine version is 6.8.1 or above')
    end
    MainWindowForm.LabelCEVer.Caption = ce_version
end

-- Check Cheat Table Version
function check_ct_version()
    local ver = '1.1.3'
    do_log(string.format('Cheat table version: %s', ver))
    MainWindowForm.LabelCTVer.Caption = ver -- update version in GUI
    ADDR_LIST.getMemoryRecordByID(2794).Description = string.format("v%s", ver) -- update version in cheat table
end

function create_dirs()
    local cmd1 = "md " .. '"' .. string.gsub(CACHE_DIR .. 'crest', "/","\\") .. '"'
    local cmd2 = "md " .. '"' .. string.gsub(CACHE_DIR .. 'heads', "/","\\") .. '"'
    local cmd3 = "md " .. '"' .. string.gsub(CACHE_DIR .. 'youthheads', "/","\\") .. '"'
    local cmd4 = "md " .. '"' .. string.gsub(DATA_DIR, "/","\\"):sub(1,-2) .. '"'

    os_execute(string.format('%s & %s & %s', cmd1, cmd2, cmd3))
    os_execute(cmd4)
    
end

function copy_template_files()
    local cmd1 = "copy " .. 'tmp\\crest_notfound.png "' .. string.gsub(CACHE_DIR .. 'crest\\notfound.png"', "/","\\")
    local cmd2 = "copy " .. 'tmp\\heads_notfound.png "' .. string.gsub(CACHE_DIR .. 'heads\\notfound.png"', "/","\\")

    os_execute(string.format('%s & %s', cmd1, cmd2))
end

function init_logger()
    if DEBUG_MODE then return nil end
    local time = os.date("*t")
    return io.open("logs/log_".. string.format("%02d-%02d-%02d", time.year, time.month, time.day) .. ".txt", "a+")
end

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
        LOGGER:write(string.format("[ %s ] %s - %s\n", level, os.date("%c", os.time()), text))
    end
end

function readMultilevelPointer(base_addr, offsets)
    for i=1, #offsets do
        base_addr = readPointer(base_addr+offsets[i])
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

function get_validated_address(name)
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
function AOBScanModule(aob)
    local memscan = createMemScan() 
    local foundlist = createFoundList(memscan) 
    local start = getAddress(FIFA_PROCESS_NAME)
    local stop = start + FIFA_MODULE_SIZE

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
function update_offset(name, save)
    local res_offset = nil
    local valid_i = {}
    
    do_log(string.format("AOBScanModule %s", name), 'INFO')
    local res = AOBScanModule(getfield(string.format('AOB_DATA.%s', name)))
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
            setfield(string.format('OFFSETS_DATA.offsets.%s', name), get_offset(BASE_ADDRESS, res[valid_i[1]]))
        else
            do_log(string.format("%s AOBScanModule error", name), 'ERROR')
            return false
        end
    else
        setfield(string.format('OFFSETS_DATA.offsets.%s', name), get_offset(BASE_ADDRESS, res[0]))
    end
    res.destroy()
    if save then save_offsets() end
    return true
end

-- Update all offsets (may take a few minutes)
function update_offsets()
    for k,v in pairs(AOB_DATA) do
        update_offset(k, false)
    end

    save_offsets()
end

function check_process() 
    if FIFA_PROCESS_NAME == nil then 
        do_log('Check process has failed. FIFA_PROCESS_NAME is nil. ', 'ERROR')
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
    
    local attached_to = nil
    if ProcIDNormal ~= nil then
        openProcess(ProcessName)
        attached_to = ProcessName
    elseif ProcIDTrial ~= nil then
        openProcess(ProcessName_Trial)
        attached_to = ProcessName_Trial
    end
    
    local pid = getOpenedProcessID()
    if pid > 0 and attached_to ~= nil then
        timer_setEnabled(AutoAttachTimer, false)
        do_log(string.format("Attached to %s", attached_to), 'INFO')
        FIFA_PROCESS_NAME = attached_to
        BASE_ADDRESS = getAddress(FIFA_PROCESS_NAME)
        FIFA_MODULE_SIZE = getModuleSize(FIFA_PROCESS_NAME)
        start()
    end
end

function autoactivate_scripts()
    for i=1, #CFG_DATA.auto_activate do
        local script_id = CFG_DATA.auto_activate[i]
        local script_record = ADDR_LIST.getMemoryRecordByID(script_id)
        do_log(string.format('Activating %s (%d)', script_record.Description, script_id), 'INFO')
        script_record.Active = true
    end
    initDBPtrs()
end

-- find record in game database and update pointer in CT
function find_record_in_game_db(start, memrec_id, value_to_find, sizeOf, first_ptrname)
    local ct_record = ADDR_LIST.getMemoryRecordByID(memrec_id)  -- Record in Cheat Table
    local offset = ct_record.getOffset(0)     -- int

    -- Assuming we are dealing with Binary Type
    local bitstart = ct_record.Binary.Startbit
    local binlen = ct_record.Binary.Size
    
    local i = start
    local current_value = 0
    while true do
        current_value = bAnd(bShr(readInteger(string.format('[%s]+%X', first_ptrname, offset+(i*sizeOf))), bitstart), (bShl(1, binlen) - 1))
        if current_value == value_to_find then
            return {
                index = i,
                addr = (readPointer(first_ptrname) + i*sizeOf),
            }
        elseif current_value == 0 then
            break
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

function initDBPtrs()
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
end

-- end

-- load AOBs
function load_aobs()
    return {
        AOB_codeGameDB = '48 0F 44 2D ?? ?? ?? ?? 8B 4D 08',
        AOB_Form_Settings = '89 86 F8 00 00 00 B8',
        AOB_CreatePlayerMax = '83 FF 1E 7C 36',
        AOB_AltTab = '48 83 EC 48 4C 8B 0D ?? ?? ?? ?? 4D 85 C9 0F 84',
        AOB_DatabaseRead = '48 01 DA 4C 03 46 30',
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
        AOB_TransfersIni = '41 89 87 D0 01 00 00 33',
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
        AOB_YouthAcademySkillMoveChance2 = '89 07 48 8D 7F 04 83 FB 0A',
        AOB_YouthAcademySkillMoveChance = '89 03 FF C7 48 83 C3 04 49 2B',
        AOB_CountryIsBeingScouted = '80 FB 01 75 0C 4C',
        AOB_NoPlayerRegens = '41 BF 10 00 00 00 48 8B CE',
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
    }
end

-- load content from .ini files
function load_cfg()
    if file_exists(CONFIG_FILE_PATH) then
        do_log(string.format('Loading CFG_DATA from %s', CONFIG_FILE_PATH), 'INFO')
        local cfg = LIP.load(CONFIG_FILE_PATH);

        CACHE_DIR = cfg.directories.cache_dir
        DEBUG_MODE = cfg.flags.debug_mode
        return cfg
    else
        do_log(string.format('cfg file not found at %s - loading default data', CONFIG_FILE_PATH), 'INFO')
        local data =
        {
            flags = {
                debug_mode = DEBUG_MODE,
                deactive_on_close = false,
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
                1666, 1667, 1668, 2058
            },
            hotkeys = {
                sync_with_game = 'VK_F5',
                search_player_by_id = 'VK_RETURN'
            },
            other = {
                something = 'something'
            }
        };
        create_dirs()
        copy_template_files()

        LIP.save(CONFIG_FILE_PATH, data);
        return data
    end
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