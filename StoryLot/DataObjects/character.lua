local function doFunction(DataObjects)
    local Character = class('StoryCharacter')

    function Character:initialize(id, isAbstract)
        self.attributes = {}
        self.relationships = {}
        
        self.isAbstract = isAbstract or false
        self.id = id or self:generateId()
    end

    function Character.getWeightedAverage(characters, targetChar, targetWeight)
        local averageChar = Character(characters[1]:getId())

        local tempAttributes = {}
        local tempRelationships = {}

        for _, character in ipairs(characters) do
            -- Collect attribute data for averaging
            for attributeName, attribute in pairs(character.attributes) do
                if not tempAttributes[attributeName] then
                    tempAttributes[attributeName] = {}
                end
                table.insert(tempAttributes[attributeName], attribute)
            end
           
            -- Collect relationship data for averaging
            for otherCharId, relationship in pairs(character.relationships) do
                if not tempRelationships[otherCharId] then
                    tempRelationships[otherCharId] = {}
                end

                table.insert(tempRelationships[otherCharId], relationship)
            end
        end

        for attributeName, attributes in pairs(tempAttributes) do
            averageChar:addAttribute(
                DataObjects.Attribute.getWeightedAverage(
                    attributes, 
                    targetChar.attributes[attributeName], 
                    targetWeight
                )
            )
        end

        for otherCharId, relationships in pairs(tempRelationships) do
            averageChar:addRelationship(
                DataObjects.Relationship.getWeightedAverage(
                    relationships, 
                    targetChar.relationships[otherCharId],
                    targetWeight
                )
            )
        end

        return averageChar
    end

    function Character:concat(otherChar, randRange)
        for attributeName, attribute in pairs(otherChar.attributes) do
            if not self.attributes[attributeName] then
                self:addAttribute(attribute:copy(randRange))
            end
        end

        for otherCharId, relationship in pairs(otherChar.relationships) do
            if self.relationships[otherCharId] then
                self.relationships[otherCharId]:concat(relationship, randRange)
            else
                self:addRelationship(
                    relationship:copy(randRange)
                )
            end
        end
    end

    -- randRange:   Number  The range that attributes may be randomized in.
    function Character:copy(randRange)
        local newChar = Character(self:getId())

        for attributeName, attribute in pairs(self.attributes) do
            newChar:addAttribute(
                attribute:copy(randRange)
            )
        end

        for otherCharId, relationship in pairs(self.relationships) do
            newChar:addRelationship(
                relationship:copy(randRange)
            )
        end

        return newChar
    end

    function Character:getDelta(otherDeltaChar)
        local deltaChar = Character(self:getId())
        for attributeName, attribute in pairs(self.attributes) do
            if otherDeltaChar.attributes[attributeName] then
                deltaChar:addAttribute(
                    attribute:getDelta(
                        otherDeltaChar.attributes[attributeName]
                    )
                )
            end
        end

        for otherCharId, relationship in pairs(self.relationships) do
            if otherDeltaChar.relationships[otherCharId] then
                deltaChar:addRelationship(
                    relationship:getDelta(
                        otherDeltaChar.relationships[otherCharId]
                    )
                )
            end
        end

        return deltaChar
    end

    function Character:getDeviation(otherChar)
        local deviation = 0

        for attributeName, attribute in pairs(self.attributes) do
            if otherChar then
                deviation = deviation + attribute:getDeviation(otherChar.attributes[attributeName])
            else
                deviation = deviation + attribute:getDeviation()
            end
        end

        for relationshipCharId, relationship in pairs(self.relationships) do
            if otherChar then
                deviation = deviation + relationship:getDeviation(otherChar.relationships[relationshipCharId])
            else
                deviation = deviation + relationship:getDeviation()
            end
        end

        return deviation
    end

    --[[function Character:__tostring()
        local str = "CharacterId: " .. self:getId() .. "\nAttributes: "
        for k, attribute in pairs(self.attributes) do
            str = str .. "\n  " .. string.gsub(tostring(attribute), "\n", "\n    ")
        end
        str = str .. "\nRelationships: "
        for k, relationship in pairs(self.relationships) do
            str = str .. "\n  " .. string.gsub(tostring(relationship), "\n", "\n    ")
        end
        return str
    end]]

    function Character:addAttribute(newAttribute)
        if newAttribute:isInstanceOf(DataObjects.Attribute) then
            self.attributes[newAttribute:getAttributeName()] = newAttribute
        end
    end

    function Character:getAttribute(attributeName)
        return self.attributes[attributeName]
    end

    function Character:modifyAttributeValue(attributeName, delta)
        local attribute = self:getAttributeModifier(attributeName)
        if attribute then
            return attribute:modifyValue(delta)
        else
            self:addAttributeModifier(DataObjects.Attribute(attributeName, delta))
            return self:getAttributeModifier(attributeName)
        end
    end

    function Character:addRelationship(newRelationship)
        if newRelationship:isInstanceOf(DataObjects.Relationship) then
            self.relationships[newRelationship:getOtherCharacterId()] = newRelationship
        end
    end

    function Character:getRelationship(otherCharacterId)
        return self.relationships[otherCharacterId]
    end

    function Character:getId()
        return self.id
    end

    function Character:generateId()
        local template ='xxxxxxxx4xxx'
        return string.gsub(template, '[xy]', 
            function (c)
                local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
                return string.format('%x', v)
            end
        )
    end

    function Character:getSaveTable()
        local saveTable = {}

        saveTable.isAbstract = self.isAbstract
        
        saveTable.Attributes = {}
        for name, attribute in pairs(self.attributes) do
            saveTable.Attributes[name] = attribute:getValue()
        end

        saveTable.Relationships = {}
        for otherId, relationship in pairs(self.relationships) do
            saveTable.Relationships[otherId] = relationship:getSaveTable()
        end

        return saveTable
    end

    return Character
end

return doFunction