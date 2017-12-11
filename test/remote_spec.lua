local Remote = require('neovim.api.common').Remote

describe('Remote', function()
    it('should allow children', function()
        local Example = Remote.child({
            _type = 'example',
            _api_prefix = 'ex',

            _props = {
                this_works = {
                    get = function(_) return 25 end,
                    set = function(_, _) return 10 end,
                }
            }
        })
        Example.__index = function(self, idx)
            if self._props[idx] ~= nil then
                return self._props[idx].get(self)
            end
        end

        local e = Example:init()
        assert.are.same('example', e._type)
        assert.are.same(25, e.this_works)
    end)
end)
