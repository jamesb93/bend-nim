import os, streams, parseopt, mosh_utils

var inputFile : string
var argCtr : int

var p = initOptParser("-i -o -c=1 -b=8 -r=44100")

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