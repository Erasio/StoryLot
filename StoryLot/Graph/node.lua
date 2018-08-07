return function(Graph)

	local Node = class('Node')

	function Node:initialize(data)
		self.data = data or {}

		self.edges = {}
		self.numEdges = 0
	end

	function Node:addEdge(newEdge, otherNode)
		self.numEdges = self.numEdges + 1
		self.edges[otherNode] = newEdge
	end

	function Node:removeEdge(removedEdge)
		self.numEdges = self.numEdges - 1
		for k, edge in pairs(self.edges) do
			if edge == removedEdge then
				table.remove(self.edges, k)
				break
			end
		end
	end

	function Node:removeEdgeByNode(otherNode)
		self.edges[otherNode] = nil
	end

	return Node
end