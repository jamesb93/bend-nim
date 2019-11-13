import memfiles, parseopt, mosh_utils, os, system
#-- CLI Args --#
when declared(commandLineParams):
    var cliArgs = commandLineParams()

if len(cliArgs) < 2:
    echo "You need to provide an input and output file!"
    quit()

# Parse Arguments
var args : seq[string]
var parser = initOptParser(cliArgs)
while true:
    parser.next()
    case parser.kind
    of cmdEnd: break
    of cmdShortOption, cmdLongOption:
      if parser.val == "":
        echo "Option: ", parser.key
      else:
        echo "Option and value: ", parser.key, ", ", parser.val
    of cmdArgument:
      args.add(parser.key)

var iFile: string = args[0]
var oFile: string = args[1]
if not fileExists(iFile):
    echo "The input file does not exist."
    quit()

#-- Process input file > output file --#
let 
    data = openRawFile(iFile)
    dataMem = data.mem
    dataSize = data.size

    header = createHeader(uint32(dataSize))

var outputFile : File
discard outputFile.open(oFile, fmWrite)

#-- Write header --#
for value in header.fields:
    when value is array:
        for arrayVal in value:
            discard outputFile.writeBuffer(unsafeAddr(arrayVal), sizeof(arrayVal))
    else:
        discard outputFile.writeBuffer(unsafeAddr(value), sizeof(value))

#-- Write input data --#
discard outputFile.writeBuffer(dataMem, (sizeof(uint8) * dataSize))

outputFile.close()