

CUSTOM_TRANSFERS = 0

function fill_custom_transfers()
    for i=0, TransferPlayersForm.TransfersScroll.ComponentCount-1 do
        TransferPlayersForm.TransfersScroll.Component[0].destroy()
    end
    CUSTOM_TRANSFERS = 0
    local num_of_transfers = readInteger('arr_NewTransfers') - 1
    for i=0, num_of_transfers do
        local pid = readInteger(string.format('arr_NewTransfers+%s', string.format('%X', i * 20 + 4)))
        local ntid = readInteger(string.format('arr_NewTransfers+%s', string.format('%X', i * 20 + 8)))
        local ctid = readInteger(string.format('arr_NewTransfers+%s', string.format('%X', i * 20 + 12)))
        local rl_clause = readInteger(string.format('arr_NewTransfers+%s', string.format('%X', i * 20 + 16)))
        if rl_clause == 0 then rl_clause = 'None' end

        local cl = readInteger(string.format('arr_NewTransfers+%s', string.format('%X', i * 20 + 20))) // 12
        local is_confirmed_by_user = true
        new_custom_transfer(pid, {ctid}, ntid, rl_clause, cl, is_confirmed_by_user)
    end
end

function new_custom_transfer(playerid, current_team_ids, teamid, clause, contract_length, is_confirmed_by_user)
    if not playerid then
        playerid = inputQuery("Queue Player Transfer", "Enter playerid:", "0")
        if not playerid or tonumber(playerid) <= 0 then
            ShowMessage("Enter Valid PlayerID")
            return
        end
        playerid = tonumber(playerid)
    end

    if not teamid then
        teamid = inputQuery("Queue Player Transfer", "Enter new teamid:", "0")
        if not teamid or tonumber(teamid) <= 0 then
            ShowMessage("Enter Valid TeamID")
            return
        end
        teamid = tonumber(teamid)
    end

    if (not is_confirmed_by_user) or (is_confirmed_by_user and playerid >= 280000) then
        if not find_player_by_id(playerid) then
            do_log("Player with ID: " .. playerid .. " doesn't exists in your current CM save", 'ERROR')
            return
        end
    end

    if not current_team_ids then
        current_team_ids = {}
        for key, value in pairs(PlayerTeamContext) do
            if value['team_type'] ~= 'national' then
                table.insert(current_team_ids, tonumber(key))
            end
        end
    
        if #current_team_ids <= 0 then
            do_log("Player with ID: " .. playerid .. " don't have any current team...", 'ERROR')
        elseif #current_team_ids > 1 then
            current_team_ids = {}
            for key, value in pairs(PlayerTeamContext) do
                if value['team_type'] == 'club' then
                    table.insert(current_team_ids, tonumber(key))
                end
            end
    
            if #current_team_ids <= 0 then
                current_team_ids = {}
                for key, value in pairs(PlayerTeamContext) do
                    if value['team_type'] == 'all_stars' then
                        table.insert(current_team_ids, tonumber(key))
                    end
                end
            end
        end
    end

    local player = {
        playerid = playerid,
        headtypecode = tonumber(ADDR_LIST.getMemoryRecordByID(CT_MEMORY_RECORDS['HEADTYPECODE']).Value),
        haircolorcode = tonumber(ADDR_LIST.getMemoryRecordByID(CT_MEMORY_RECORDS['HAIRCOLORCODE']).Value)
    }

    if not clause then
        clause = 'None'
    end

    if not contract_length then
        contract_length = 3
    end

    create_player_transfer_comp(player, current_team_ids, teamid, clause, contract_length, is_confirmed_by_user)
end

function create_player_transfer_comp(player, current_team_ids, teamid, clause, contract_length, is_confirmed_by_user)
    CUSTOM_TRANSFERS = CUSTOM_TRANSFERS + 1
    local name = string.format('NewTransferContainerPanel%d', CUSTOM_TRANSFERS)
    local reindex = false
    local deleted = 0
    for i=0, TransferPlayersForm.TransfersScroll.ComponentCount-1 do
        -- Delete deleted transfers
        if not TransferPlayersForm.TransfersScroll.Component[i-deleted].Visible then
            TransferPlayersForm.TransfersScroll.Component[i-deleted].destroy()
            deleted = deleted + 1
            reindex = true
        end
    end

    -- reindex
    if reindex then
        for i=0, TransferPlayersForm.TransfersScroll.ComponentCount-1 do
            local comp = TransferPlayersForm.TransfersScroll.Component[i]
            comp.Name = string.gsub(comp.Name, '%d', i+1)
            for j=0, comp.ComponentCount-1 do
                comp.Component[j].Name = string.gsub(comp.Component[j].Name, '%d', i+1)
            end
        end
    end

    local panel_player_transfer_container = createPanel(TransferPlayersForm.TransfersScroll)
    panel_player_transfer_container.Name = name
    panel_player_transfer_container.BevelOuter = bvNone
    panel_player_transfer_container.Caption = ''

    panel_player_transfer_container.Color = '0x00302825'
    panel_player_transfer_container.Width = 780
    panel_player_transfer_container.Height = 160
    panel_player_transfer_container.Left = 10

    if CUSTOM_TRANSFERS == 1 then
        panel_player_transfer_container.Top = 70
    else
        panel_player_transfer_container.Top = 160*(CUSTOM_TRANSFERS-1) + 85
    end

    -- Player miniface
    local playerimg = createImage(panel_player_transfer_container)
    local ss_p = load_headshot(
        player['playerid'],
        player['headtypecode'],
        player['haircolorcode']
    )
    playerimg.Picture.LoadFromStream(ss_p)
    ss_p.destroy()
    
    playerimg.Name = string.format('PlayerImage%d', CUSTOM_TRANSFERS)
    playerimg.Left = 20
    playerimg.Top = 25
    playerimg.Height = 90
    playerimg.Width = 90
    playerimg.Stretch = true

    -- PlayerID
    local PlayerIDLabel = createLabel(panel_player_transfer_container)

    PlayerIDLabel.Name = string.format('PlayerIDLabel%d', CUSTOM_TRANSFERS)
    PlayerIDLabel.AutoSize = false
    PlayerIDLabel.Left = 20
    PlayerIDLabel.Height = 14
    PlayerIDLabel.Top = 125
    PlayerIDLabel.Width = 90
    PlayerIDLabel.Alignment = "taCenter"
    PlayerIDLabel.Caption = player['playerid']

    -- From
    local FromLabel = createLabel(panel_player_transfer_container)

    FromLabel.Name = string.format('FromTeamLabel%d', CUSTOM_TRANSFERS)
    FromLabel.AutoSize = false
    FromLabel.Left = 135
    FromLabel.Height = 14
    FromLabel.Top = 0
    FromLabel.Width = 90
    FromLabel.Alignment = "taCenter"
    FromLabel.Caption = "From:"

    -- From Crest
    local FromCrestImg = createImage(panel_player_transfer_container)
    local ss_c = load_crest(current_team_ids[1])
    FromCrestImg.Picture.LoadFromStream(ss_c)
    ss_c.destroy()
    
    FromCrestImg.Name = string.format('FromCrestImage%d', CUSTOM_TRANSFERS)
    FromCrestImg.Left = 135
    FromCrestImg.Top = 25
    FromCrestImg.Height = 90
    FromCrestImg.Width = 90
    FromCrestImg.Stretch = true

    -- From Edit/Combo
    if #current_team_ids == 1 then
        -- If only one team
        local FromTeamId = createEdit(panel_player_transfer_container)
        FromTeamId.Name = string.format('FromTeamId%d', CUSTOM_TRANSFERS)
        FromTeamId.BorderStyle = "bsNone"
        FromTeamId.ParentFont = false
        FromTeamId.Color = 5653320
        FromTeamId.Font.CharSet = "EASTEUROPE_CHARSET"
        FromTeamId.Font.Color = 12632256 -- clCream
        FromTeamId.Font.Height = -12
        FromTeamId.Font.Name = "Verdana"
        FromTeamId.AutoSize = false
        FromTeamId.Left = 135
        FromTeamId.Height = 14
        FromTeamId.Top = 124
        FromTeamId.Width = 90
        FromTeamId.Alignment = "taCenter"
        FromTeamId.Text = current_team_ids[1]
        FromTeamId.ReadOnly = true
    else
        -- If multiple teams
        local FromTeamId = createComboBox(panel_player_transfer_container)
        for i = 1, #current_team_ids do
            FromTeamId.items.add(current_team_ids[i])
        end
        FromTeamId.ItemIndex = 0
        FromTeamId.Name = string.format('FromTeamId%d', CUSTOM_TRANSFERS)
        FromTeamId.AutoSize = false
        FromTeamId.Left = 135
        FromTeamId.Height = 22
        FromTeamId.Top = 124
        FromTeamId.Width = 90
        FromTeamId.Style = "csDropDownList"
        FromTeamId.OnChange = reload_team_from_crest
    end

    -- To
    local ToLabel = createLabel(panel_player_transfer_container)

    ToLabel.Name = string.format('ToTeamLabel%d', CUSTOM_TRANSFERS)
    ToLabel.AutoSize = false
    ToLabel.Left = 265
    ToLabel.Height = 14
    ToLabel.Top = 0
    ToLabel.Width = 90
    ToLabel.Alignment = "taCenter"
    ToLabel.Caption = "To:"

    -- To Crest
    local ToCrestImg = createImage(panel_player_transfer_container)
    local ss_c = load_crest(teamid)
    ToCrestImg.Picture.LoadFromStream(ss_c)
    ss_c.destroy()
    
    ToCrestImg.Name = string.format('ToCrestImage%d', CUSTOM_TRANSFERS)
    ToCrestImg.Left = 265
    ToCrestImg.Top = 25
    ToCrestImg.Height = 90
    ToCrestImg.Width = 90
    ToCrestImg.Stretch = true

    -- To Edit
    local ToTeamId = createEdit(panel_player_transfer_container)
    ToTeamId.Name = string.format('ToTeamId%d', CUSTOM_TRANSFERS)
    ToTeamId.BorderStyle = "bsNone"
    ToTeamId.Color = 5653320
    ToTeamId.ParentFont = false
    ToTeamId.Font.CharSet = "EASTEUROPE_CHARSET"
    ToTeamId.Font.Color = 15793151
    ToTeamId.Font.Height = -12
    ToTeamId.Font.Name = "Verdana"
    ToTeamId.AutoSize = false
    ToTeamId.Alignment = "taCenter"
    ToTeamId.Left = 265
    ToTeamId.Height = 14
    ToTeamId.Top = 124
    ToTeamId.Width = 90
    ToTeamId.Text = teamid
    ToTeamId.OnChange = reload_team_to_crest

    -- Release Clause Label
    local RCLabel = createLabel(panel_player_transfer_container)

    RCLabel.Name = string.format('RCLabel%d', CUSTOM_TRANSFERS)
    RCLabel.AutoSize = false
    RCLabel.Left = 375
    RCLabel.Height = 14
    RCLabel.Top = 25
    RCLabel.Width = 110
    RCLabel.Alignment = "taCenter"
    RCLabel.Caption = "Release Clause:"

    -- Release Clause Edit
    local RCValue = createEdit(panel_player_transfer_container)
    RCValue.Name = string.format('ReleaseClauseValue%d', CUSTOM_TRANSFERS)
    RCValue.BorderStyle = "bsNone"
    RCValue.Color = 5653320
    RCValue.ParentFont = false
    RCValue.Font.CharSet = "EASTEUROPE_CHARSET"
    RCValue.Font.Color = 15793151
    RCValue.Font.Height = -12
    RCValue.Font.Name = "Verdana"
    RCValue.AutoSize = false
    RCValue.Alignment = "taCenter"
    RCValue.Left = 495
    RCValue.Height = 14
    RCValue.Top = 29
    RCValue.Width = 100
    RCValue.Text = clause

    -- Contract Length Label
    local CLLabel = createLabel(panel_player_transfer_container)

    CLLabel.Name = string.format('CLLabel%d', CUSTOM_TRANSFERS)
    CLLabel.AutoSize = false
    CLLabel.Left = 375
    CLLabel.Height = 14
    CLLabel.Top = 65
    CLLabel.Width = 110
    CLLabel.Alignment = "taCenter"
    CLLabel.Caption = "Contract Length:"

    -- Contract Length Combo
    local CLCombo = createComboBox(panel_player_transfer_container)
    local contract_length_values = {
        '1 year', '2 years', '3 years', '4 years', '5 years'
    }
    for i = 1, #contract_length_values do
        CLCombo.items.add(contract_length_values[i])
    end

    CLCombo.ItemIndex = contract_length - 1
    CLCombo.Name = string.format('ContractLengthCombo%d', CUSTOM_TRANSFERS)
    CLCombo.AutoSize = false
    CLCombo.Left = 495
    CLCombo.Height = 22
    CLCombo.Top = 63
    CLCombo.Width = 100
    CLCombo.Style = "csDropDownList"

    -- Confirm Btn
    if not is_confirmed_by_user then
        local ConfirmImg = createImage(panel_player_transfer_container)
        ConfirmImg.Picture.LoadFromStream(findTableFile('btn.png').Stream)

        ConfirmImg.Name = string.format('ConfirmBtnImage%d', CUSTOM_TRANSFERS)
        ConfirmImg.Left = 605
        ConfirmImg.Top = 20
        ConfirmImg.Height = 56
        ConfirmImg.Width = 161
        ConfirmImg.OnClick = confirm_transfer

        local ConfirmLabel = createLabel(panel_player_transfer_container)
        ConfirmLabel.Name = string.format('ConfirmBtnLabel%d', CUSTOM_TRANSFERS)
        ConfirmLabel.AnchorSideLeft.Control = ConfirmImg
        ConfirmLabel.AnchorSideTop.Control = ConfirmImg
        ConfirmLabel.AnchorSideRight.Control = ConfirmImg
        ConfirmLabel.AnchorSideRight.Side = "asrBottom"
        ConfirmLabel.AnchorSideBottom.Control = ConfirmImg
        ConfirmLabel.AnchorSideBottom.Side = "asrBottom"
        ConfirmLabel.Anchors = "[akTop, akLeft, akRight, akBottom]"
        ConfirmLabel.Alignment = "taCenter"
        ConfirmLabel.AutoSize = false
        ConfirmLabel.BorderSpacing.Top = 13
        ConfirmLabel.Caption = 'Confirm'
        ConfirmLabel.Font.CharSet = "EASTEUROPE_CHARSET"
        ConfirmLabel.Font.Color = 12632256  -- clSilver
        ConfirmLabel.Font.Height = -15
        ConfirmLabel.Font.Name = 'Verdana'
        ConfirmLabel.ParentColor = false
        ConfirmLabel.ParentFont = false
        ConfirmLabel.OnClick = confirm_transfer
    end

    -- Delete Btn
    local DeleteImg = createImage(panel_player_transfer_container)
    DeleteImg.Picture.LoadFromStream(findTableFile('btn.png').Stream)

    DeleteImg.Name = string.format('DeleteBtnImage%d', CUSTOM_TRANSFERS)
    DeleteImg.Left = 605
    DeleteImg.Top = 81
    DeleteImg.Height = 56
    DeleteImg.Width = 161
    DeleteImg.OnClick = delete_transfer

    local DeleteLabel = createLabel(panel_player_transfer_container)
    DeleteLabel.Name = string.format('DeleteBtnLabel%d', CUSTOM_TRANSFERS)
    DeleteLabel.AnchorSideLeft.Control = DeleteImg
    DeleteLabel.AnchorSideTop.Control = DeleteImg
    DeleteLabel.AnchorSideRight.Control = DeleteImg
    DeleteLabel.AnchorSideRight.Side = "asrBottom"
    DeleteLabel.AnchorSideBottom.Control = DeleteImg
    DeleteLabel.AnchorSideBottom.Side = "asrBottom"
    DeleteLabel.Anchors = "[akTop, akLeft, akRight, akBottom]"
    DeleteLabel.Alignment = "taCenter"
    DeleteLabel.BorderSpacing.Top = 13
    DeleteLabel.Caption = 'Delete'
    DeleteLabel.Font.CharSet = "EASTEUROPE_CHARSET"
    DeleteLabel.Font.Color = 12632256
    DeleteLabel.Font.Height = -15
    DeleteLabel.Font.Name = 'Verdana'
    DeleteLabel.ParentColor = false
    DeleteLabel.ParentFont = false
    DeleteLabel.OnClick = delete_transfer
end

