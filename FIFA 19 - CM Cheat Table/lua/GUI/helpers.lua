-- GUI Helpers
require 'lua/helpers';

local ComponentsExtraData = {}

function UpdateCBComponentHint(sender)
    sender.Hint = sender.Items[sender.ItemIndex]
end

function SaveOriginalWidth(sender)
    if ComponentsExtraData[sender.Name] == nil then
        ComponentsExtraData[sender.Name] = {
            Width = sender.Width
        }
    end
end

function MakeComponentWider(sender)
    if ComponentsExtraData[sender.Name] == nil then return end

    if sender.Width <= ComponentsExtraData[sender.Name]['Width'] then
        sender.bringToFront()
        sender.Width = sender.Width + 60
    end
end

function MakeComponentShorter(sender)
    if ComponentsExtraData[sender.Name] == nil then return end

    if sender.Width > ComponentsExtraData[sender.Name]['Width'] then
        sender.sendToBack()
        sender.Width = sender.Width - 60
    end
end


-- load player head
-- return string stream
function load_headshot(playerid, headtypecode, haircolorcode)
    if not playerid then
        return load_img('heads/notfound.png', 'https://fifatracker.net/static/img/assets/common/heads/notfound.png')
    end

    local fpath = nil
    local iplayerid = tonumber(playerid)

    if iplayerid < 280000 then
        -- heads
        fpath = string.format('heads/p%d.png', playerid)
    else
        -- youthheads
        if headtypecode == 0 then
            fpath = string.format('youthheads/p%d.png', haircolorcode)
        else
            fpath = string.format('youthheads/p%d%02d.png', headtypecode, haircolorcode)
        end
    end
    local url = string.format('https://fifatracker.net/static/img/assets/%d/%s', FIFA, fpath)
    local img_ss = load_img(fpath, url)
    
    -- If file is not a png file use notfound.png
    if not img_ss then return load_img('heads/notfound.png', 'https://fifatracker.net/static/img/assets/common/heads/notfound.png') end
    
    return img_ss
end

function load_crest(teamid)
    local fpath = string.format('crest/l%d.png', teamid)
    local url = string.format('https://fifatracker.net/static/img/assets/%d/%s', FIFA, fpath)

    local img_ss = load_img(fpath, url)
    
    -- If file is not a png file use notfound.png
    if not img_ss then return load_img('crest/notfound.png', 'https://fifatracker.net/static/img/assets/common/crest/notfound.png') end
    
    return img_ss
end

-- load img
-- return string stream
function load_img(path, url)
    local img = nil
    
    local f=io.open(CACHE_DIR .. path, "rb")
    if f ~= nil then
        -- load from cache_dir
        img = f:read("*a")
        io.close(f)
    else
        -- load from internet and save in cache_dir
        local int=getInternet()
        img=int.getURL(url)
        int.destroy()
        -- If file is not a png file
        if img == nil or string.sub(img, 2, 4) ~= 'PNG' then
            do_log('Img is nil: '.. url, 'WARNING')
            return false
        end
        f, err=io.open(CACHE_DIR .. path, "w+b")
        if f then
            f:write(img)
            io.close(f)
        else
            do_log('Error opening img file: ' .. CACHE_DIR .. path)
            do_log('Error - ' .. err)
        end
    end
    return createStringStream(img)
end

function convert_from_days(days)
    return FIFA_EPOCH_TIME + (tonumber(days)*24*60*60)
end

function days_to_date(args)
    local comp_desc = args['comp_desc']
    
    local fifa_date_rec_id = comp_desc['id']
    return os.date("%d/%m/%Y", convert_from_days(ADDR_LIST.getMemoryRecordByID(fifa_date_rec_id).Value))
end

function convert_to_days(date)
    return math.floor((date - FIFA_EPOCH_TIME) / (24*60*60))
end

function date_to_days(args)
    local component = args['component']
    local d, m, y = string.match(component.Text, "(%d+)/(%d+)/(%d+)")
    if (not d) or (not m) or (not y) then
        do_log(string.format("Invalid date format in %s component: %s doesn't match DD/MM/YYYY pattern", component.Name, component.Text), 'ERROR')
        return 157195 -- 03/03/2013
    end

    local new_date = os.time{
        year=tonumber(y),
        month=tonumber(m),
        day=tonumber(d)
    }
    return convert_to_days(new_date)
end