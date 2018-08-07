local function doFunction(DataObjects)
	local Relationship = class('StoryRelationship')

	function Relationship:initialize(otherCharacterId, attributeModifiers, storyEvents)
		self.otherCharId = otherCharacterId
		self.attributeModifiers = attributeModifiers or {}
		self.events = storyEvents or {}
	end

	function Relationship.getWeightedAverage(relationships, targetRelationShip, targetWeight)
		local averageRelationship = Relationship(relationships[1]:getOtherCharacterId())

		local tempAttributes = {}

		for _, relationship in ipairs(relationships) do
			-- Collect attribute data for averaging
            for attributeName, attribute in pairs(relationship.attributeModifiers) do
                if not tempAttributes[attributeName] then
                    tempAttributes[attributeName] = {}
                end

                table.insert(tempAttributes[attributeName], attribute)
            end
		end

        for _, attributes in ipairs(tempAttributes) do
            averageRelationship:addAttributeModifier(
                DataObjects.Attribute.getWeightedAverage(attributes)
            )
        end

        return averageRelationship
	end

	function Relationship:copy(randRange)
		local newRelationship = Relationship(
			self.otherCharId,
			nil,
			self.events
		)

		for attributeName, attribute in pairs(self.attributeModifiers) do
			newRelationship:addAttributeModifier(attribute:copy(randRange))
		end

		return newRelationship
	end

	function Relationship:concat(otherRelationship, randRange)
		for attributeName, attribute in pairs(otherRelationship.attributeModifiers) do
			if not self.attributeModifiers[attributeName] then
				self:addAttributeModifier(
					attribute:copy(randRange)
				)
			end
		end
	end

	function Relationship:getDelta(otherRelationship)
		local deltaRelationship = Relationship(
			self.otherCharId,
			nil,
			self.events
		)

		for attributeName, attribute in pairs(self.attributeModifiers) do
			if otherRelationship.attributeModifiers[attributeName] then
				deltaRelationship:addAttributeModifier(
					attribute:getDelta(
						otherRelationship.attributeModifiers[attributeName]
					)
				)
			end
		end

		return deltaRelationship
	end

	function Relationship:getDeviation(otherRelationship)
		local deviation = 0
		for attributeName, attribute in pairs(self.attributeModifiers) do
			if otherRelationship then
				deviation = deviation + attribute:getDeviation(
					otherRelationship.attributeModifiers[attributeName]
				)
			else
				deviation = deviation + attribute:getDeviation()
			end
		end

		return deviation
	end

	--[[function Relationship:__tostring()
		local str = "Other Character: " .. self:getOtherCharacterId() .. "\nAttributes: "
		for k, attribute in pairs(self.attributeModifiers) do
			str = str .. "\n  " .. string.gsub(tostring(attribute), "\n", "\n  ")
		end
		str = str .. "\nEvents:"
		for k, event in pairs(self.events) do
			str = str .. "\n  " .. string.gsub(tostring(event), "\n", "\n  ")
		end
		return str
	end]]

	function Relationship:getOtherCharacterId()
		return self.otherCharId
	end

	function Relationship:addAttributeModifier(newAttribute)
		if newAttribute:isInstanceOf(DataObjects.Attribute) then
			self.attributeModifiers[newAttribute:getAttributeName()] = newAttribute
			return self.attributeModifiers[newAttribute:getAttributeName()]
		end
	end

	function Relationship:getAttributeModifier(attributeName)
		return self.attributeModifiers[attributeName]:getValue() or 0
	end

	function Relationship:modifyAttributeModifier(attributeName, delta)
		local attribute = self:getAttributeModifier(attributeName)
		if attribute then
			return attribute:modifyValue(delta)
		else
			self:addAttributeModifier(DataObjects.Attribute(attributeName, delta))
			return self:getAttributeModifier(attributeName)
		end
	end

	function Relationship:setAttributeModifier(attributeName, newValue)
		return self.attributeModifiers[attributeName]:setValue(newValue)
	end

	function Relationship:addStoryEvent(newEvent)
		if newEvent.isInstanceOf(DataObjects.StoryEvent) then
			table.insert(self.events, newEvent)
		end
	end

	function Relationship:getSaveTable()
		local saveTable = {}
		
		saveTable.Modifiers = {}
		for name, attribute in pairs(self.attributeModifiers) do 
			saveTable.Modifiers[name] = attribute:getValue()
		end

		saveTable.Events = {}
		for k, event in ipairs(self.events) do
			saveTable.Events[k] = event:getSaveTable()
		end

		return saveTable
	end

	return Relationship
end

return doFunction