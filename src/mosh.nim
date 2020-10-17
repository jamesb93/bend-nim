import convert, markov

proc convert(
    input:string,
    output:string,
    bitDepth:uint16=8,
    numChans:uint16=1,
    sampRate:uint32=44100,
    limit:float=5000,
    maxSize:float=4096,
    dcFilter:bool=true
): void= doConvert(input,output,bitDepth,numChans,sampRate,limit,maxSize,dcFilter)

proc markov(
    input:string,
    output:string,
    order:int=4,
    length:int=10
): void= doMarkov(input,output,order,length)

when isMainModule:
    import cligen
    dispatchMulti(
        [convert, 
        help={
            "input" : "An input to process. This can be a folder or file containing data.",
            "output" : "An output to render to. This can be a folder of, or single wav.",
            "bitDepth" : "The bit depth to render to.",
            "numChans" : "The number of channels to write to.",
            "sampRate" : "The sample rate of the output file(s).",
            "limit" : "The amount of data to scrape if working with directories.",
            "maxSize" : "The maximum size of any single file in directory mode.",
            "dcFilter" : "If true, apply a DC Filter. Conversion often produces lots of DC."
        }],
        [markov, help={
            "input" : "A input file to process. Should be audio full of 8 bit unsigned integers.",
            "output" : "An output file to render to",
            "order" : "The order of analysis for the markov chain.",
            "length" : "How many samples to generate. This number is multiplied by 44100."
        }]
    )