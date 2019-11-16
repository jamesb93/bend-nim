import os, system, strutils, argparse, threadpool
import moshutils

#-- CLI Args --#
when declared(commandLineParams):
    var cliArgs = commandLineParams()
    if len(cliArgs) < 2:
        echo "Please provide a minimum of two parameters."
        quit()

# Parse Arguments
var p = newParser("mosh"):
    help("mosh can turn any input file into audio files in the wav format.")
    option("-b", "--depth", choices = @["8","16","24","32"], default="8", help="Bit-depth of the output file.")
    option("-c", "--channels", default="1", help="Number of channels in the output file.")
    option("-r", "--rate", default="44100", help="The sampleing rate of the output file.")
    flag("-dc", "--highpass", help="Apply a highpass filter to remove DC from the output.")
    flag("-v", "--verbose", help="When enabled, allows for verbose output.")
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

# Now assign the CLI args
var sampRate: uint32 = uint32(parseUInt(opts.rate))
var bitDepth: uint16 = uint16(parseUInt(opts.depth))
var numChans: uint16 = uint16(parseUInt(opts.channels))
var iPath: string = opts.input
var oPath: string = opts.output
var iType: FileType = iPath.discernFile()
var oType: FileType = oPath.discernFile()
var dcFilter: bool = opts.highpass
var verbose: bool = opts.verbose

#-- Check for parity between the input and output types --#

#-- If the output dir doesnt exist make it! --#
echo iType
if iType == file:
    # var outputFilePath: string = joinPath(
    #     absolutePath(outputFilePath), 
    #     inputFilePath.extractFilename().changeFileExt(".wav")
    # )
    createOutputFile(
        iPath, 
        oPath, 
        dcFilter, 
        verbose,
        sampRate,
        bitDepth,
        numChans
    )

#TODO block user from setting input and output to the same folder/file
if iType == dir:
    echo "Running in directory mode"
    for kind, inputFilePath in walkDir(iPath):
        if kind == pcFile:
            var outputFilePath: string = joinPath(
                absolutePath(oPath), 
                inputFilePath.extractFilename().changeFileExt(".wav")
            )
            spawn createOutputFile(
                    inputFilePath,
                    outputFilePath, 
                    dcFilter, 
                    verbose,
                    sampRate,
                    bitDepth,
                    numChans
                )

if iType == none:
    quit()