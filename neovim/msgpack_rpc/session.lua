local uv = require('luv')
local MsgpackRpcStream = require('neovim.msgpack_rpc.stream')

local Session = {}
Session.__index = Session

Session.init = function(stream)
  return setmetatable({
    _msgpack_rpc_stream = MsgpackRpcStream.init(stream),
    _pending_messages = {},
    _prepare = uv.new_prepare(),
    _timer = uv.new_timer(),
    _is_running = false,
  }, Session)
end

Session.next_message = function(self, timeout)
  local on_request = function(method, args, response)
    table.insert(self._pending_messages, {'request', method, args, response})
    uv.stop()
  end

  local on_notification = function(method, args)
    table.insert(self._pending_messages, {'notification', method, args})
    uv.stop()
  end

  if self._is_running then
    error('Event loop already running')
  end

  if #self._pending_messages > 0 then
    return table.remove(self._pending_messages, 1)
  end

  self:_run(on_request, on_notification, timeout)
end

return Session
