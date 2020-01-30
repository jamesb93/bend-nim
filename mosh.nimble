version       = "0.2.0"
author        = "James Bradbury"
description   = "nimBend can turn any input file into audio files in the wav format. It also has functionality for generating new 8bit audio with Markov processes."
license       = "MIT"

srcDir = "src"
bin    = @["mosh"]

requires "nim >= 1.0.0"
requires "cligen"

#Manual buildRelease
task buildRelease, "Builds nimBend with -d:release and -d:danger":
    exec "nim c -d:release -d:danger --opt:speed --threads:on --outdir:./ ./src/mosh.nim"

#Manual installRelease
task installRelease, "Builds nimBend with -d:release and -d:danger and installs it in ~/.nimble/bin":
    exec "nimble install --passNim:-d:release --passNim:--threads:on --passNim:-d:danger --passNim:--opt:speed"

#Manual buildDebug
task buildDebug, "Builds nimBend without any optimisations and full stack traces":
    exec "nim c --stackTrace:on -x:on --opt:none --threads:on -o:./ ./src/mosh.nim"