import std/[os, threadpool, terminal, math], system
import convertutils
{. experimental: "parallel" .}

proc conversion*( 
    input: string,
    output: string,
    bitDepth: uint16 = 8,
    numChans: uint16 = 1,
    sampRate: uint32 = 44100,
    limit: float = 5000,
    maxSize: float = 4096,
    dc: bool = true
): void =

    let iPath = sanitisePath(input)
    let oPath = sanitisePath(output)
    #-- Discern the input/output information --#
    let iType: FileType = discernFile(iPath)

    #-- Make the output directory if it does not exist --#
    if iType == dir: 
        checkMake(output)

    #-- Make sure that the input and output are not the same file --#
    if sameFile(iPath, oPath):
        echo "You cannot set the same input and output file for safety reasons"
        quit()

    #-- Operate on single files --#
    if iType == file:
        if getFileSize(iPath) != 0:
            createOutputFile(
                iPath, 
                oPath, 
                dc, 
                sampRate,
                bitDepth,
                numChans,
            )
        else:
            echo "Input file is 0 bytes!"
            quit()

    #-- Operate on folders --#
    if iType == dir:
        var mbAccum: float = 0
        var files: seq[string]

        for inputFilePath in walkDirRec(input):
            if mbAccum < limit and inputFilePath.parentDir() != oPath:
                try:
                    var sizeMb = getFileSize(inputFilePath).float / (1024 * 1024).float # to mb
                    if sizeMb < maxSize and sizeMb != 0: # Check for size boundaries
                        files.add(inputFilePath)
                        mbAccum += sizeMb
                except OSError:
                    discard


        for i, iFile in files:
            # Terminal Writing
            let percentage: float = round((i / files.len) * 100.0)
            stdout.eraseLine()
            stdout.write(percentage)
            stdout.flushFile

            var oFile = oPath / iFile.extractFilename().formatDotFile().changeFileExt("wav")
            if not fileExists(oFile):
                parallel: spawn createOutputFile(
                    iFile,
                    oFile, 
                    dc, 
                    sampRate,
                    bitDepth,
                    numChans
                )

    if iType == none:
        echo "There was an error with your input or output arguments."
        quit()