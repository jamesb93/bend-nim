import os, system, strutils, argparse, threadpool
import moshutils
{. experimental: "parallel" .} # Enable parallel processing

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
    option("-l", "--limit", default="5000", help="The maximum limit of files to process in directory mode.")
    option("-m", "--maxsize", default="5000", help="The maximum size of an individual file to be processed in directory mode.")
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
let sampRate: uint32 = uint32(parseUInt(opts.rate))
let bitDepth: uint16 = uint16(parseUInt(opts.depth))
let numChans: uint16 = uint16(parseUInt(opts.channels))
let limit: float = parseFloat(opts.limit)
let maxSize: float = parseFloat(opts.maxsize)
let iPath: string = opts.input
let oPath: string = opts.output
let iType: FileType = iPath.discernFile()
let oType: FileType = oPath.discernFile()
let dcFilter: bool = opts.highpass
let verbose: bool = opts.verbose

#-- Make sure that the input and output are not the same file --#
if iPath == oPath:
    echo "You cannot set the same input and output file for safety reasons"
    quit()

#-- Make the output directory if it does not exist --#
if oType == dir or oType == none: checkMake(oPath)

#-- Check for parity between the input and output types --#
if not ensureParity(iType, oPath.discernFile()):
    quit()
    
#-- Operate on single files --#
if iType == file:
    if getFileSize(iPath) != 0:
        createOutputFile(
        iPath, 
        oPath, 
        dcFilter, 
        verbose,
        sampRate,
        bitDepth,
        numChans
        )
    else:
        echo "Input file is 0 bytes!"
        quit()

#-- Operate on folders --#
if iType == dir:
    echo "Running in directory mode"
    var progressMb: float = 0
    while progressMb < limit:
        for inputFilePath in walkDirRec(iPath):
            var sizeMb = getFileSize(inputFilePath).float / (1024 * 1024).float #to mb
            if sizeMb < maxSize and sizeMb != 0: # Check for size limitations
                progressMb += sizeMb

                var outputFilePath: string = joinPath(
                    oPath.absolutePath(), 
                    inputFilePath.extractFilename().formatDotFile().changeFileExt(".wav")
                )

                parallel: spawn createOutputFile(
                    inputFilePath,
                    outputFilePath, 
                    dcFilter, 
                    verbose,
                    sampRate,
                    bitDepth,
                    numChans
                )

if iType == none:
    echo "There was an error with your input or output arguments."
    quit()