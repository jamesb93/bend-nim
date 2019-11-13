import os, streams, memfiles, parseopt

var inputFile : string

var argCtr : int

#Command line arg: e.g. ./mosh ./whatever.txt
for kind, key, value in getOpt():
    case kind
        of cmdArgument:
            inputFile = key
            break           #only allow one arg

        of cmdLongOption, cmdShortOption:
            discard

        of cmdEnd:
            discard

var fixedSize: uint32 = 36

type wavHeader = object
    chunkID: array[4, char]
    chunkSize: uint32
    format: array[4, char]
    subChunk1ID: array[4, char]
    subChunk1Size: uint32
    audioFormat: uint16
    numChannels: uint16
    sampleRate: uint32
    byteRate: uint32
    blockAlign: uint16
    bitDepth: uint16
    subChunk2ID: array[4, char]
    subChunk2Size: uint32

proc createHeader(binarySize: uint32): wavHeader =
    # Wav header structure
    result.chunkID = ['R', 'I', 'F', 'F']
    result.chunkSize = binarySize + fixedSize
    result.format = ['W','A','V','E']
    result.subChunk1ID = ['f','m','t',' ']
    result.subChunk1Size = 16
    result.audioFormat = 1
    result.numChannels = 1
    result.sampleRate = 44100
    result.byteRate = 44100
    result.blockAlign = 1
    result.bitDepth = 8
    result.subChunk2ID = ['d','a','t','a']
    result.subChunk2Size = binarySize

proc openRawFile(filePath: string) : MemMapFileStream =
    return newMemMapFileStream(filePath, fmRead)

var fileSize = uint32(getFileSize(inputFile))
var data = openRawFile(inputFile)

var header = createHeader(fileSize)

var outputStream : File
discard outputStream.open("toy_output.wav", fmWrite)

for value in header.fields:
    when value is array:
        for arrayVal in value:
            discard outputStream.writeBuffer(unsafeAddr(arrayVal), sizeof(arrayVal))
    else:
        discard outputStream.writeBuffer(unsafeAddr(value), sizeof(value))

var data_array : seq[uint8] = newSeq[uint8](fileSize)

var index = 0
while not data.atEnd():
    data_array[index] = readUint8(data)
    index += 1

discard outputStream.writeBytes(data_array, 0, fileSize)

outputStream.close()