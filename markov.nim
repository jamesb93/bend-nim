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

proc generateFromChain(sChain:Table, iterations:int, order:int): seq[int] =
    # Setup a places to store the results
    var results = seq[int]
    
    # Get a random key from the data, rather than the chain
    var randomPoint = rand(len(someData)-1)
    var randomSlice = someData[randomPoint..randomPoint + (order-1)]
    var possibleStates = 

    # Now loop around for some iterations
    for i 0..iterations:
        var possibleStates = 



    return results

    
    
    
var order = 2
var iters = 100
var chain = buildChain(someData, order)
discard generateFromChain(chain, iters, order)