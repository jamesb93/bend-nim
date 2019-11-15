import memfiles
# http://www-mmsp.ece.mcgill.ca/Documents/AudioFormats/WAVE/WAVE.html

const fixedSize : uint32 = 36

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

#a uint24 type
type 
    uint24_range = range[0'u32 .. 0xFFFFFF'u32]
    uint24_obj {.packed.} = object
        bit1 : uint8
        bit2 : uint8
        bit3 : uint8

#https://stackoverflow.com/questions/7416699/how-to-define-24bit-data-type-in-c
proc assignUInt24(obj : var uint24_obj, val : SomeUnsignedInt) =
    #Store as little endian (the way WAV wants it)
    obj.bit3 = uint8(val shr 16 and 0xff)
    obj.bit2 = uint8(val shr 8 and 0xff)
    obj.bit1 = uint8(val and 0xff)

proc asUnsigned32Bit(obj : uint24_obj) : uint32 =
    return (uint32(obj.bit1)) or (uint32(obj.bit2) shl 8) or (uint32(obj.bit3) shl 16)

#[
const
    highestUInt8  : float = float(high(uint8))
    halfHighestUInt8 : float = highestUInt8 * 0.5
    highestUInt16 : float = float(high(uint16))
    halfHighestUInt16 : float = highestUInt16 * 0.5
    highestUInt24 : float = float(high(uint24_range))
    halfHighestUInt24 : float = highestUInt24 * 0.5
    highestUInt32 : float = float(high(uint32))
    halfHighestUInt32 : float = highestUInt32 * 0.5
]#

proc applyDCFilter*(dataDC : pointer, data : pointer, size : Natural, bitDepth : uint16) : void =

    #Use floating point operations for precision (and ease of calcs)
    var 
        y : float     = 0.0
        xPrev : float = 0.0
        yPrev : float = 0.0

    let filterFB : float = 0.98

    #Should be this applied on x (input), or y (output)?
    let scaleAmplitude : float = 0.4

    case bitDepth:
        of 8:
            var dataArr   = cast[ptr UncheckedArray[uint8]](data)
            var dataDCArr = cast[ptr UncheckedArray[uint8]](dataDC)

            for index in 0..size:
                let x : float = float(dataArr[index]) # - halfHighestUInt8
                let y : float = x - xPrev + (filterFB * yPrev)
                xPrev = x
                yPrev = y

                #Scale output result.. these should in theory be scaled to min/max of uint8 range
                let finalOut : float = (y * scaleAmplitude) # + halfHighestUInt8
                
                #Re-write the results over to the dataDC array
                dataDCArr[index] = uint8(finalOut)

        of 16:
            var dataArr   = cast[ptr UncheckedArray[uint16]](data)
            var dataDCArr = cast[ptr UncheckedArray[uint16]](dataDC)

            #account for bigger chunks of memory to read
            let scaledSize = int(size / 2)

            for index in 0..scaledSize:
                let x : float = float(dataArr[index]) #- halfHighestUInt16
                let y : float = x - xPrev + (filterFB * yPrev)
                xPrev = x
                yPrev = y

                #Scale output result.. these should in theory be scaled to min/max of uint16 range
                let finalOut : float = (y * scaleAmplitude) # + halfHighestUInt16
                
                #Re-write the results over to the dataDC array
                dataDCArr[index] = uint16(finalOut)
        
        of 24:
            var dataArr   = cast[ptr UncheckedArray[uint24_obj]](data)
            var dataDCArr = cast[ptr UncheckedArray[uint24_obj]](dataDC)

            #account for bigger chunks of memory to read
            let scaledSize = int(size / 3)

            for index in 0..scaledSize:
                let xUnpacked : float = float(dataArr[index].asUnsigned32Bit)
                let x : float = xUnpacked # - halfHighestUInt24
                let y : float = x - xPrev + (filterFB * yPrev)
                
                xPrev = x
                yPrev = y

                #Scale output result.. these should in theory be scaled to min/max of uint24 range
                let finalOut : float = (y * scaleAmplitude) # + halfHighestUInt24

                var finalOut24bit : uint24_obj
                finalOut24bit.assignUInt24(uint32(finalOut))

                #Re-write the results over to the dataDC array
                dataDCArr[index] = finalOut24bit

        of 32:
            var dataArr   = cast[ptr UncheckedArray[uint32]](data)
            var dataDCArr = cast[ptr UncheckedArray[uint32]](dataDC)
            
            #account for bigger chunks of memory to read
            let scaledSize = int(size / 4)

            for index in 0..scaledSize:
                let x : float = float(dataArr[index]) # - halfHighestUInt32
                let y : float = x - xPrev + (filterFB * yPrev)
                xPrev = x
                yPrev = y

                #Scale output result.. these should in theory be scaled to min/max of uint32 range
                let finalOut : float = (y * scaleAmplitude) # + halfHighestUInt32
                
                #Re-write the results over to the dataDC array
                dataDCArr[index] = uint32(finalOut)
        else:
            discard