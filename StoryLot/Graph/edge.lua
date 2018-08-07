return function(Graph)

	local Edge = class('Edge')

	function Edge:initialize(nodeA, nodeB, data)
		if nodeA:isInstanceOf(Graph.Node) and nodeB:isInstanceOf(Graph.Node) then
			self.nodes = {nodeA, nodeB}

			nodeA:addEdge(self, nodeB)
			nodeB:addEdge(self, nodeA)

			self.data = data
		else
			print("Edge initialization failed. NodeA or NodeB are not of type \"Node\": \n" .. tostring(nodeA) .. "\n" .. tostring(nodeB) .. "\n")
		end
	end

	function Edge:getDeltaState()

	end

	function Edge:getOther(nodeA)
		if self.nodes[1] == nodeA then
			return self.nodes[2]
		else
			return self.nodes[1]
		end
	end

	function Edge:getNodes()
		if self.nodes[1].timeStep < self.nodes[2].timeStep then
			return self.nodes[1], self.nodes[2]
		else
			return self.nodes[2], self.nodes[1]
		end
	end

	function Edge:hasData()
		return self.data ~= nil
	end

	function Edge:setData(newData)
		self.data = newData
	end

	function Edge:addData(newData, overwrite)
		for k, v in pairs(newData) do
			-- if key exists and should be overwritten or the key doesn't exist yet
			-- assign data
			if (self.data[k] and overwrite) or not self.data[k] then
				self.data[k] = v
			end
		end
	end

	return Edge
end