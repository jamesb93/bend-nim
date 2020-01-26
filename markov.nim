import tables, random

randomize()
var someData = @[1, 2, 1, 1, 2, 1, 2, 3, 4, 1, 2, 3, 4, 3, 4, 2, 1, 2, 3, 4, 5]

proc buildChain(inputData:seq[int], order:int): Table[seq[int], seq[int]] = 
    
    var markov = initTable[seq[int], seq[int]]()

    # Build the chain
    for i in 0..(len(inputData)-1) - order:
        var mem = inputData[i..i+order]
        var key:seq[int] = mem[0..order-1]
        var pair:seq[int] = @[mem[order]] 

        if not markov.hasKey(key):
            markov[key] = pair
        else:
            markov[key].add(pair)
    
    return markov


proc generateFromChain(sChain:Table, iterations:int, order:int): seq[int] =
    # Setup a places to store the results
    var res:seq[int]
    
    # Get a random key from the data, rather than the chain
    var
        randomPoint:int = rand(0..len(someData)-order-1)
        randomSlice:seq[int] = someData[randomPoint..randomPoint+(order-1)]
        previousStates:seq[int] = randomSlice

    # Now loop around for some iterations
    for i in 0..iterations:
        var sampleSelection:seq[int]

        if sChain.hasKey(previousStates):
            sampleSelection = sChain[previousStates]
        else:
            # New valid point
            randomPoint = rand(0..len(someData)-order-1)
            randomSlice = someData[randomPoint..randomPoint+(order-1)]
            sampleSelection = sChain[randomSlice]
            
        var nextState = sample(sampleSelection)
        
        
        var nextKey:seq[int] = previousStates[1..previousStates.len()-1]
        nextKey.add(nextState)
        previousStates = nextKey
        
        res.add(nextState)
    return res




    # return results

    
    
    
var order = 3
var iters = 30
var chain = buildChain(someData, order)
var resu = generateFromChain(chain, iters, order)
echo resu