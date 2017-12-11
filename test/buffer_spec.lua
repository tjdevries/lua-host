
local Buffer = require('neovim.api.buffer').Buffer

describe('Buffer', function()
    it('should be able to get its name', function()
        local b = Buffer:init()
        assert.are.same('BUFFER NAME', b.name)
    end)
end)
