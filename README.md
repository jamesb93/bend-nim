# bend

bend is a small command-line application written in Nim for 'bending' data into audio. There is also an experimental markov-based synthesiser that can help you generate audio based on the results of your conversion process.


bend is fast, small and bare bones and can be compiled to any platform that Nim can compile to. This includes MacOS, Windows, Linux, iOS, Android.


This project stems from my own perverse use of [SoX](http://sox.sourceforge.net) to _bend_ raw data into audio with the command:

`sox -r 44100 -b 8 -c 1 -e unsigned-integer input.raw output.wav`


I wanted to write a small application that could implement this functionality but without the overhead of having to install SoX, a tool suited to performing a number of other DSP tasks that I didn't need. This was also a fun project to learn more about the structure of WAVE audio as well as experimenting with the Nim language.


[Francesco Cameli](github.com/vitreo12) is a significant contributor, particularly in optimising the code to be fast (from 100ms to less than 5ms!). I'd like to also thank him for his patience and guidance on all things Nim.


# Installation

First, it is most convenient to have access to the `nim` compiler as well as `nimble`. To install both of these you can use [choosenim](https://github.com/dom96/choosenim#installation).

Once you have `choosenim` you can `git clone` this repo, `cd` to it and run the following `nimble` command:

`nimble install`

This will give you an executable inside the project folder that you can use in place or move to your `$PATH`.

# Usage

You can pass a folder or file as the input and the executable will convert all files in the folder recursively or a single file and place it at the output which is a directory or file.


 an input file/folder and an output file/folder name. Example:

`bend cat.png output.wav`

Which could convert the `cat.png` file to a new wav file `output.wav`.

or

`bend foo bar`

Which would convert all the files inside the directory `foo` recursively into a new folder called `bar`.

## Help and issues
---


Detailed help can be found by running `bend -h` or `bend convert -h` or `bend generate -h`.

If you have any issues or questions please raise one on the github!
