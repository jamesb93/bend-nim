import os, streams

when declared(commandLineParams):
    var cliArgs = commandLineParams()

var iFile = cliArgs[0]

proc openRawFile(filePath: string): FileStream =
    return newFileStream(filePath, mode=fmRead)

var data = openRawFile(iFile)

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

echo "chunkID: ", chunkID
echo "chunkSize: ", chunkSize
echo "format: ", format
echo "subChunk1ID: ", subChunk1ID
echo "subChunk1Size: ", subChunk1Size
echo "audioFormat: ", audioFormat
echo "numChannels: ", numChannels
echo "sampleRate: ", sampleRate
echo "byteRate: ", byteRate
echo "blockAlign: ", blockAlign
echo "bitDepth: ", bitDepth
echo "subChunk2ID: ", subChunk2ID
echo "subChunk2Size: ", subChunk2size
