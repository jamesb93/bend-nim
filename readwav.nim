import os, strutils, streams, memfiles

const fixedSize : uint32 = 36

type WavFile* = object
    # A type for a wave file that holds information and a pointer to some data
    data*: pointer
    size*: BiggestInt
    sr*: uint32
    depth*: uint16
    channels*: uint16

# http://soundfile.sapp.org/doc/WaveFormat/
# RIFF chunk descriptor

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

proc arrayToWav*(outputFilePath:string, someData:seq[uint8]): bool =
    var header: wavHeader = createHeader(
        uint32(somedata.len()),
        uint32(44100),
        uint16(8),
        uint16(1)
    )
    var outputFile : File
    if not outputFile.open(outPutFilePath, fmWrite):
        echo ("ERROR: Could not create", outputFilePath)
        return
    
    #-- Write Header Information --#
    for value in header.fields:
        when value is array:
            for arrayVal in value:
                discard outputFile.writeBuffer(unsafeAddr(arrayVal), sizeof(arrayVal))
        else:
            discard outputFile.writeBuffer(unsafeAddr(value), sizeof(value))
    
    # -- Write Data -- #
    for sample in someData:
        discard outputFile.writeBuffer(unsafeAddr(sample), sizeof(sample))
    
    outputFile.close()
    
    return true

        
proc wavToArray*(filePath: string): seq[uint8]= 
    var container: seq[uint8]
    var data = newFileStream(filePath, mode=fmRead)
    data.setPosition(0)
    var chunkID = readStr(data, 4)
    var chunkSize = readUint32(data)
    var format = readStr(data, 4)

    # fmt sub-chunk
    var subChunk1ID = readStr(data, 4)
    while subChunk1ID != "fmt ":
        subChunk1ID = readStr(data, 4)
    assert subChunk1ID == "fmt "
    # var subChunk1ID = readStr(data, 4)
    var subChunk1Size = readUint32(data)
    var audioFormat = readUint16(data)
    var numChannels = readUint16(data)
    var sampleRate = readUint32(data)
    var byteRate = readUint32(data)
    var blockAlign = readUint16(data)
    var bitDepth = readUint16(data)
    var subChunk2ID = readStr(data, 4)
    while subChunk2ID != "data":
        subChunk2ID = readStr(data, 4)
    assert subChunk2ID == "data"
    var subChunk2Size = readUint32(data)

    while not data.atEnd():
        container.add(
            readUint8(data)
        )
    return container



