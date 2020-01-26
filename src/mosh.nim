import os, system, strutils, argparse, threadpool
import moshutils
{. experimental: "parallel" .} # Enable parallel processing

#-- CLI Args --#
when declared(commandLineParams):
    var cliArgs = commandLineParams()

# Parse Arguments
var p = newParser("mosh"):
    help("mosh can turn any input file into audio files in the wav format.")
    option("-b", "--depth", choices = @["8","16","24","32"], default="8", help="Bit-depth of the output file.")
    option("-c", "--channels", default="1", help="Number of channels in the output file.")
    option("-r", "--rate", default="44100", help="The sampleing rate of the output file.")
    option("-l", "--limit", default="5000", help="The maximum limit of files to process in directory mode.")
    option("-m", "--maxsize", default="5000", help="The maximum size of an individual file to be processed in directory mode.")
    flag("-dc", "--dcfilter", help="Applies a DC filter to the output.")
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
let dcFilter: bool = opts.dcfilter
let verbose: bool = opts.verbose

#-- Make sure that the input and output are not the same file --#
if iPath == oPath:
    echo "You cannot set the same input and output file for safety reasons"
    quit()

#-- Make the output directory if it does not exist --#
if iType == dir: 
    checkMake(oPath)
    let oType: FileType = oPath.discernFile()
    
#-- Operate on single files --#
if iType == file:
    if verbose: echo "Running single file mode"
    if getFileSize(iPath) != 0:
        createOutputFile(
            iPath, 
            oPath, 
            dcFilter, 
            sampRate,
            bitDepth,
            numChans,
            generate
        )
    else:
        echo "Input file is 0 bytes!"
        quit()

#-- Operate on folders --#
if iType == dir:
    var outputDir: string = oPath.absolutePath()
    if verbose: echo "Running in directory mode"
    var progressMb: float = 0

    for inputFilePath in walkDirRec(iPath):
        if progressMb < limit:
            if verbose: echo inputFilePath
            if inputFilePath.parentDir() != oPath:
                var sizeMb = getFileSize(inputFilePath).float / (1024 * 1024).float #to mb
                if sizeMb < maxSize and sizeMb != 0: # Check for size boundaries
                    var outputFilePath = outputDir / inputFilePath.extractFilename().formatDotFile().changeFileExt("wav")
                    parallel: spawn createOutputFile(
                        inputFilePath,
                        outputFilePath, 
                        dcFilter, 
                        sampRate,
                        bitDepth,
                        numChans
                    )
                    progressMb += sizeMb

if iType == none:
    echo "There was an error with your input or output arguments."
    quit()