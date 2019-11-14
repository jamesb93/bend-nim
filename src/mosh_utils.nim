import memfiles
# http://www-mmsp.ece.mcgill.ca/Documents/AudioFormats/WAVE/WAVE.html

var fixedSize: uint32 = 36
type wavHeader* = object
    chunkID*: array[4, char]
    chunkSize*: uint32
    format*: array[4, char]
    subChunk1ID*: array[4, char]
    subChunk1Size*: uint32
    audioFormat*: uint16
    numChannels*: uint16
    sampleRate*: uint32
    byteRate*: uint32
    blockAlign*: uint16
    bitDepth*: uint16
    subChunk2ID*: array[4, char]
    subChunk2Size*: uint32

proc createHeader*(
    binarySize: uint32,
    kSampleRate: uint32,
    kBitDepth: uint16,
    kNumChannels: uint16
): wavHeader =
    # Wav header structure
    result.chunkID = ['R','I','F','F']
    result.chunkSize = binarySize + fixedSize
    result.format = ['W','A','V','E']
    result.subChunk1ID = ['f','m','t',' ']
    result.subChunk1Size = 16
    if kBitDepth == 32:
        result.audioFormat = 3
    else:
        result.audioFormat = 1
    result.numChannels = kNumChannels
    result.sampleRate = kSampleRate
    result.byteRate = kSampleRate * kNumChannels * kBitDepth div 8
    result.blockAlign = kNumChannels * kBitDepth div 8
    result.bitDepth = kBitDepth
    result.subChunk2ID = ['d','a','t','a']
    result.subChunk2Size = binarySize

proc openRawFile*(filePath: string) : MemFile =
    return memfiles.open(filePath, fmRead)

proc applyDCFilter*(dataDC : pointer, data : pointer, size : Natural) : void =
    
    #Re-interpret as array of uint8 (raw 1 byte)
    var dataArr   = cast[ptr UncheckedArray[uint8]](data)

    #Re-interpret dataDC as array of uint8 (raw 1 byte)
    var dataDCArr = cast[ptr UncheckedArray[uint8]](dataDC)

    #Use floating point operations for precision (and ease of calcs)
    var 
        y : float     = 0.0
        xPrev : float = 0.0
        yPrev : float = 0.0

    let 
        highestUInt8 : float = float(high(uint8))
        halfHifghestUInt8 : float = highestUInt8 * 0.5

    for index in 0..size:
        #let x : float = (float(dataArr[index]) - halfHifghestUInt8) / halfHifghestUInt8   #-1 to 1
        let x : float = float(dataArr[index]) - halfHifghestUInt8
        let y : float = x - xPrev + (0.98 * yPrev)
        xPrev = x
        yPrev = y

        #Scale output result.. these should in theory be scaled to min/max of uint8 range
        #let finalOut : float = (y * 0.5 * halfHifghestUInt8) + halfHifghestUInt8
        let finalOut : float = (y * 0.5) + halfHifghestUInt8
        
        #Re-write the results over to the dataDC array
        dataDCArr[index] = uint8(finalOut)