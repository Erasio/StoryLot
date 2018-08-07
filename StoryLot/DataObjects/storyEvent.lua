local StoryEvent = class("StoryEvent")

function StoryEvent:initialize(content)
	for k,v in pairs(table_name) do
		self.data[k] = v
	end
end

function StoryEvent:__tostring()
	local str = "Instance of class StoryEvent;\n  Data: "
	for k, entry in pairs(self.data) do
		str = str .. "\n  " .. k .. "    " tostring(entry)
	end
	return str
end

function StoryEvent:get(name)
	return self.data[name]
end

function StoryEvent:getSaveTable()
	return self.data
end

return StoryEvent