# XPMCK
OSX "fork" of http://jiggawatt.org/muzak/xpmck/ Release 32

# How to Compile
I am including my own binaries in the repo, but you may choose to compile them yourself.

## Install Euphoria
To compile, you will need to have installed [Euphoria](http://openeuphoria.org)

[euphoria-4.1.0-OSX-ix86-64.tar.gz](https://sourceforge.net/projects/rapideuphoria/files/Euphoria/4.1.0)

Once it's placed somewhere you need to update your PATH. I do it this way, ~/.profile
```
# stuff for Euphoria
export EUDIR="$HOME/Code/euphoria"
export PATH="$PATH:$EUDIR/bin"
export EUINC="$EUDIR/include"
```

open a new terminal or source the profile `. ~/.profile` and then try `eui -v` to ensure your PATH is setup properly.

Then from the XPMCK root directory, just type `make` and you will build all of the tools.

_note_: Only xpmc requires Euphoria. The other helper tools are c/cpp apps.

You may want to additionally add the XPMCK bin dir to your PATH variable ;)
