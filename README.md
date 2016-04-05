# XPMCK
Fork of http://jiggawatt.org/muzak/xpmck/ Release 32

XPMCK is a cross platform music (expressed in MML) compiler kit targeted towards various video game systems. It currently supports the following systems:

- Amstrad CPC
- Atari 8-bit (400/800/XL/XE)
- Capcom Play System (VGM output only)
- ColecoVision (CLV)
- Commodore 64 (C64)
- MSX (KSS output only)
- Nintendo Gameboy / Gameboy Color
- PC-Engine (PCE) / TurboGrafx
- SEGA Master System (SMS)
- SEGA Game Gear (SGG)
- SEGA Genesis (SGEN)

Besides the compiler and its source code, the kit includes playback libraries for all supported systems, as well as examples and brief documentation.

# This Fork

This fork mainly focuses on bugfixes and new features. Believe me, there were some important bugs to be fixed!

While XPMCK is a cross-platform software, a lot of my "convenience scripts" are written exclusively for *nix platforms. There should be an inclusion of Windows batch scripts in the near future.

# How to Compile

The X-platform MML compiler (XPMC) is the main program. It requires Euphoria to compile. If you make any changes to the XPMC Euphoria source code, xpmc must be recompiled.

Additionally, there are other small utility programs written in C and CPP that also require compiling, but they are only needed for certain targets. I recommend building all of them.

Since my OS of choice is *nix-based, I have written a Makefile to compile all of these programs. I am not sure if the original Windows release included any sort of build-all script, but it does not yet exist in this repo for Windows developers of XPMCK.

## Install Euphoria
Please install [Euphoria](http://openeuphoria.org).

I suggest downloading 4.1.0 from [Sourceforge](https://sourceforge.net/projects/rapideuphoria/files/Euphoria/). There are appropriate downloads for Windows/Linux 64/32 bit, and even ARMv6!

## OSX / *nix

Compiling will require `gcc`, `g++`, and `make`.

Once Euphoria is downloaded and placed somewhere permanent, you need to update your PATH environment variable. I do it by appending to the file `~/.profile` on OSX or `~/.bashrc` on Linux:

```
# stuff for Euphoria
export EUDIR="$HOME/Code/euphoria"
export PATH="$PATH:$EUDIR/bin"
export EUINC="$EUDIR/include"

# XPMCK
export XPMCK_DIR="$HOME/Code/xpmck-32"    # must be defined for XPMCK bash scripts
export PATH="$PATH:$XPMCK_DIR/bin"
```

Note that in the above snippet, you must change `EUDIR` and `XPMCK_DIR` to reflect the location of your Euphoria and XPMCK directories, respectively.

Open a new terminal to `source` the newly updated file and then try `eui -v` to ensure your PATH is setup properly.

Then from the XPMCK root directory, just type `make` to build all of the tools.

## Windows

There are no instructions for this platform yet. A Windows-based contributor to this project is welcome and needed.
