-- MAIN FORM HELPERS

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
