-- @description Roof|control: SLEW (Mode Switch)
-- @version 1.0.0
-- @author Ilya
-- @link https://github.com/Ilya-audio/roof_control
-- @about
--    Part of the Roof|control headphone monitoring system.
--    This script switches the monitoring mode to "Slew" (Transient Control) via gmem.

local this_mode = 2 -- Индекс для Slew

reaper.gmem_attach("roof_mem")

-- 1. core test: if no bubrik - button is down
if reaper.gmem_read(5) ~= 1 then 
    local _, _, section_id, cmd_id = reaper.get_action_context()
        reaper.SetToggleCommandState(section_id, cmd_id, 0)
        reaper.RefreshToolbar2(section_id, cmd_id)
    return 
end

-- 2. Контекст текущего вызова
local _, _, section_id, cmd_id = reaper.get_action_context()

-- 3. Реестр хешей всех кнопок системы
local mode_buttons = {
    [0] = "_RSc5baed1e3a0d5a5f102eac5ed4fb116e7571a8fd", -- main
    [1] = "_RS3adcbd2aea112bb9d6de420ba8e89440d3e7e7b8", -- subwoofer
    [2] = "_RSd2de92f0cdb4327be8b70394921f86f8cb40076f", -- slew
    [3] = "_RSee2e93f9a0ab95384ab026464b1c1396f84c1e62", -- cubes
    [4] = "_RS3f6a8479b0c85a2a4c1759ceda74033a6ea81073", -- smartphone
    [5] = "_RS520d8a71c2f0f333cebfe450beac00ae464d386c", -- vinyl
    [6] = "_RS002678f56047caa4e3915fb964ab62e444949bbf"  -- fullrange
}

-- 4. Мгновенная синхронизация тулбара силами самого скрипта
local function SyncToolbarNow()
    for mode, hash in pairs(mode_buttons) do
        local target_id = reaper.NamedCommandLookup(hash)
        if target_id and target_id > 0 then
            -- Включаем SLEW (1), выключаем все остальные (0)
            local state = (mode == this_mode) and 1 or 0
            reaper.SetToggleCommandState(section_id, target_id, state)
            reaper.RefreshToolbar2(section_id, target_id)
        end
    end
end

-- 5. ИСПОЛНЕНИЕ
-- Передаем режим в JSFX (gmem[3])
reaper.gmem_write(3, this_mode)
-- Поднимаем флаг "Ручное управление" для Бубрика (gmem[4])
reaper.gmem_write(4, 1) 

-- Отрисовываем изменения в интерфейсе мгновенно
SyncToolbarNow()

