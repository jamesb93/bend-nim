import os, system, threadpool
import convertutils
{. experimental: "parallel" .}

proc conversion*(
    input:string,
    output:string,
    bitDepth:uint16=8,
    numChans:uint16=1,
    sampRate:uint32=44100,
    limit:float=5000,
    maxSize:float=4096,
    dc:bool=true
): void =

    #-- Discern the input/output information --#
    let iType: FileType = input.discernFile()

    #-- Make sure that the input and output are not the same file --#
    if input == output:
        echo "You cannot set the same input and output file for safety reasons"
        quit()

    #-- Make the output directory if it does not exist --#
    if iType == dir: 
        checkMake(output)
        let oType: FileType = output.discernFile()
        
    #-- Operate on single files --#
    if iType == file:
        if getFileSize(input) != 0:
            createOutputFile(
                input, 
                output, 
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
        var outputDir: string = output.absolutePath()
        var progressMb: float = 0

        for inputFilePath in walkDirRec(input):
            if progressMb < limit:
                if inputFilePath.parentDir() != output:
                    var sizeMb = getFileSize(inputFilePath).float / (1024 * 1024).float #to mb
                    if sizeMb < maxSize and sizeMb != 0: # Check for size boundaries
                        var outputFilePath = outputDir / inputFilePath.extractFilename().formatDotFile().changeFileExt("wav")
                        parallel: spawn createOutputFile(
                            inputFilePath,
                            outputFilePath, 
                            dc, 
                            sampRate,
                            bitDepth,
                            numChans
                        )
                        progressMb += sizeMb

    if iType == none:
        echo "There was an error with your input or output arguments."
        quit()