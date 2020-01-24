import tables, random

randomize()
var someData = @[1, 2, 1, 1, 2, 1, 2, 3, 4, 1, 2, 3, 4, 3, 4, 2, 1, 2, 3, 4, 5]

proc buildChain(inputData:seq[int], order:int): Table[seq[int], seq[int]] = 
    
    var markov = initTable[seq[int], seq[int]]()

    # Build the chain
    for i in 0..(inputData.len()-1) - order:
        var mem = inputData[i..i+order]
        var key:seq[int] = mem[0..order-1]
        var pair:seq[int] = @[mem[order]]  

        if not markov.hasKey(key):
            markov[key] = pair
        else:
            markov[key].add(pair)
    return markov

proc generateFromChain(sChain:Table, iterations:int, order:int): void =
    # Setup a places to store the results
    var res:seq[int]
    
    # Get a random key from the data, rather than the chain
    let 
        randomPoint:int = sample(someData)
        randomSlice:seq[int] = someData[randomPoint..randomPoint + (order-1)]
    var 
        possibleStates:seq[int] = sChain[randomSlice]
        previousStates:seq[int] = randomSlice


    # Now loop around for some iterations
    for i in 0..iterations:
        var nextState = sample(possibleStates)
        
        #everything 1 from the left + nextState
        var shift = previousStates[1..previousStates.len()]
        echo shift
        shift.insert(nextState, shift.len())
        echo shift
        var possibleStates = shift
        
        
        res.add(nextState)
        if i == 1: quit()
    echo res 



    # return results

    
    
    
var order = 4
var iters = 100
var chain = buildChain(someData, order)
generateFromChain(chain, iters, order)