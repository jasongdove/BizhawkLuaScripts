-- sorted pairs
function spairs(t, order)
  -- collect the keys
  local keys = {}
  for k in pairs(t) do keys[#keys+1] = k end
  
  -- if order function given, sort by it by passing the table and keys a, b
  -- otherwise just sort the keys
  if order then
    table.sort(keys, function(a, b) return order(t, a, b) end)
  else
    table.sort(keys)
  end
  
  -- return the iterator function
  local i = 0
  return function()
    i = i + 1
    if keys[i] then
      return keys[i], t[keys[i]]
    end
  end
end

function pressAndRelease(bot_context, keys, key)
  if bot_context.press_and_release == nil then
    bot_context.press_and_release = {}
    bot_context.press_and_release.press_frame = emu.framecount()
    bot_context.press_and_release.release_frame = emu.framecount() + 4
  end
  
  local framecount = emu.framecount()
  if framecount < bot_context.press_and_release.release_frame then
    keys[key] = true
  else
    keys[key] = false
    bot_context.press_and_release = nil
  end
end
