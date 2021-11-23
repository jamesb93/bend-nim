import memfiles, os
import wav

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
    
proc checkMake*(path: string) : void =
    if not exists(path):
        createDir(path)
        echo path, " did not exist and was created for you."
        
proc discernFile*(path: string) : FileType = 
    if fileExists(path):
        return file
    elif dirExists(path):
        return dir
    else:
        return none

proc sanitisePath*(path: string) : string =
    return path.normalizedPath().expandTilde().absolutePath()

proc ensureParity*(input: FileType, output: FileType) : bool =
    if input == output:
        return true
    else:
        echo "There was a mismatch between the type of input and output arguments"
        echo "They should both be either a file or folder."
        return false

proc openRawFile*(path: string) : MemFile =
    return memfiles.open(path, fmRead)

#-- 24 bit unsigned int --#
type 
    ## This type represents an unsigned 24 bit integer
    uint24_obj {.packed.} = object
        bit1 : uint8
        bit2 : uint8
        bit3 : uint8

#https://stackoverflow.com/questions/7416699/how-to-define-24bit-data-type-in-c
proc assignUInt24(obj : var uint24_obj, val : SomeUnsignedInt) =
    #Store as little endian (the way WAV wants it)
    obj.bit3 = uint8(val shr 16 and 0xff)
    obj.bit2 = uint8(val shr 8 and 0xff)
    obj.bit1 = uint8(val and 0xff)

proc asUnsigned32Bit(obj : uint24_obj) : uint32 =
    return (uint32(obj.bit1)) or (uint32(obj.bit2) shl 8) or (uint32(obj.bit3) shl 16)

#-- DC Filter --#
proc applyDCFilter*(dataDC : pointer, dataMem : pointer, dataSize : Natural, bitDepth : uint16) : void =

    #Use floating point operations for precision (and ease of calcs)
    var 
        xPrev : float = 0.0
        yPrev : float = 0.0

    let filterFB : float = 0.995

    #Should be this applied on x (input), or y (output)?
    let scaleAmplitude : float = 0.4

    case bitDepth:
        of 8:
            var dataArr   = cast[ptr UncheckedArray[uint8]](dataMem)
            var dataDCArr = cast[ptr UncheckedArray[uint8]](dataDC)

            let scaledSize = dataSize - 1

            for index in 0..scaledSize:
                let x : float = float(dataArr[index]) # - halfHighestUInt8
                let y : float = x - xPrev + (filterFB * yPrev)
                xPrev = x
                yPrev = y

                #Scale output result.. these should in theory be scaled to min/max of uint8 range
                let finalOut : float = (y * scaleAmplitude) # + halfHighestUInt8
                
                #Re-write the results over to the dataDC array
                dataDCArr[index] = uint8(finalOut)

        of 16:
            var dataArr   = cast[ptr UncheckedArray[uint16]](dataMem)
            var dataDCArr = cast[ptr UncheckedArray[uint16]](dataDC)

            #account for bigger chunks of memory to read
            let scaledSize = int(dataSize / 2) - 1

            for index in 0..scaledSize:
                let x : float = float(dataArr[index]) #- halfHighestUInt16
                let y : float = x - xPrev + (filterFB * yPrev)
                xPrev = x
                yPrev = y

                #Scale output result.. these should in theory be scaled to min/max of uint16 range
                let finalOut : float = (y * scaleAmplitude) # + halfHighestUInt16
                
                #Re-write the results over to the dataDC array
                dataDCArr[index] = uint16(finalOut)
        
        of 24:
            var dataArr   = cast[ptr UncheckedArray[uint24_obj]](dataMem)
            var dataDCArr = cast[ptr UncheckedArray[uint24_obj]](dataDC)

            #account for bigger chunks of memory to read
            let scaledSize = int(dataSize / 3) - 1

            for index in 0..scaledSize:
                let xUnpacked : float = float(dataArr[index].asUnsigned32Bit)
                let x : float = xUnpacked # - halfHighestUInt24
                let y : float = x - xPrev + (filterFB * yPrev)
                
                xPrev = x
                yPrev = y

                #Scale output result.. these should in theory be scaled to min/max of uint24 range
                let finalOut : float = (y * scaleAmplitude) # + halfHighestUInt24

                var finalOut24bit : uint24_obj
                finalOut24bit.assignUInt24(uint32(finalOut))

                #Re-write the results over to the dataDC array
                dataDCArr[index] = finalOut24bit

        of 32:
            var dataArr   = cast[ptr UncheckedArray[uint32]](dataMem)
            var dataDCArr = cast[ptr UncheckedArray[uint32]](dataDC)
            
            #account for bigger chunks of memory to read
            let scaledSize = int(dataSize / 4) - 1

            for index in 0..scaledSize:
                let x : float = float(dataArr[index]) # - halfHighestUInt32
                let y : float = x - xPrev + (filterFB * yPrev)
                xPrev = x
                yPrev = y

                #Scale output result.. these should in theory be scaled to min/max of uint32 range
                let finalOut : float = (y * scaleAmplitude) # + halfHighestUInt32
                
                #Re-write the results over to the dataDC array
                dataDCArr[index] = uint32(finalOut)
        else:
            discard

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
            inputFilePath,
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

        dataDC.applyDCFilter(inputDataMem, inputDataSize, bitDepth)

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

    # Close files
    outputFile.close()
    inputData.close()