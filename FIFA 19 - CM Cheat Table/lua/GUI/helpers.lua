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

-- Make window resizeable
RESIZER= {
    allow_resize = false
}
function ResizerMouseDown(sender, button, x, y)
    RESIZER = {
        allow_resize = true,
        w = sender.Owner.Width,
        h = sender.Owner.Height,
        mx = x,
        my = y
    }
end

function ResizerMouseMove(sender, x, y)
    if RESIZER['allow_resize'] then
        RESIZER['w'] = x - RESIZER['mx'] + sender.Owner.Width
        RESIZER['h'] = y - RESIZER['my'] + sender.Owner.Height
    end
end
function ResizerMouseUp(sender, button, x, y)
    RESIZER['allow_resize'] = false
    sender.Owner.Width = RESIZER['w']
    sender.Owner.Height = RESIZER['h']
end

-- stay on top
function AlwaysOnTopClick(sender)
    if sender.Owner.FormStyle == "fsNormal" then
        sender.Owner.AlwaysOnTop.Visible = false
        sender.Owner.AlwaysOnTopOn.Visible = true
        sender.Owner.FormStyle = "fsSystemStayOnTop"
    else
        sender.Owner.AlwaysOnTop.Visible = true
        sender.Owner.AlwaysOnTopOn.Visible = false
        sender.Owner.FormStyle = "fsNormal"
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

function get_btn_img()
    return {
        [["1754506F727461626C654E6574776F726B47726170686963EF06000089504E47
        0D0A1A0A0000000D49484452000000A10000003808060000009538983D000000
        06624B4744003400380043684F013B000000097048597300000B1300000B1301
        009A9C180000000774494D4507E20C17101611F568A45B0000001D6954587443
        6F6D6D656E7400000000004372656174656420776974682047494D50642E6507
        000006534944415478DAED9CCB6EDB461486FF2147BE418ED216E80304685114
        419779892EB269BA2CFA127D893E491FA0AFD15D964552340810A78E2D4B8C6C
        5DC8D38586D2703437522265CBE70084645EADE177AE431E808565CF221AEE27
        78E8581C4281BF374446C2278CEF0C228B0F40B2004875215C81F6EC9BE7DF12
        91E8F7073FA652FE2C44F21CC0298F777B2E89026E871C1680EE816520604254
        BCCEF3FC8F6C74FD2744426FFF7EFDC607A3F48C470220C9F35C0E9E7EF55B9A
        CA5F1895EE7C58681B35384F5DA5A09A0AA494E04C88E445229317E7832F7FB8
        195EFE0E200550A865E3D48907C01480ECF7072F1940568AD0BE647C2700692A
        7FEDF79FBE54C62ED578133E082B0002384965EFA7EAA977B9F87E826B9F5DEB
        3C4B9B227BBD57004E2C205ADD71997C94101E03384B12F15D37FA460DF66913
        4411792D61D92EB408CDFC7C64B1AE10DF0338B35899D5A049CB8826007A8ADE
        7321C4093BA4BAFB5144B2D845AA439EF5A293944688E404C0B98A07732D3624
        D3129A56F048D13B608772684A447BF02A180098AB65614048B6C4446A103EE1
        9BC9B20379A2783A527CE975E74A90685AC2A5196D922BC4EC678D0E38E73850
        39C7B2B67C644B4E5C898954109E6D952BC482D53688AE3028B40D815089B051
        2463B1CA994A74A5E2AB62095D898954C9C9F141854754735B8C32EC4A716C79
        842FB74020F1BE5F4A71AC78D2215CFD121784AB5A216D317E75C7E2511B93A6
        D322D4E0F836126FE1F5303DCD0D3B2DA130EEBF1E1F06F1A01D1A88B6C34101
        7B45CF358EAC340D15A6AA1C254BC23664AEB9632D3EECBAC6651678017B4DCB
        15B8F90235021963B06D299C5A1E0104BC6DAC02ED59614CEB277C108AC890BC
        E3008E22D56E5768D54506081786E33188CDD3EAFECA2ECD88E39AD601906069
        C137B970DA57EDC9655B2962BFD84C68BD9DFC5C4643C80FAE1EA4A2C4DAD618
        CFB2BB87C912BE412CFB168690852164610927261411EF86C2505FE18DA7BB18
        C25612C35DAD6F33518C4922434AC20A740F207CC889626C12197B4CDB0AE37B
        80FB817B1959FFAEB90AB0B6C7D95DFB77F764EFC1284CD3B9D12E6BF340A3FA
        BCAC6F38FCEF370BF5B9FE3FAAFB95A5CC72026DFD7F9215C7D8776CAB7FDB94
        2166445DD381AEA2ED23578C186F423B80B00BE5AD3B2917DE8F6A8E585589D6
        C891B10769A89277C6DA87B03B400DF95FD433310FE4252B9EB6DBC2C36D33A3
        1DDE23EEEA2E9BBF46982A0A150A239B6574B10AC4101EB4D2C42A40F36770DB
        7BBA978BD52C7B178690852164616108591E008475FA1A35F9AC13FBB21CA434
        98318948D1829F2A9D276C1615C857646E50EB8A7D95D25711E7099DBD40D8F2
        F3E81DCE41592F65A1901CC0974A41A18BECE8DDBCD08C27B05DFDFA215AC282
        284F84480F4BF7EABE47472D9CB3C665C9A63CDA7732BD880B7AD7F60604473E
        8D44459E877E78121A82F97C366487711F95872C81BBEB7B687B6CF0AF2DE44A
        0EB0DE4684F9ACC20FC52626FA598B4976F3AEAD3EADBE3C0711EBB887D27D54
        92EA9DC8B2D1BF58B782B3867989E3685207E6D9F8E67D361E5EECF7A7D8D76D
        A9CB5B3537AEDB588C62BCED8121391A0D3F64E3E17BAC1B645A6FA3B48C55A1
        1DB48010F9D5E5C53F7777B7E8F7075F1C1D9FF49224E1EE173520EB12C49850
        2DA6E6D0B430901705CDA677F36C3CBCFA9C8DDE2669BAC0B239A6D9A5954210
        96074EAF2E3FFC05E0D9F0FABFCF00BEC6B2EBE629D68DB01BD64E580E4C3F73
        C5CD2D801B001F01BC03F006C0148E2EAD00485A3C5B09E114C004400660A44E
        5CB68A9B63DD694930841C082A08E78A991BB58C143F13C5D32264094973C333
        45F418C035803E965D36A14E56B67E6508597408671A841F015C2A7EC68AA799
        E696BD31E1423BD908C0270DC0995AA7439830848F1EC2C28070A400BC50FC8C
        D4FA99E2CB6A09CB15858568A9019829AB788A6AE3438690212CDDF1ADE2E45A
        01F8497134312CE10A445762320770A79570F480B3EC3FCC31218B2D262C7389
        B1964B8C154F732331B1C684BA359C6A7F9701E710CB86EAA615640819C2C200
        F156313351004E6D56D0660961048D6498D9236CF61FE6120D435872A38338D3
        96B24EB89194B8E031DA05AFBAF9A7067C0C208B0BC442836E81CD22358520D4
        D7EB300AC3FD72234D169B5BD6DD3321306F1C03900923183E96088BE87A4CC7
        0B1922610403C812092242F06D031303C8521744AFFC0F3D137F292D74570B00
        00000049454E44AE426082"]]
    }
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
            return false
        end
        f, err=io.open(CACHE_DIR .. path, "w+b")
        if f then
            f:write(img)
            io.close(f)
        else
            do_log('Error opening img file: ' .. CACHE_DIR .. path)
            if err then
                do_log('Error - ' .. err)
            end
        end
    end
    return createStringStream(img)
end

function convert_from_days(days)
    if not days then return nil end

    local result = FIFA_EPOCH_TIME + (tonumber(days)*24*60*60)
    if result < 1 then
        -- For very old players return 1 (age around 50)
        result = 1
    end

    return result
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