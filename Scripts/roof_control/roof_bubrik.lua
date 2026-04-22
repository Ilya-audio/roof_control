-- @description roof_bubrik - roof|control backend service
-- @version 0.95
-- @author Ilya
-- @about
--   Part of the Roof|control headphone monitoring system.
--   Handles database synchronization, profile saving, and toolbar states.
--   https://github.com/Ilya-audio/roof_control

local mem_name = "roof_mem"
reaper.gmem_attach(mem_name)

local res_path = reaper.GetResourcePath()
local sep = package.config:sub(1,1) 

-- Пути для Backend
local base_dir = res_path .. sep .. "Data" .. sep .. "roof_control"
local src_dir = base_dir .. sep .. "phones_eq"
local db_path = base_dir .. sep .. "hp.db"

-----------------------------------------------------------
-- БЛОК ТУЛБАРА (OPTIMIZED LOGIC)
-----------------------------------------------------------
local last_visual_mode = -1
local button_ids = {}

-- Твои хеши кнопок
local mode_buttons = {
    [0] = "_RSc5baed1e3a0d5a5f102eac5ed4fb116e7571a8fd", -- main
    [1] = "_RS3adcbd2aea112bb9d6de420ba8e89440d3e7e7b8", -- subwoofer
    [2] = "_RSd2de92f0cdb4327be8b70394921f86f8cb40076f", -- slew
    [3] = "_RSee2e93f9a0ab95384ab026464b1c1396f84c1e62", -- cubes
    [4] = "_RS3f6a8479b0c85a2a4c1759ceda74033a6ea81073", -- smartphone
    [5] = "_RS520d8a71c2f0f333cebfe450beac00ae464d386c", -- vinyl
    [6] = "_RS002678f56047caa4e3915fb964ab62e444949bbf"  -- fullrange
}

function InitButtonIDs()
    for mode, hash in pairs(mode_buttons) do
        local id = reaper.NamedCommandLookup(hash)
        if id and id > 0 then
            button_ids[mode] = id
        end
    end
end

function UpdateToolbarStates()
    local current_mode = reaper.gmem_read(3)
    local source_from_button = reaper.gmem_read(4) -- 1 = от кнопки, 0 = от JSFX
    
    if current_mode ~= last_visual_mode then
        if source_from_button == 1 then
            -- Если кнопка сама себя зажгла, просто сбрасываем флаг
            reaper.gmem_write(4, 0) 
            last_visual_mode = current_mode
        else
            -- Если переключили в JSFX, обновляем иконки (с задержкой defer)
            for mode, cmd_id in pairs(button_ids) do
                if cmd_id and cmd_id > 0 then
                    local state = (mode == current_mode) and 1 or 0
                    reaper.SetToggleCommandState(0, cmd_id, state)
                    reaper.RefreshToolbar2(0, cmd_id)
                end
            end
            last_visual_mode = current_mode
        end
    end
end

-----------------------------------------------------------
-- ФУНКЦИИ BACKEND (DB & FILES)
-----------------------------------------------------------

function GetFolderFiles()
    local files = {}
    local i = 0
    repeat
        local name = reaper.EnumerateFiles(src_dir, i)
        if name then
            if name:lower():match("%.txt$") then table.insert(files, name) end
        end
        i = i + 1
    until not name
    table.sort(files)
    return files
end

function GetStoredFiles()
    local files = {}
    local f = io.open(db_path, "r")
    if f then
        for line in f:lines() do
            local clean_line = line:gsub("%s+", "")
            if clean_line ~= "" then table.insert(files, clean_line) end
        end
        f:close()
    end
    table.sort(files)
    return files
end

function SyncDatabase()
    local folder_files = GetFolderFiles()
    local stored_files = GetStoredFiles()
    local update_needed = (#folder_files ~= #stored_files)
    if not update_needed then
        for i = 1, #folder_files do
            if folder_files[i] ~= stored_files[i] then update_needed = true break end
        end
    end
    if update_needed then
        local f = io.open(db_path, "w")
        if f then
            for _, v in ipairs(folder_files) do f:write(v .. "\n") end
            f:close()
        end
    end
    reaper.gmem_write(1, #folder_files)
    reaper.gmem_write(2, 2) 
end

function CheckDB()
    local f = io.open(db_path, "r")
    if f then f:close() else
        local new_f = io.open(db_path, "w")
        if new_f then new_f:write("") new_f:close() end
    end
    reaper.gmem_write(2, 1) 
end

function SaveProfile()
    local gain = reaper.gmem_read(1)
    local chars = {}
    for i = 0, 255 do
        local ch = reaper.gmem_read(10 + i)
        if ch == 0 then break end
        chars[#chars+1] = string.char(ch)
    end
    local filename = table.concat(chars)
    if filename == "" then return end
    local full_path = src_dir .. sep .. filename
    local lines = {}
    local f = io.open(full_path, "r")
    if not f then return end
    for line in f:lines() do table.insert(lines, line) end
    f:close()
    local f = io.open(full_path, "w")
    if not f then return end
    for _, line in ipairs(lines) do
        if line:match("Preamp:") then f:write(string.format("Preamp: %.2f dB\n", gain))
        else f:write(line .. "\n") end
    end
    f:close()
    reaper.gmem_write(2, 3)
end

-----------------------------------------------------------
-- MAIN LOOP
-----------------------------------------------------------

function Main()
    -- Сообщаем, что бэкенд жив
    reaper.gmem_write(5, 1)

    local cmd = reaper.gmem_read(0)
    if cmd == 1 then
        reaper.gmem_write(0, 0)
        SyncDatabase()
    elseif cmd == 2 then
        reaper.gmem_write(0, 0)
        CheckDB()
    elseif cmd == 3 then
        reaper.gmem_write(0, 0)
        SaveProfile()
    end

    UpdateToolbarStates()
    reaper.defer(Main)
end

-- При выходе обнуляем статус "живучести"
reaper.atexit(function()
    reaper.gmem_write(5, 0)
end)

-- СТАРТ
InitButtonIDs()
CheckDB()
SyncDatabase()
Main()
