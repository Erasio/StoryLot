local Location = class('StoryLocation')

function Location:initialize(id, data)
	self.data = data or {}
	self.id = id or self:generateId()
end

function Character:__tostring()
	return "LocationId: " .. self:getId()
end

function Location:getId()
	return self.id
end

function Location:generateId()
    local template ='xxxxxxxx4xxx'
    return string.gsub(template, '[xy]', 
    	function (c)
        	local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        	return string.format('%x', v)
    	end
	)
end

return Location