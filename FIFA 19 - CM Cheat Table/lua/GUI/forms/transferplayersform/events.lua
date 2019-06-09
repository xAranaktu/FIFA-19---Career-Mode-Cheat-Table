require 'lua/GUI/forms/transferplayersform/helpers';

function TransferPlayersNewTransferBtnClick(sender)
    new_custom_transfer()
end
function TransferPlayersNewTransferLabelClick(sender)
    TransferPlayersNewTransferBtnClick(sender)
end
function TransferPlayersExitClick(sender)
    TransferPlayersForm.close()
    MainWindowForm.show()
end

function TransferPlayersSettingsClick(sender)
    SettingsForm.show()
end

function TransferPlayersSyncImageClick(sender)
    fill_custom_transfers()
end

function TransferPlayersMinimizeClick(sender)
    TransferPlayersForm.WindowState = "wsMinimized"
end

function TransferPlayersTopPanelMouseDown(sender, button, x, y)
    TransferPlayersForm.dragNow()
end

function TransferTypeListBoxSelectionChange(sender, user)

end

local FillTransferPlayersFormTimer = createTimer(nil)
function TransferPlayersFormShow(sender)
    TransferPlayersForm.TransferTypeListBox.setItemIndex(0)
    -- Load Data
    timer_onTimer(FillTransferPlayersFormTimer, fill_transfers_on_show)
    timer_setInterval(FillTransferPlayersFormTimer, 100)
    timer_setEnabled(FillTransferPlayersFormTimer, true)
end

function fill_transfers_on_show()
    timer_setEnabled(FillTransferPlayersFormTimer, false)
    fill_custom_transfers()
end

function reload_team_to_crest(sender)
    local teamid = tonumber(sender.Text)
    if not teamid or teamid == 0 then
        return
    end

    local comp_id = string.gsub(sender.Name, "ToTeamId", "")
    local ToCrestImg = TransferPlayersForm.TransfersScroll[string.format('NewTransferContainerPanel%d', comp_id)][string.format('ToCrestImage%d', comp_id)]
    local ss_c = load_crest(teamid)
    ToCrestImg.Picture.LoadFromStream(ss_c)
    ss_c.destroy()
end

function reload_team_from_crest(sender)
    local teamid = tonumber(sender.Items[sender.ItemIndex])
    if not teamid or teamid == 0 then
        return
    end

    local comp_id = string.gsub(sender.Name, "FromTeamId", "")
    comp_id = tonumber(comp_id)
    local FromCrestImg = TransferPlayersForm.TransfersScroll[string.format('NewTransferContainerPanel%d', comp_id)][string.format('FromCrestImage%d', comp_id)]
    local ss_c = load_crest(teamid)
    FromCrestImg.Picture.LoadFromStream(ss_c)
    ss_c.destroy()
end

function confirm_transfer(sender)
    if not ADDR_LIST.getMemoryRecordByID(3034).Active then ADDR_LIST.getMemoryRecordByID(3034).Active = true end
    local comp_id = nil
    if sender.ClassName == 'TCEImage' then
        comp_id = string.gsub(sender.Name, "ConfirmBtnImage", "")
    else
        comp_id = string.gsub(sender.Name, "ConfirmBtnLabel", "")
    end
    comp_id = tonumber(comp_id)
    TransferPlayersForm.TransfersScroll[string.format('NewTransferContainerPanel%d', comp_id)][string.format('ConfirmBtnLabel%d', comp_id)].Visible = false
    TransferPlayersForm.TransfersScroll[string.format('NewTransferContainerPanel%d', comp_id)][string.format('ConfirmBtnImage%d', comp_id)].Visible = false

    local num_of_transfers = readInteger('arr_NewTransfers')
    writeInteger('arr_NewTransfers', num_of_transfers + 1)

    -- append
    local playerid = tonumber(TransferPlayersForm.TransfersScroll[string.format('NewTransferContainerPanel%d', comp_id)][string.format('PlayerIDLabel%d', comp_id)].Caption)

    local current_teamid_comp = TransferPlayersForm.TransfersScroll[string.format('NewTransferContainerPanel%d', comp_id)][string.format('FromTeamId%d', comp_id)]
    local current_teamid = nil
    if current_teamid_comp.ClassName == 'TEdit' or current_teamid_comp.ClassName == 'TCEEdit' then
        current_teamid = tonumber(current_teamid_comp.Text)
    else
        current_teamid = tonumber(current_teamid_comp.Items[current_teamid_comp.ItemIndex])
    end
    local new_teamid = tonumber(TransferPlayersForm.TransfersScroll[string.format('NewTransferContainerPanel%d', comp_id)][string.format('ToTeamId%d', comp_id)].Text)
    local release_clause = tonumber(TransferPlayersForm.TransfersScroll[string.format('NewTransferContainerPanel%d', comp_id)][string.format('ReleaseClauseValue%d', comp_id)].Text) or 0
    local contract_length = (tonumber(TransferPlayersForm.TransfersScroll[string.format('NewTransferContainerPanel%d', comp_id)][string.format('ContractLengthCombo%d', comp_id)].ItemIndex) + 1) * 12

    writeInteger(
        string.format('arr_NewTransfers+%s', string.format('%X', (num_of_transfers) * 20 + 4)),
        playerid
    )
    writeInteger(
        string.format('arr_NewTransfers+%s', string.format('%X', (num_of_transfers) * 20 + 8)),
        new_teamid
    )
    writeInteger(
        string.format('arr_NewTransfers+%s', string.format('%X', (num_of_transfers) * 20 + 12)),
        current_teamid
    )
    writeInteger(
        string.format('arr_NewTransfers+%s', string.format('%X', (num_of_transfers) * 20 + 16)),
        release_clause
    )
    writeInteger(
        string.format('arr_NewTransfers+%s', string.format('%X', (num_of_transfers) * 20 + 20)),
        contract_length
    )
    do_log(string.format("Confirm transfer. PlayerID: %d, CurrentTeamID: %d, NewTeamID: %d, Clause: %d, Length: %d", playerid, current_teamid, new_teamid, release_clause, contract_length), 'INFO')
    if not ADDR_LIST.getMemoryRecordByID(3034).Active then
        do_log("Script -> Transfer players between teams is not active. Transfer will not be finalized", "ERROR")
    end
end

function delete_transfer(sender)
    local comp_id = nil
    if sender.ClassName == 'TCEImage' then
        comp_id = string.gsub(sender.Name, "DeleteBtnImage", "")
    else
        comp_id = string.gsub(sender.Name, "DeleteBtnLabel", "")
    end
    comp_id = tonumber(comp_id)

    for i=comp_id, TransferPlayersForm.TransfersScroll.ComponentCount-1 do
        TransferPlayersForm.TransfersScroll.Component[i].Top = TransferPlayersForm.TransfersScroll.Component[i].Top - TransferPlayersForm.TransfersScroll.Component[i].Height
    end

    local num_of_transfers = readInteger('arr_NewTransfers')
    local playerid = tonumber(TransferPlayersForm.TransfersScroll[string.format('NewTransferContainerPanel%d', comp_id)][string.format('PlayerIDLabel%d', comp_id)].Caption)
    local current_teamid_comp = TransferPlayersForm.TransfersScroll[string.format('NewTransferContainerPanel%d', comp_id)][string.format('FromTeamId%d', comp_id)]
    local current_teamid = nil
    if current_teamid_comp.ClassName == 'TEdit' or current_teamid_comp.ClassName == 'TCEEdit' then
        current_teamid = tonumber(current_teamid_comp.Text)
    else
        current_teamid = tonumber(current_teamid_comp.Items[current_teamid_comp.ItemIndex])
    end
    local new_teamid = tonumber(TransferPlayersForm.TransfersScroll[string.format('NewTransferContainerPanel%d', comp_id)][string.format('ToTeamId%d', comp_id)].Text)

    do_log(string.format("Delete Transfer. PlayerID: %d, CurrentTeamID: %d, NewTeamID: %d", playerid, current_teamid, new_teamid), 'INFO')

    rewrite_transfers = {}
    local transfer_is_in_queue = false
    for i=0, num_of_transfers do
        local pid = readInteger(string.format('arr_NewTransfers+%s', string.format('%X', i * 20 + 4)))
        local ntid = readInteger(string.format('arr_NewTransfers+%s', string.format('%X', i * 20 + 8)))
        local ctid = readInteger(string.format('arr_NewTransfers+%s', string.format('%X', i * 20 + 12)))
        local rl_clause = readInteger(string.format('arr_NewTransfers+%s', string.format('%X', i * 20 + 16)))
        local cl = readInteger(string.format('arr_NewTransfers+%s', string.format('%X', i * 20 + 20)))
        if pid == playerid and ctid == current_teamid and ntid == new_teamid then
            transfer_is_in_queue = true
        else
            table.insert(rewrite_transfers, pid)
            table.insert(rewrite_transfers, ctid)
            table.insert(rewrite_transfers, ntid)
            table.insert(rewrite_transfers, rl_clause)
            table.insert(rewrite_transfers, cl)
        end
    end

    if transfer_is_in_queue then
        do_log("^Transfer in queue", 'INFO')
        for i=1, #rewrite_transfers do
            writeInteger(
                string.format('arr_NewTransfers+%s', string.format('%X', i * 4)),
                rewrite_transfers[i]
            )
        end
        writeInteger('arr_NewTransfers', num_of_transfers - 1)
    end
    
    sender.Owner.Visible = false
    CUSTOM_TRANSFERS = CUSTOM_TRANSFERS - 1
end