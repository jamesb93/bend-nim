import memfiles, parseopt

var inputFile : string
var argCtr : int

#Command line arg: e.g. ./mosh ./whatever.txt
for kind, key, value in getOpt():
    case kind
        of cmdArgument:
            inputFile = key
            break           #only allow one arg

var fileSize = uint32(getFileSize(inputFile))
var data = openRawFile(inputFile)
        of cmdLongOption, cmdShortOption:
            discard

var header = createHeader(fileSize)
        of cmdEnd:
            discard

var outputStream : File
discard outputStream.open("toy_output.wav", fmWrite)

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
