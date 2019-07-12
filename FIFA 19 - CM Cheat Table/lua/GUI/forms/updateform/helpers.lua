function check_for_ct_update()
    if CFG_DATA.flags.check_for_update then
        local new_version_is_available = false
        local r = getInternet()

        local patrons_version = r.getURL("https://pastebin.com/raw/RUstCP9N")
        local free_version = r.getURL("https://pastebin.com/raw/fN0RXF7V")
        r.destroy()

        -- no internet?
        if (patrons_version == nil) or (free_version == nil) then
            do_log("CT Update check failed. No internet?", 'INFO')
            return false
        end

        do_log(string.format('Patrons ver -  %s, free ver - %s', patrons_version, free_version))

        local ipatronsver, _ = string.gsub(
            patrons_version, '%.', ''
        )
        ipatronsver = tonumber(ipatronsver)

        local ifreever, _ = string.gsub(
            free_version, '%.', ''
        )
        ifreever = tonumber(ifreever)

        local current_ver = get_ct_version()
        local icurver, _ = string.gsub(
            current_ver, '%.', ''
        )
        icurver = tonumber(icurver)

        if CFG_DATA.flags.only_check_for_free_update then
            if CFG_DATA.other.ignore_update == free_version then
                return false
            end
            if ifreever > icurver then
                return {
                    current_ver = current_ver,
                    patrons_version = patrons_version,
                    free_version = free_version,
                    free_update = ifreever > icurver,
                    patron_update = ipatronsver > icurver
                }
            end
        else
            if (ifreever > icurver) or (ipatronsver > icurver) then
                if CFG_DATA.other.ignore_update == patrons_version then
                    return false
                end

                return {
                    current_ver = current_ver,
                    patrons_version = patrons_version,
                    free_version = free_version,
                    free_update = ifreever > icurver,
                    patron_update = ipatronsver > icurver
                }
            end
        end
    end

    return false
end
