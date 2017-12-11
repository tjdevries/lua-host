local RemoteApi = {}
RemoteApi.init = function(self, obj, api_prefix)
  self._obj = obj
  self._api_prefix = api_prefix
end
local RemoteMap = {}
-- TODO(tjdevries): "__contains__"
RemoteMap.init = function(self, obj, get_method, set_method)
  -- TODO(tjdevries): Why does python have: "self_obj" as an optional argument

  local required_attrs = { 'request' }
  for _, attr in ipairs(required_attrs) do
    if obj[attr] == nil then
      error('Invalid Remote Map: ' .. tostring(obj))
    end
  end

  self._get = function(key)
    return self.obj.request(get_method, key)
  end

  self._set = nil
  if set_method ~= nil then
    self._set = function(key, value)
      return self.obj.request(set_method, key, value)
    end
  end
end
RemoteMap.__index = function(self, key)
  return self._get(key)
end
RemoteMap.__newindex = function(self, key, value)
  if self._set == nil then
    error('This dict is read-only')
  end

  self._set(key, value)
end
RemoteMap.get = function(self, key, default)
  local status, result = pcall(self._get, key)

  if not status then
    return default
  end

  return result
end

-- Base  class for Neovim objects (buffer/window/tabpage).
local Remote = {}
Remote.init = function(self, session, code_data)
  if self._type == nil then
    self._type = 'Remote'
  end

  self._session = session
  self.code_data = code_data
  self.api = RemoteApi:init(self, self._api_prefix)
  self.vars = RemoteMap:init(self, self._api_prefix .. 'get_var', self._api_prefix .. 'set_var')
  self.options = RemoteMap:init(self, self._api_prefix .. 'get_option', self._api_prefix .. 'get_var')

  return self
end
Remote.child = function(config)
  assert(config._type ~= nil)
  assert(config._api_prefix ~= nil)

  config.__index = function(self, key)
    if type(key) == 'number' then
      return self:_numeric_index(key)
    end

    if self._props[key] ~= nil then
      return self._props[key].get(self)
    end

    if Remote[key] ~= nil then
      return Remote[key]
    end
  end

  config.init = function(self, session, code_data)
    local new_inst = Remote.init(self, session, code_data)
    setmetatable(new_inst, self)
    return new_inst
  end

  setmetatable(config, { __index = Remote })

  return config
end
Remote.request = function(self, _type, ...)
  return self._session.request(_type, self, ...)
end

return {
  Remote = Remote,
}
