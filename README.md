# nimBend

nimBend is a small command-line application written in Nim. The application converts any input file to a WAVE audio file given parameters for bit-depth, sampling rate and number of channels. 


nimBend is fast, small and bare bones and can be compiled to any platform that Nim can compile to. This includes MacOS, Windows, Linux, iOS, Android.


This project stems from my own perverse use of [SoX](http://sox.sourceforge.net) to _bend_ raw data into audio with the command:

`sox -r 44100 -b 8 -c 1 -e unsigned-integer input.raw output.wav`


I wanted to write a small application that could implement this functionality but without the overhead of having to install SoX, a tool suited to performing a number of other DSP tasks that I didn't need. This was also a fun project to learn more about the structure of WAVE audio as well as experimenting with the Nim language.


[Francesco Cameli](github.com/vitreo12) is a significant contributor, particularly in optimising the code to be fast (from 100ms to less than 5ms!). I'd like to also thank him for his patience and guidance on all things Nim.


## Installing

Installation is simple. `git clone` this repo, `cd` to it and run the following `nimble` command:

`nimble installRelease`

The command will install all nimBend's executables in your predefined `nimble` directory. (Usually, ~/.nimble/bin)

## Usage

Right now, the nimBend executable `mosh` only takes two arguments, an input file/folder and an output file/folder name. Example:

`mosh cat.png output.wav`

Which could convert the `cat.png` file to a new wav file `output.wav`.

or

`mosh foo bar`

Which would convert all the files inside the directory `foo` recursively into a new folder called `bar`


If you have any issues or questions please raise one on the github!
