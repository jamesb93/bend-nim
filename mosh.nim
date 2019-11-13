import os, streams, parseopt, mosh_utils

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