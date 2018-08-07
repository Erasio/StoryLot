return function(DataObjects)
    local World = class('StoryWorld')

    function World:initialize(text)
        self.characters = {}
        self.text = text
    end

    --[[function World:__tostring()
        local str = "Characters: "
        for k, character in pairs(self.characters) do
            str = str .. "\n  " .. string.gsub(tostring(character), "\n", "\n  ") .. "\n"
        end
        return str
    end]]

    -- worlds being an array consisting of world instances
    function World.getWeightedAverage(worlds, targetWorld, targetWeight)
        local averageWorld = World()
            
        local tempCharacters = {}
        for l, world in ipairs(worlds)  do
            for charId, char in pairs(world.characters) do
                if not tempCharacters[charId] then
                    tempCharacters[charId] = {}
                end

                table.insert(tempCharacters[charId], char)
            end
        end

        for charId, chars in pairs(tempCharacters) do
            averageWorld:addCharacter(
                DataObjects.Character.getWeightedAverage(chars, targetWorld.characters[charId], targetWeight)
            )
        end

        return averageWorld
    end

    -- Insert all non existing characters, attributes or relationships 
    -- with a certain deviation from the default
    function World:concat(otherWorld)
        for charId, char in pairs(otherWorld.characters) do
            
            if self.characters[charId] then
                -- Check if all attributes exist

                self.characters[charId]:concat(char, 1)
            else
                -- Insert other character

                self:addCharacter(char:copy(2))
            end
        end
    end

    -- Get the difference between two worlds
    function World:getDelta(otherWorld)
        local deltaWorld = World()

        for charId, char in pairs(self.characters) do
            if otherWorld.characters[charId] then
                deltaWorld:addCharacter(
                    char:getDelta(otherWorld.characters[charId])
                )
            end
        end

        return deltaWorld
    end

    -- 
    function World:getDeviation(storyEdge)
        local deviation = 0

        for charId, char in pairs(self.characters) do
            -- Provides the other character or nil
            if storyEdge then 
                for edgeCharId, edgeChar in pairs(storyEdge.deltaState.characters) do
                    if edgeChar.isAbstract or edgeCharId == charId then
                        deviation = deviation + char:getDeviation(edgeChar)
                    end
                end
            else
                deviaton = deviation + char:getDeviation()
            end
        end

        return deviation
    end
    
    function World:addCharacter(newCharacter)
        if newCharacter:isInstanceOf(DataObjects.Character) then
            self.characters[newCharacter:getId()] = newCharacter
        end
    end

    function World:getCharacter(charId)
        return self.characters[charId]
    end

    function World:save(filename)
        file, errorstr = love.filesystem.newFile(filename, "w")
        
        if file then
            file:write(self:getSaveString())
        else
            print(errorstr) 
        end

        file:close()
    end

    function World:getSaveString()
        local saveTable = {}

        for k, character in pairs(self.characters) do
            saveTable[k] = character:getSaveTable()
        end

        return json.encode(saveTable)
    end

    function World.load(filename)
        local saveString = love.filesystem.read(filename)
        local saveJson = json.decode(saveString)
        return World.loadFromJson(saveJson.world, saveJson.text)
    end

    function World.loadFromJson(worldData, text)
        local newWorld = World(text)

        local char, relationship, isAbstract
        for charId, charData in pairs(worldData) do

            char = DataObjects.Character(charId, charData.isAbstract)

            if charData.Attributes then
                for name, value in pairs(charData.Attributes) do
                    char:addAttribute(DataObjects.Attribute(name, value))
                end
            end

            if charData.Relationships then 
                for otherId, relationshipData in pairs(charData.Relationships) do
                    relationship = DataObjects.Relationship(otherId)
                    
                    for name, value in pairs(relationshipData.Modifiers) do
                        relationship:addAttributeModifier(DataObjects.Attribute(name, value))
                    end

                    for _, eventData in pairs(relationshipData.Events) do
                        relationship:addStoryEvent(DataObjects.StoryEvent(eventData))
                    end

                    char:addRelationship(relationship)
                end
            end

            newWorld:addCharacter(char)
        end

        return newWorld
    end

    return World
end