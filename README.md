# nimBend

nimBend is a small command-line application written in Nim-lang. The application can  convert any input file to a WAVE fitting severeal parameters pertaining to bit-depth, sampling rate and number of channels. 



nimBend is fast, small and bare bones and can be compiled to any platform that nim can compile to. This includes MacOS, Windows and Linux.



This project stems from my own perverse use of [SoX](http://sox.sourceforge.net) to _bend_ raw data into audio with the command:

`sox -r 44100 -b 8 -c 1 -e unsigned-integer input.raw output.wav`


I wanted to write a small application that could implement this functionality but without the overhead of having to install SoX, a tool suited to performing a number of tasks that I was however not interested in. This was also a fun project to make my own tool in nim and to experiment with the language.



[Francesco Cameli](github.com/vitreo12) is a significant contributor, particularly in optimising the code to be fast (from 100ms to less than 5ms!). I'd like to also thank him for his patience and guidance on all things nim.



## Installing

Installation is simple. `git clone` this repo, `cd` to it and compile `mosh.nim` using the nim compiler.

We found that the best results for speed and binary size came with aggressive optimisations:

`nim c -d:release -d:danger mosh.nim`

## Usage

Right now, the nimBend executable `mosh` only takes two arguments, an input file and an output file name. Example:

`mosh cat.png output.wav`



If you have any issues please raise one on the github!
