import memfiles

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