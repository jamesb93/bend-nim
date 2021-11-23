version       = "0.5.0"
author        = "James Bradbury"
description   = "mosh can turn any input file into audio files in the wav format. It also has functionality for generating new 8bit audio with Markov processes."
license       = "MIT"

srcDir = "src"
bin    = @["mosh"]

requires "nim >= 1.6.0"
requires "cligen == 1.5.19"
