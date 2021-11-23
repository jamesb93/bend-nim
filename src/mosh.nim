import convert
from std/tables import toTable

when isMainModule:
    import cligen

    clCfg.version = "0.5.0"

    const Help = {
            "input" : "Input folder or file containing data.",
            "output" : "Output folder or a file.",
            "bitdepth" : "Bit-depth to render to.",
            "numchans" : "Number of channels to write to.",
            "samprate" : "Output samplerate",
            "limit" : "Limit in megabytes of folder contents to write",
            "maxsize" : "Maximum size of any individual file",
            "dc" : "Apply a DC filter to the output"
    }.toTable()
    
    dispatch(conversion, help=Help)
