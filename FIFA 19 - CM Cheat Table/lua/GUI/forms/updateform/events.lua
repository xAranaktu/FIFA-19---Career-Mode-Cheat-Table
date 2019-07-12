require 'lua/GUI/consts';
require 'lua/GUI/forms/updateform/consts';
require 'lua/GUI/forms/updateform/helpers';
-- UpdateForm Events

-- Make window dragable
function UpdateTopPanelMouseDown(sender, button, x, y)
    UpdateForm.dragNow()
end

-- onShow
function UpdateFormShow(sender)
    MainWindowForm.hide()

    UpdateForm.BorderStyle = bsNone

    local current_ver = CHECK_CT_UPDATE['current_ver']
    local patrons_version = CHECK_CT_UPDATE['patrons_version']
    local free_version = CHECK_CT_UPDATE['free_version']
    local free_update = CHECK_CT_UPDATE['free_update']
    local patron_update = CHECK_CT_UPDATE['patron_update']

    UpdateForm.curVerLabel.Caption = string.gsub(
        UpdateForm.curVerLabel.Caption, 'x.x.x', current_ver
    )

    UpdateForm.patronVerLabel.Caption = string.gsub(
        UpdateForm.patronVerLabel.Caption, 'x.x.x', patrons_version
    )

    UpdateForm.freeVerLabel.Caption = string.gsub(
        UpdateForm.freeVerLabel.Caption, 'x.x.x', free_version
    )

    if free_update then
        UpdateForm.DownloadBtnFree.Visible = true
    end

    if patron_update then
        UpdateForm.DownloadBtnPatron.Visible = true
    end
end

-- Minimize
function UpdateMinimizeClick(sender)
    UpdateForm.WindowState = "wsMinimized" 
end

-- Close
function UpdateExitClick(sender)
    UpdateForm.close()
    MainWindowForm.show()
    before_start()
end

function ChangelogLabelLinkClick(sender)
    shellExecute("https://raw.githubusercontent.com/xAranaktu/FIFA-19---Career-Mode-Cheat-Table/master/changelog.txt")
end
function ReleaseScheduleLabelLinkClick(sender)
    shellExecute("https://docs.google.com/spreadsheets/d/1EsYf4I4oDD6kw5jTGTFsv7rR1qL-Oausd1ZRbbSWm84/edit")
end
function DownloadBtnPatronClick(sender)
    shellExecute(string.format(
        "https://www.patreon.com/xAranaktu/posts?tag=v%s", CHECK_CT_UPDATE['patrons_version']
    ))
end
function DownloadBtnFreeClick(sender)
    shellExecute(string.format(
        "https://www.patreon.com/xAranaktu/posts?tag=v%s", CHECK_CT_UPDATE['free_version']
    ))
end
function DontShowAgainCBChange(sender)
    CFG_DATA.flags.check_for_update = sender.State == 0
    save_cfg()
end
function IgnoreBtnClick(sender)
    if CHECK_CT_UPDATE['free_update'] then
        CFG_DATA.other.ignore_update = CHECK_CT_UPDATE['free_version']
    elseif CHECK_CT_UPDATE['patron_update'] then
        CFG_DATA.other.ignore_update = CHECK_CT_UPDATE['patrons_version']
    end
    save_cfg()
    UpdateForm.close()
    MainWindowForm.show()
    before_start()
end

function NotNowBtnClick(sender)
    UpdateForm.close()
    MainWindowForm.show()
    before_start()
end
