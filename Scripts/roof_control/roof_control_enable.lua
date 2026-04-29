-- @description Roof|control: ENABLE (Toggle)
-- @version 1.0.0 (experimenta)
-- @author Ilya
-- @link https://github.com/Ilya-audio/roof_control
-- @about
--    Part of the Roof|control headphone monitoring system.
--    Toggles headphone EQ correction state (1 = Enabled, 0 = Disabled).

reaper.gmem_attach("roof_mem")

-- 1. Проверка бэкенда
if reaper.gmem_read(5) ~= 1 then 
    local _, _, section_id, cmd_id = reaper.get_action_context()
    reaper.SetToggleCommandState(section_id, cmd_id, 0)
    reaper.RefreshToolbar2(section_id, cmd_id)
    return 
end

-- 2. Контекст
local _, _, section_id, cmd_id = reaper.get_action_context()

-- 3. Логика (1 = Bypass, 0 = Work)
local current_mem = reaper.gmem_read(6)
local new_mem = (current_mem == 0) and 1 or 0 -- Инвертируем память

reaper.gmem_write(6, new_mem)
reaper.gmem_write(4, 1) -- Флаг для Бубрика "я сам всё сделал"

-- 4. Мгновенный отклик иконки
-- Горит (1), если в памяти 0 (режим работы)
local visual_state = (new_mem == 0) and 1 or 0
reaper.SetToggleCommandState(section_id, cmd_id, visual_state)
reaper.RefreshToolbar2(section_id, cmd_id)
