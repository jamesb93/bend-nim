import tables, random, os
import wav

proc buildChain(inputData:seq[uint8], order:int): Table[seq[uint8], seq[uint8]] = 
    
    var stateGraph = initTable[seq[uint8], seq[uint8]]()
    echo "Analysing input data"
    var iterationLength = (len(inputData)-1) - order
    for i in 0..iterationLength:
        var mem = inputData[i..i+order]
        var key:seq[uint8] = mem[0..order-1]
        var pair:seq[uint8] = @[mem[order]] 

        if not stateGraph.hasKey(key):
            stateGraph[key] = pair
        else:
            stateGraph[key].add(pair)
    return stateGraph

proc generateFromChain(
    stateGraph:Table, 
    iterations:int, 
    order:int, 
    originalData:seq[uint8], 
): seq[uint8] =
    var res:seq[uint8]
    
    var
        randomPoint:int = rand(0..len(originalData)-order-1)
        randomSlice:seq[uint8] = originalData[randomPoint..randomPoint+(order-1)]
        previousStates:seq[uint8] = randomSlice
    echo "Generating new samples"
    for i in 0..iterations:
        var sampleSelection:seq[uint8]

        if stateGraph.hasKey(previousStates):
            sampleSelection = stateGraph[previousStates]
        else:
            var randomPoint:int = rand(0..len(originalData)-order-1)
            randomSlice = originalData[randomPoint..randomPoint+(order-1)]
            sampleSelection = stateGraph[randomSlice]
            
        var nextState = sample(sampleSelection)
        
        
        var nextKey:seq[uint8] = previousStates[1..previousStates.len()-1]
        nextKey.add(nextState)
        previousStates = nextKey
        
        res.add(nextState)
    return res

proc doMarkov*(
    input:string, 
    output:string, 
    order:int, 
    length:int, 
): void =
    randomize()
    var data = wavToArray(
        expandTilde(input)
    )
    var chain = buildChain(data, order)
    var newStates = generateFromChain(chain, length * 44100, order, data)
    discard arrayToWav(
        expandTilde(output), 
        newStates
    )