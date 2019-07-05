-- MAIN FORM HELPERS

function set_ce_mem_scanner_state()
    -- Hide/show mem scanner
    local main_form = getMainForm()

    -- local min_h = 378 -- default one

    main_form.Panel5.Constraints.MinHeight = 65
    main_form.Panel5.Height = 65

    local comps = {
        "Label6", "foundcountlabel", "sbOpenProcess", "lblcompareToSavedScan",
        "ScanText", "lblScanType", "lblValueType", "SpeedButton2", "btnNewScan",
        "gbScanOptions", "Panel2", "Panel3", "Panel6", "Panel7", "Panel8",
        "btnNextScan", "ScanType", "VarType", "ProgressBar", "UndoScan",
        "scanvalue", "btnFirst", "btnNext", "LogoPanel", "pnlScanValueOptions",
        "Panel9", "Panel10", "Foundlist3", "SpeedButton3", "UndoScan"
    }

    for i=1, #comps do
        main_form[comps[i]].Visible = false
    end

    -- main_form.Label6.Visible = not main_form.Label6.Visible
    -- main_form.foundcountlabel.Visible = not main_form.foundcountlabel.Visible
    -- main_form.sbOpenProcess.Visible = not main_form.sbOpenProcess.Visible
    -- main_form.lblcompareToSavedScan.Visible = not main_form.lblcompareToSavedScan.Visible
    -- main_form.ScanText.Visible = main_form.ScanText.Visible

    -- main_form.lblScanType.Visible = state
    -- main_form.lblValueType.Visible = state
    -- main_form.SpeedButton2.Visible = state
    -- main_form.btnNewScan.Visible = state
    -- main_form.gbScanOptions.Visible = state
    -- main_form.Panel2.Visible = state
    -- main_form.Panel3.Visible = state
    -- main_form.Panel6.Visible = state
    -- main_form.Panel7.Visible = state
    -- main_form.Panel8.Visible = state
    -- main_form.btnNextScan.Visible = state
    -- main_form.ScanType.Visible = state
    -- main_form.VarType.Visible = state
    -- main_form.ProgressBar.Visible = state
    -- main_form.UndoScan.Visible = state
    -- main_form.scanvalue.Visible = state
    -- main_form.btnFirst.Visible = state
    -- main_form.btnNext.Visible = state
    -- main_form.LogoPanel.Visible = state
    -- main_form.pnlScanValueOptions.Visible = state
    -- main_form.Panel9.Visible = state
    -- main_form.Panel10.Visible = state

    -- main_form.Foundlist3.Visible = state
    -- main_form.SpeedButton3.Visible = state
    -- main_form.UndoScan.Visible = state
end

function update_status_label(text)
    MainWindowForm.LabelStatus.Caption = text
end

function deactive_all(record)
    for i=0, record.Count-1 do
        if record[i].Active then record[i].Active = false end
        if record.Child[i].Count > 0 then
            deactive_all(record.Child[i])
        end
    end
end
