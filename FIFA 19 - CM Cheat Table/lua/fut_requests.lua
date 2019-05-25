json = require 'lua/requirements/json';

FUT_URLS = {
    card_bg = 'https://www.easports.com/fifa/ultimate-team/web-app/content/7D49A6B1-760B-4491-B10C-167FBC81D58A/2019/fut/items/images/backgrounds/itemCompanionBGs/large/cards_bg_e_1_',
    display = 'https://www.easports.com/fifa/ultimate-team/api/fut/display',
    player_search = 'https://www.easports.com/fifa/ultimate-team/api/fut/item?jsonParamObject='
}

function encodeURI(str)
    if (str) then
        str = string.gsub (str, "\n", "\r\n")
        str = string.gsub (str, "([^%w ])",
            function (c) return string.format ("%%%02X", string.byte(c)) end)
        str = string.gsub (str, " ", "+")
   end
   return str
end

function fut_get_rarity_display()
    local r = getInternet()
    local request = FUT_URLS['display']
    local reply = r.getURL(request)
    if reply == nil then
        do_log('No internet connection? No reply from: ' .. request, 'ERROR')
        return nil
    end
    
    local response = json.decode(
        reply
    )
    r.destroy()

    return response
end

function fut_find_player(player_data, page)
    -- print(fut_find_player('ronaldo')['items'][1]['age'])
    if string.match(player_data, '[0-9]') then
        -- TODO player name from playerid
    end

    if page == nil then
        page = 1
    end

    local request = FUT_URLS['player_search'] .. encodeURI(string.format(
        '{"name":"%s", "page": "%d"}',
        player_data, page
    ))

    local r = getInternet()
    local reply = r.getURL(request)
    if reply == nil then
        do_log('No internet connection? No reply from: ' .. request, 'ERROR')
        return nil
    end

    local response = json.decode(
        reply
    )
    r.destroy()

    return response
end
