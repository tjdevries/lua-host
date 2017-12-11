local Remote = require('neovim.api.common').Remote

describe('Remote', function()
    it('should allow children', function()
        local Example = Remote.child('example')

        local e = Example:init()
        assert.are.same('example', e.name)
    end)
end)
