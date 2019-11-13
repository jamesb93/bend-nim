import memfiles, parseopt

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

proc openRawFile(filePath: string) : MemFile =
    return memfiles.open(filePath, fmRead)

let 
    data = openRawFile(inputFile)
    dataMem = data.mem
    dataSize = data.size

    header = createHeader(uint32(dataSize))

var outputFile : File
discard outputFile.open("toy_output.wav", fmWrite)

#Write header
for value in header.fields:
    when value is array:
        for arrayVal in value:
            discard outputFile.writeBuffer(unsafeAddr(arrayVal), sizeof(arrayVal))
    else:
        discard outputFile.writeBuffer(unsafeAddr(value), sizeof(value))

#Write actual content
discard outputFile.writeBuffer(dataMem, (sizeof(uint8) * dataSize))

outputFile.close()