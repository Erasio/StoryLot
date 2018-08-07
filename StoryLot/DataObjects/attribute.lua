local Attribute = class('StoryAttribute')

function Attribute:initialize(name, value)
	self.attributeName = name
	self.value = value
end

function Attribute.getWeightedAverage(attributes, targetAttribute, targetWeight)
	local totalValue = 0
	for _, attribute in ipairs(attributes) do
		totalValue = totalValue + attribute:getValue()
	end

	totalValue = totalValue + (targetAttribute:getValue() * targetWeight)

	return Attribute(
		attributes[1].attributeName, 
		totalValue / (#attributes + 1)
	)
end

function Attribute:copy(randRange)
	return Attribute(
		self:getAttributeName(),
		self.value + (math.random() * (randRange * 2) - randRange)
	)
end

function Attribute:getDelta(otherAttribute)
	return Attribute(
		self:getAttributeName(),
		math.abs(self.value - otherAttribute.value)
	)
end

function Attribute:getDeviation(otherAttribute)
	if otherAttribute then
		return self.value + otherAttribute.value
	else
		return self.value
	end
end

--[[function Attribute:__tostring()
	return self:getAttributeName() .. ": " .. self:getValue()
end]]

function Attribute:getAttributeName()
	return self.attributeName
end

function Attribute:getValue()
	return self.value
end

function Attribute:modifyValue(delta)
	self.value = value + delta
	return self.value
end

function Attribute:setValue(newValue)
	self.value = newValue
	return self.value
end

return Attribute