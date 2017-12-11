  --- TODO(tjdevries): documentation

-- Property functions
local get_name = function(_)
  return 'BUFFER NAME'
  -- return self.request('nvim_buf_get_name')
end

local set_name = function(self, value)
  return self.request('nvim_buf_set_name', value)
end

local Buffer = {
  _type = 'Buffer',
  _api_prefix = 'buf',

  _props = {
    name = {
      get = get_name,
      set = set_name,
    },
  },
}
Buffer = require('neovim.api.common').Remote.child(Buffer)

Buffer.__len = function(self)
  self.request('nvim_buf_line_count')
end
Buffer.__index = function(self, idx)
  if type(idx) == type(1) then
    return self.request('nvim_buf_get_lines', idx, idx, false)
  end

  if self._props[idx] ~= nil then
    return self._props[idx].get(self)
  end
end
Buffer.__newindex = function(self, idx, value)
  self.request('nvim_buf_set_lines', idx, idx, false, { value })
end
Buffer.insert = function(self, idx, value)
  -- Just like table.insert
  if value == nil then
    value = idx
    idx = #self
  end

  self[idx] = value
end
Buffer.remove = function(self, idx)
  -- Just like table.remove
  if idx == nil then
    idx = #self
  end

  local current_value = self[idx]

  self.request('nvim_buf_set_lines', idx, idx, false, {})

  return current_value
end
return {
  Buffer = Buffer
}
