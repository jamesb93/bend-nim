import memfiles, os
import wav, unsignedint24

type FileType* = enum
    file,
    dir,
    none

proc formatDotFile*(input: string): string =
    if input[0] == '.': 
        return input[1..^1] 
    else: 
        return input

#-- Deal with bad folder inputs --#
proc exists(p: string): bool =
    try:
        discard getFileInfo(p)
        result = true
    except OSError:
        result = false
    
proc checkMake*(filePath: string) : void =
    if not exists(filePath):
        createDir(filePath)
        echo filePath, " did not exist and was created for you."
        
proc discernFile*(filePath: string) : FileType = 
    if filePath.fileExists():
        return file
    elif filePath.dirExists():
        return dir
    else:
        return none

proc ensureParity*(input: FileType, output: FileType) : bool =
    if input == output:
        return true
    else:
        echo "There was a mismatch between the type of input and output arguments"
        echo "They should both be either a file or folder."
        return false

proc openRawFile*(filePath: string) : MemFile =
    return memfiles.open(filePath, fmRead)

proc applyDCFilter*(dataDC : pointer, dataMem : pointer, dataSize : Natural, bitDepth : typedesc) : void =
    var 
        xPrev = 0.0
        yPrev = 0.0
        dataArr   = cast[ptr UncheckedArray[bitDepth]](dataMem)
        dataDCArr = cast[ptr UncheckedArray[bitDepth]](dataDC)

    let
        filterFB = 0.995
        scaleAmplitude = 0.4

    when bitDepth is uint8:
        let scaledSize = dataSize
    elif bitDepth is uint16:
        let scaledSize = int(dataSize / 2)
    elif bitDepth is uint24:
        let scaledSize = int(dataSize / 3)
    elif bitDepth is uint32:
        let scaledSize = int(dataSize / 4)
    else:
        {.fatal: "Invalid unsigned int type: " & $T.}

    for index in 0..<scaledSize:
        when bitDepth is uint24:
            let x = float(dataArr[index].asUnsigned32Bit)
        else:
            let x = float(dataArr[index])
        let y = x - xPrev + (filterFB * yPrev)
        xPrev = x
        yPrev = y

        #Scale output result
        when bitDepth is uint24:
            let finalOut = assignUInt24(uint(y * scaleAmplitude))
        else:
            let finalOut = y * scaleAmplitude
        
        #Re-write the results over to the dataDC array
        dataDCArr[index] = bitDepth(finalOut)

proc createOutputFile*(
    inputFilePath: string,
    outputFilePath: string, 
    dcFilter: bool,
    sampRate: uint32,
    bitDepth: uint16,
    numChans: uint16,
    ) {.thread.} =
    
    #-- Process input file > output file --#
    var
        inputData: MemFile = memfiles.open(
            absolutePath(inputFilePath), 
            fmRead
            )
            
        inputDataMem  = inputData.mem
        inputDataSize = inputData.size
        
        dataDC: pointer 

        header: wavHeader = createHeader(
            uint32(inputDataSize),
            sampRate,
            bitDepth,
            numChans
        )

    #Create the output file
    var outputFile : File
    if not outputFile.open(outputFilePath, fmWrite):
        echo "ERROR: Could not create ", outputFilePath
        return
    
    #Apply DC filter
    if dcFilter:
        #raw bytes allocation
        dataDC = alloc(inputDataSize)

        if dataDC.isNil:
            echo "ERROR: Could not allocate data for DC filter"
            return

        case bitDepth:
            of 8:
                dataDC.applyDCFilter(inputDataMem, inputDataSize, uint8)
            of 16:
                dataDC.applyDCFilter(inputDataMem, inputDataSize, uint16)
            of 24:
                dataDC.applyDCFilter(inputDataMem, inputDataSize, uint24)
            of 32:
                dataDC.applyDCFilter(inputDataMem, inputDataSize, uint32)
            else: 
                echo "ERROR: Invalid bitDepth: ", $bitDepth
                return

    #-- Write header --#
    for value in header.fields:
        when value is array:
            for arrayVal in value:
                discard outputFile.writeBuffer(unsafeAddr(arrayVal), sizeof(arrayVal))
        else:
            discard outputFile.writeBuffer(unsafeAddr(value), sizeof(value))
    
    #-- Write data to output --#
    if dcFilter:
        discard outputFile.writeBuffer(dataDC, inputDataSize)
        dataDC.dealloc
    else:
        discard outputFile.writeBuffer(inputDataMem, inputDataSize)

    #Close files
    outputFile.close()
    inputData.close()
