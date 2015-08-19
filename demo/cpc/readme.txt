Running the test program in the WinApe emulator:

* Create a new disk with WinApe: "File" -> "Drive A:" -> "New Blank Disc...". 

* Select "Format Disc Image...".

* Click "Edit Disc..." and drag&drop the binary to the disk edit window.

* Now run the following BASIC commands:

  memory &3fff
  load"tetay.bin",&4000
  call &4000

The program should now start.