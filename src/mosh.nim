import os, system, strutils, argparse, threadpool
import moshutils
import progress
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
let iPath: string = opts.input
let oPath: string = opts.output
let iType: FileType = iPath.discernFile()
let oType: FileType = oPath.discernFile()
let dcFilter: bool = opts.highpass
let verbose: bool = opts.verbose

#-- Check for parity between the input and output types --#
if not ensureParity(iType, oType):
    quit()

if iPath == oPath:
    echo "You cannot set the same input and output file for safety reasons"
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

#-- Operate on folders --#
if iType == dir:
    echo "Running in directory mode"
    var bar = newProgressBar()
    checkMake(oPath)
    for kind, inputFilePath in walkDir(iPath):
        if kind == pcFile and getFileSize(inputFilePath) != 0:
            
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