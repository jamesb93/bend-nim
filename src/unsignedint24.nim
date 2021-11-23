#-- 24 bit unsigned int --#
type 
    ## This type represents an unsigned 24 bit integer
    uint24* {.packed.} = object
        bit1 : uint8
        bit2 : uint8
        bit3 : uint8

#https://stackoverflow.com/questions/7416699/how-to-define-24bit-data-type-in-c
proc assignUInt24*(val : SomeUnsignedInt) : uint24 =
    #Store as little endian (the way WAV wants it)
    result.bit3 = uint8(val shr 16 and 0xff)
    result.bit2 = uint8(val shr 8 and 0xff)
    result.bit1 = uint8(val and 0xff)

proc asUnsigned32Bit*(obj : uint24) : uint32 =
    return (uint32(obj.bit1)) or (uint32(obj.bit2) shl 8) or (uint32(obj.bit3) shl 16)

