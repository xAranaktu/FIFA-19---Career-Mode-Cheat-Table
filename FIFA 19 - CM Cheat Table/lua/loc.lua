require 'lua/commons';

function create_loc_file(lang)
    local scripts = getAddressList().getMemoryRecordByDescription('Scripts')  -- Parent containing all scripts
    if scripts == nil then return end

    local path = string.format("loc/%s.csv", lang)
    local current_loc = {}
    if file_exists(path) then
        current_loc = load_loc_file(lang)[1]
    end
    local f = io.open(path, "w+")
    write_to_loc_file(scripts, f, {}, current_loc)
    io.close(f)
    print("GOTOWE")
end

function write_to_loc_file(record, f, keys, current_loc)
    local key = ""
    for i=0, record.Count-1 do
        key = record.Child[i].Description
        if current_loc[key] ~= nil then
            f:write(string.format("%s;%s", key, current_loc[key]), "\n")
        elseif keys[key] == nil then
            f:write(string.format("%s;%s", key, key), "\n")
        end
        keys[key] = key
        if record.Child[i].Count > 0 then
            write_to_loc_file(record.Child[i], f, keys, current_loc)
        end
    end
end

function load_loc_file(lang)
    local path = string.format("loc/%s.csv", lang)
    local loc = {}
    local reverse_loc = {}
    
    local splited_line = {}
    for line in io.lines(path) do
        splited_line = split(line, ";")
        loc[splited_line[1]] = splited_line[2]
        reverse_loc[splited_line[2]] = splited_line[1]
    end
    return {loc, reverse_loc}
end

create_loc_file('eng')
loc = load_loc_file('eng')[1]
print(loc['preferredposition4'])