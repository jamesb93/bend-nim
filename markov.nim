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
        echo key, pair

        if not markov.hasKey(key):
            markov[key] = pair
        else:
            markov[key].add(pair)
    
    # Create a special key for the final key
    var specialKey = someData[(len(someData)-order)..len(someData)]
    markov[specialKey] = @["_END_"]
    for key, value in markov:
        echo(key, value)
    return markov

proc generateFromChain(sChain:Table, iterations:int, order:int): void =
    # Setup a places to store the results
    var res:seq[int]
    
    # Get a random key from the data, rather than the chain
    let 
        randomPoint:int = rand(0..len(someData))
        randomSlice:seq[int] = someData[randomPoint..randomPoint + (order-1)]
    echo randomPoint
    echo randomPoint+(order-1)
    var previousStates:seq[int] = randomSlice


    # Now loop around for some iterations
    for i in 0..iterations:
         var nextState = sample(
                sChain[previousStates]
            )
        if nextState = 
        
        var nextKey:seq[int] = previousStates[1..previousStates.len()-1]
        nextKey.add(nextState)
        previousStates = nextKey
        
        res.add(nextState)
    echo res 



    # return results

    
    
    
var order = 2
var iters = 3
var chain = buildChain(someData, order)
generateFromChain(chain, iters, order)