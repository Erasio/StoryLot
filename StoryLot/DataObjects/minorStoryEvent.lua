return function(DataObjects)
	local StoryEdge = class('StoryEdge')

    function StoryEdge:initialize(deltaState, text, char)
        self.text = text or "No text provided"
        self.deltaState = deltaState
    end

    function StoryEdge:getString(char)
        local str = string.gsub(self.text, "%$char%$", char:getId())
    	return str
    end

    function StoryEdge.load(filename)
    	local saveString = love.filesystem.read(filename)
    	local edgeData = json.decode(saveString)

    	local newStoryEdge = StoryEdge(
    		DataObjects.World.loadFromJson(edgeData.world),
    		edgeData.text
		)


    	return newStoryEdge
    end

    return StoryEdge
end