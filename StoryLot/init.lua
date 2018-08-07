local folderOfThisFile = (...)
local StoryLot = {}

class = require(folderOfThisFile .. ".middleclass")

StoryLot.Graph = require(folderOfThisFile .. ".Graph")
StoryLot.DataObjects = require(folderOfThisFile .. ".DataObjects")

local Node = StoryLot.Graph.Node
local Edge = StoryLot.Graph.Edge
local World = StoryLot.DataObjects.World

--[[ 
config
    initialStates:          List    World Data Objects
    keySteps:                   List    Time-Steps
        timeStep:               List    KeyStates
    conclustionSteps:           List    Concluding States
    minorStoryEvents:           List    StoryEdges
    numTransitionSteps:         Number  Amount of transition time steps between key states
    numKeyStatesPerStep:        Number  Amount of key states per key step
    numTransitionStatesPerStep: Number  Amount of transition states per transition step. Has to be equal or larger than the amount of key states per key step
    numConclusionStatesPerStep: Number  Amount of conclusion states per conclusion step
    numAverageEdgesPerNode:     Number  Amount of edges per node on average. Integer numbers will not result in any deviation. Non integers will be randomized to floor and ceil values distributed according to the value of the decimal.
    transitionStateDeviation:   Number  The allowed deviation from the desired transition state
    numEdgesPerCharacter:       Number  The amount of story events that any character is able to participate in per edge
]]

function StoryLot.generate(config)
    config.numTransitionSteps = config.numTransitionSteps or 3
    config.numKeyStatesPerStep = config.numKeyStatesPerStep or 2
    config.numTransitionNodesPerStep = config.numTransitionNodesPerStep or 3
    config.numConclusionStatesPerStep = config.numConclusionStatesPerStep or 1
    config.numAverageEdgesPerNode = config.numAverageExtraEdgesPerNode or 0.5
    config.transitionStateDeviation = config.transitionStateDeviation or 0.5
    config.numEdgesPerCharacter = config.numEdgesPerCharacter or 2

    -- Create time steps and insert initial state as root node. 
    local graph = StoryLot.generateGraph(
        config.initialStates,     -- List of Hooks
        config.keySteps, 
        config.numTransitionSteps
    )

    StoryLot.createKeyNodes(
        graph, 
        config.keySteps, 
        config.numKeyStatesPerStep
    )

    StoryLot.createConclusionNodes(
        graph, 
        config.conclustionSteps, 
        numConclusionStatesPerStep
    )

    StoryLot.createTransitionNodes(
        graph,
        #config.keySteps,
        config.numTransitionSteps,
        config.numTransitionNodesPerStep
    )

    StoryLot.createEdges(
        graph,
        config.numAverageEdgesPerNode
    )

    StoryLot.createTransitionStates(
        graph,
        #config.keySteps,
        config.numTransitionSteps
    )

    StoryLot.enrichEdges(
        graph,
        config.minorStoryEvents,
        config.transitionStateDeviation,
        config.numEdgesPerCharacter
    )

    return graph
end


function StoryLot.generateGraph(hooks, keySteps, numTransitionSteps)
    return StoryLot.Graph{
        numKeySteps = #keySteps + 1,    -- Key Steps + Conclusion Step
        numTransitionSteps = numTransitionSteps,    -- The amount of transition time steps between key timeSteps
        root = Node(hooks[math.random(1, #hooks)])  -- The initial state, selected from a list of possible initial states.
    }
end

function StoryLot.createKeyNodes(graph, keySteps, numKeyStatesPerStep)
    -- Select all key steps
    local i = 0
    for timeStepIndex, timeStep in ipairs(graph.timeSteps) do
        if timeStep.timeStepType == "KeyState" then
            i = i + 1
            if numKeyStatesPerStep > #keySteps[i] then
                for _ = 1, numKeyStatesPerStep do
                    -- ToDo: Should take previously added states into consideration. To not serve duplicate key states.
                    local tempNode = Node(keySteps[i][math.random(1, #keySteps[i])])
                    tempNode.timeStep = timeStepIndex
                    table.insert(timeStep, tempNode)
                end
            else
                for _, keyState in pairs(keySteps[i]) do
                    local tempNode = Node(keyState)
                    tempNode.timeStep = timeStepIndex
                    table.insert(timeStep, tempNode)
                end
            end
        end 
    end
end

function StoryLot.createConclusionNodes(graph, conclusionStates, numConclusionStatesPerStep)
    numConclusionStatesPerStep = numConclusionStatesPerStep or 1

    local tempNode = Node(conclusionStates[math.random(1, #conclusionStates)])
    tempNode.timeStep = #graph.timeSteps
    table.insert(graph.timeSteps[#graph.timeSteps], tempNode)
end

function StoryLot.createTransitionNodes(graph, numKeySteps, numTransitionSteps, numTransitionNodesPerStep)
    local transitionStep, targetStep, tempNode

    for i, timeStep in ipairs(graph.timeSteps) do
        if timeStep.timeStepType == "TransitionState" then
            for j = 1, numTransitionNodesPerStep do
                local tempNode = Node()
                tempNode.timeStep = i
                table.insert(timeStep, tempNode)
            end
        end
    end
end

function StoryLot.createEdges(graph, numAverageEdgesPerNode)
    local currentStep, nextStep

    currentStep = graph.timeSteps[1]

    -- Look at next time step and create all essential edges, so every node can be reached.
    for i = 1, #graph.timeSteps - 1 do
        nextStep = graph.timeSteps[i + 1]

        -- Create a connection between all nodes of the current step and the nodes of the next step.
        for j = 1, #currentStep do
            Edge(currentStep[j], nextStep[(j % #nextStep) + 1])
        end

        -- Create a connection between nodes of the next step, and nodes of the current step, if it does not yet exist.
        -- To guarantee every node can be reached, if the next step contains more nodes than the current step. 
        for j = 1, #nextStep do
            if next(nextStep[j].edges) == nil then
                Edge(nextStep[j], currentStep[math.random(#currentStep)])
            end
        end
        
        -- Introduce more branching, through adding additional edges
        for j = 1, #currentStep do
            if #currentStep[j].edges <= math.floor(numAverageEdgesPerNode) then
                local edgesToAdd

                -- Default assignement, more nodes than necessary available
                if #nextStep > math.ceil(numAverageEdgesPerNode) then 
                    -- Use decimal part as probability for creating one additional edge
                    if math.random() <= numAverageEdgesPerNode % 1 then
                        edgesToAdd = math.ceil(numAverageEdgesPerNode)
                    else
                        edgesToAdd = math.floor(numAverageEdgesPerNode)
                    end

                -- Limited assignment. The next step doesn't have enough nodes.
                -- So the connections need to be more limited in order to still retain meaningful paths.
                elseif #nextStep >= math.floor(numAverageEdgesPerNode) then
                    edgesToAdd = math.floor(numAverageEdgesPerNode)

                -- There's very few nodes. Strongly consider, whether more edges are necessary
                else
                    edgesToAdd = 0
                end

                -- Build list of unconnected nodes
                local unconnectedNodes = {}
                for k, v in pairs(nextStep) do
                    if type(v) == "table" then 
                        if not currentStep[j].edges[v] then
                            table.insert(unconnectedNodes, v)
                        end
                    end
                end

                -- Guarantee no duplicate edges
                -- ToDo: Is the guarantee of non duplicates even desirable?
                if #unconnectedNodes == 0 then
                    edgesToAdd = 0
                elseif #unconnectedNodes < edgesToAdd then
                    edgesToAdd = #unconnectedNodes
                end

                local randomIndex
                for k = 1, edgesToAdd do
                    randomIndex = math.random(#unconnectedNodes)
                    Edge(currentStep[j], unconnectedNodes[randomIndex])
                    table.remove(unconnectedNodes, randomIndex)
                end
            end
        end

        

        currentStep = nextStep
    end
end

function StoryLot.createTransitionStates(graph, numKeySteps, numTransitionSteps)
    -- Iterate over the space between all key steps + conclusion
    for i = 1, numKeySteps + 1 do
        -- The previous keyState, considered the "current" state.
        local originStep = graph.timeSteps[(i - 1) * (numTransitionSteps + 1) + 1]
        local targetKeyStep = graph.timeSteps[(i) * (numTransitionSteps + 1) + 1]
        if targetKeyStep then
            for _, keyNode in ipairs(targetKeyStep) do

                keyNode.data:concat(
                    originStep[math.random(#originStep)].data
                )
            end
        end
        -- Fill transition steps between key states backwards
        for j = 0, numTransitionSteps - 1 do
            transitionStep = graph.timeSteps[i * (numTransitionSteps + 1) - j]

            for _, node in ipairs(transitionStep) do
                local targetStates = {} -- The states to collect data from
                for __, edge in pairs(node.edges) do
                    -- If the edge points to a node in the following time step
                    if node.timeStep < edge:getOther(node).timeStep then
                        -- Push world to the target states
                        table.insert(targetStates, edge:getOther(node).data)
                    end
                end
                
                

                node.data = World.getWeightedAverage(
                    targetStates, 
                    originStep[math.random(#originStep)].data, 
                    -- Reduce the influence of the originState, depending on how many steps are in between.
                    1 / (node.timeStep - originStep.timeStep)
                )
            end
        end
    end
end

function StoryLot.enrichEdges(graph, minorStoryEvents, transitionStateDeviation, numEdgesPerCharacter)
    
    local function shuffle(tbl) -- suffles numeric indices
        local len, random = #tbl, math.random ;
        for i = len, 2, -1 do
            local j = random( 1, i );
            tbl[i], tbl[j] = tbl[j], tbl[i];
        end
        return tbl;
    end

    
    for i, timeStep in ipairs(graph.timeSteps) do
        for j, node in ipairs(timeStep) do
            for ___, edge in pairs(node.edges) do
                -- Don't modify edge data, if it was hard coded by the author
                -- Or if it has previously been assigned by the algorithm
                if not edge:hasData() then
                    edge.data = {storyEvents = {}}

                    local nodeA, nodeB = edge:getNodes() -- Get the nodes connected by this edge, ascending order by timestep they belong to.


                    -- Analyze difference between states
                    local deltaWorld = nodeA.data:getDelta(nodeB.data)

                    -- Change order of available events to mix up which events get selected
                    --shuffle(minorStoryEvents) -- Unnecessary in the current setup
                    local selectedEvents = {}
                    for charId, char in pairs(deltaWorld.characters) do
                        for _, event in ipairs(minorStoryEvents) do
                            for otherCharId, otherChar in pairs(event.deltaState.characters) do
                                if otherChar.isAbstract or charId == otherCharId then 
                                    -- Check if event would nudge delta state closer to 0. 
                                    if selectedEvents[numEdgesPerCharacter] then
                                        local deviation = deltaWorld:getDeviation(event)
                                        local insertIndex = -1
                                        for i = #selectedEvents, 1, -1 do
                                            if deviation < selectedEvents[i].deviation then
                                                insertIndex = i
                                            else 
                                                break
                                            end
                                        end
                                        if insertIndex > 0 then
                                            table.insert(
                                                selectedEvents, 
                                                i, 
                                                {
                                                    deviation = deviation,
                                                    event = event,
                                                }
                                            )
                                            table.remove(selectedEvents, #selectedEvents)
                                        end
                                    else
                                        table.insert(
                                            selectedEvents, 
                                            {
                                                deviation = deltaWorld:getDeviation(event),
                                                event = event
                                            }
                                        )
                                    end
                                end
                            end
                        end

                        for _, struct in ipairs(selectedEvents) do
                            print(nodeA.timeStep, nodeB.timeStep, struct.event:getString(char), struct.deviation)
                            table.insert(edge.data.storyEvents, {event=struct.event, char=char})
                        end
                    end
                end
            end
        end
    end
end

function StoryLot.drawGraph(graph)
    local tempNode
    for i, timeStep in ipairs(graph.timeSteps) do
        if timeStep.timeStepType == "InitialState" or timeStep.timeStepType == "ConclusionState" then
            love.graphics.setColor(0, 0, 1, 0.4)
        elseif timeStep.timeStepType == "KeyState" then
            love.graphics.setColor(0, 1, 0, 0.4)
        elseif timeStep.timeStepType == "TransitionState" then
            love.graphics.setColor(1, 1, 1, 0.4)
        end
        for j, node in ipairs(timeStep) do
            node.i = i
            node.j = j
            love.graphics.circle("fill", i * 60, j * 40 + 10, 10)
            for k, edge in pairs(node.edges) do
                tempNode = edge:getOther(node)
                if tempNode.i then
                    local r, g, b, a = love.graphics.getColor()
                    love.graphics.setColor(1, 1, 1, 0.2)
                    love.graphics.line(i * 60, j * 40 + 10, tempNode.i * 60, tempNode.j * 40 + 10)
                    love.graphics.setColor(r, g, b, a)
                end
            end
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return StoryLot