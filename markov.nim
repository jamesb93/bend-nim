import tables, random
import readwav
# Read a Wav file into an array or seq

var someData = wavToArray("C:\\Users\\james\\dev\\nimBend\\short_test.wav")

# pass that to the two markov functions
# pass the seq of new data to the wav writer

#################################################################


randomize()

proc buildChain(inputData:seq[uint8], order:int): Table[seq[uint8], seq[uint8]] = 
    
    var markov = initTable[seq[uint8], seq[uint8]]()

    # Build the chain
    for i in 0..(len(inputData)-1) - order:
        var mem = inputData[i..i+order]
        var key:seq[uint8] = mem[0..order-1]
        var pair:seq[uint8] = @[mem[order]] 

        if not markov.hasKey(key):
            markov[key] = pair
        else:
            markov[key].add(pair)
    
    return markov


proc generateFromChain(sChain:Table, iterations:int, order:int): seq[uint8] =
    # Setup a places to store the results
    var res:seq[uint8]
    
    # Get a random key from the data, rather than the chain
    var
        randomPoint:int = rand(0..len(someData)-order-1)
        randomSlice:seq[uint8] = someData[randomPoint..randomPoint+(order-1)]
        previousStates:seq[uint8] = randomSlice

    # Now loop around for some iterations
    for i in 0..iterations:
        var sampleSelection:seq[uint8]

        if sChain.hasKey(previousStates):
            sampleSelection = sChain[previousStates]
        else:
            # New valid point
            randomPoint = rand(0..len(someData)-order-1)
            randomSlice = someData[randomPoint..randomPoint+(order-1)]
            sampleSelection = sChain[randomSlice]
            
        var nextState = sample(sampleSelection)
        
        
        var nextKey:seq[uint8] = previousStates[1..previousStates.len()-1]
        nextKey.add(nextState)
        previousStates = nextKey
        
        res.add(nextState)
    return res

    
    
var order = 8
var iters = 20 * 44100
var chain = buildChain(someData, order)
var resu = generateFromChain(chain, iters, order)
var result = arrayToWav("C:/Users/james/dev/nimBend/outputTest.wav", resu)