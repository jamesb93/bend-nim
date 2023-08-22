version       = "1.0.0"
author        = "James Bradbury"
description   = "bend can turn any input file into audio files in the wav format. It also has functionality for generating new 8bit audio with Markov processes."
license       = "MIT"

srcDir = "src"
bin    = @["bend"]

requires "nim >= 2.0.0"
requires "cligen == 1.6.13"
