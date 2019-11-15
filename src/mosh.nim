import memfiles, mosh_utils, os, system, strutils, argparse

#-- CLI Args --#
when declared(commandLineParams):
    var cliArgs = commandLineParams()

# Parse Arguments
var p = newParser("mosh"):
    help("mosh can turn any input file into audio files in the wav format.")
    option("-b", "--depth", choices = @["8","16","24","32"], default="8", help="Bit-depth of the output file.")
    option("-c", "--channels", default="1", help="Number of channels in the output file.")
    option("-r", "--rate", default="44100", help="The sampling rate of the output file.")
    arg("input")
    arg("output")

var opts = p.parse(cliArgs)
# Check to make sure user has passed input/output files
if opts.input == "":
    echo "You need to provide an input file."
    quit()
if opts.output == "":
    echo "You need to provide an output file."
    quit()

var sampRate: uint32 = uint32(parseUInt(opts.rate))
var bitDepth: uint16 = uint16(parseUInt(opts.depth))
var numChans: uint16 = uint16(parseUInt(opts.channels))
var iFile: string = opts.input
var oFile: string = opts.output
if not fileExists(iFile):
    echo "The input file does not exist."
    quit()

#-- Process input file > output file --#
let 
    data = openRawFile(iFile)
    dataMem = data.mem
    dataSize = data.size
    
    dataDC = alloc(dataSize) #raw bytes
    
    header = createHeader(
        uint32(dataSize),
        sampRate,
        bitDepth,
        numChans
        )

var outputFile : File
discard outputFile.open(oFile, fmWrite)

#-- Apply DC filter on data --#
#This DC filter doesn't (yet) work for >1 channels!!!
dataDC.applyDCFilter(dataMem, dataSize, bitDepth)

#-- Write header --#
for value in header.fields:
    when value is array:
        for arrayVal in value:
            discard outputFile.writeBuffer(unsafeAddr(arrayVal), sizeof(arrayVal))
    else:
        discard outputFile.writeBuffer(unsafeAddr(value), sizeof(value))

#-- Write input data --#
discard outputFile.writeBuffer(dataDC, dataSize)

#Close file
outputFile.close()

#Free data
dataDC.dealloc