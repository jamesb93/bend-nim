import os, strutils, streams, memfiles

let inputFile= "/Users/james/dev/scrape/bent.wav"

proc openRawFile(filePath: string): FileStream =
    return newFileStream(filePath, mode=fmRead)

let fileSize = getFileSize(inputFile)
var data = openRawFile(inputFile)

# http://soundfile.sapp.org/doc/WaveFormat/
# RIFF chunk descriptor
data.setPosition(0)
var chunkID = readStr(data, 4)
var chunkSize = readUint32(data)
var format = readStr(data, 4)

# fmt sub-chunk
var subChunk1ID = readStr(data, 4)
var subChunk1Size = readUint32(data)
var audioFormat = readUint16(data)
var numChannels = readUint16(data)
var sampleRate = readUint32(data)
var byteRate = readUint32(data)
var blockAlign = readUint16(data)
var bitDepth = readUint16(data)
var subChunk2ID = readStr(data, 4)
var subChunk2Size = readUint32(data)

echo chunkSize
echo subChunk1Size
echo subChunk2Size
