local Remote = require('neovim.api.common').Remote
--- TODO(tjdevries): documentation

-- Property functions
local get_name = function(self)
  return self.request('nvim_buf_get_name')
end

local set_name = function(self, value)
  return self.request('nvim_buf_set_name', value)
end

local Buffer = {
  _type = 'Buffer',
  _api_prefix = 'buf',

  _numeric_index = function(self, idx)
    return self.request('nvim_buf_get_lines', idx, idx, false)
  end,

  _props = {
    name = {
      get = get_name,
      set = set_name,
    },
  },
}
Buffer = Remote.child(Buffer)

Buffer.__len = function(self)
  self.request('nvim_buf_line_count')
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
