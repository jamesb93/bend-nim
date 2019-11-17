version       = "0.1.0"
author        = "James Bradbury"
description   = "nimBend can turn any input file into audio files in the wav format."
license       = "MIT"

srcDir = "src"
bin    = @["mosh"]

requires "nim >= 1.0.0"
requires "argparse >= 0.9.0"
requires "progress >= 1.1.1"

#Manual buildRelease
task buildRelease, "Builds nimBend with -d:release and -d:danger":
    exec "nim c -d:release -d:danger --opt:speed --threads:on --outdir:./ ./src/mosh.nim"

#Manual installRelease
task installRelease, "Builds nimBend with -d:release and -d:danger and installs it in ~/.nimble/bin":
    exec "nimble install --passNim:-d:release --threads:on --passNim:-d:danger --passNim:--opt:speed"

#Manual buildDebug
task buildDebug, "Builds nimBend without any optimisations and full stack traces":
    exec "nim c --stackTrace:on -x:on --opt:none --threads:on -o:./ ./src/mosh.nim"