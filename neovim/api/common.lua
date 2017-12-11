local RemoteApi = {}
RemoteApi.init = function(self, obj, api_prefix)
    self._obj = obj
    self._api_prefix = api_prefix
end
local RemoteMap = {}
RemoteMap.init = function(self, obj, get_method, set_method, self_obj)
end
-- Base  class for Neovim objects (buffer/window/tabpage).
local Remote = {}

Remote.init = function(self, session, code_data)
    self.name = 'Remote'

    self._session = session
    self.code_data = code_data
    self.api = RemoteApi:init(self, self._api_prefix)
end

Remote.child = function(name)
    local new_class = {
        name = name
    }
    local class_mt = { __index = new_class }

    new_class.init = function(_)
        local new_inst = {}
        setmetatable(new_inst, class_mt)
        return new_inst
    end

    setmetatable(new_class, { __index = Remote })

    return new_class
end

return {
    Remote = Remote,
}
