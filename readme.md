# KeepassClone
A clone of the GUI of Keepass to test out the SciterJS framework.

## Building and Running
Before cloning this repository, you will need to download the SciterJS SDK from their GitLab
[repository](https://gitlab.com/sciter-engine/sciter-js-sdk) as a zip or tar.gz file and extract it
to a memorable location on your pc, then remove the trailing `-main` (I recommend `C:\sciter-js-sdk`
for windows or `~/sciter-js-sdk` for linux because the build scripts assume these locations).

After following the platform specific instructions you can execute the `build.bat` file on windows
or the `build.sh` file on linux from the root of the project to build the binary. The outputted
binary must be run from the root to work as intended.

The build scripts consist of two parts, firstly the packfolder binary in the SciterJS SDK is called
on the `ui` folder of this project to generate a `program/include/resources.cpp` file which is then
included in any cpp files that need to access it - this file is not included in compilation. Next
the makefile is run which compiles the project as per usual. Note that on windows everything is
statically linked except the `sciter.dll` file, but on linux everything is dynamically linked,
including the `libsciter.so` file.

On windows, when you run the binary the manifest file in the same directory as it is read, this is
to ensure that the binary has DPIAwareness set to true and PerMonitorV2 or V1 if possible, as this
is recommended by SciterJS for windows.

### Windows
You must have any 64-bit version of [MinGW](https://winlibs.com/) with clang/LLVM support in your
path, this will give you access to the unix tools that are used in the makefile. To build using the
makefile, you will need Make (`winget install make --source winget`) and Python3 (`winget install
--id Python.Python.3.12`);

### Linux
If you don't already have a native linux box, I highly recommend using WSL2, specifically running
`wsl2 --install Ubuntu-24.04`, as this framework is very particular about the video dependencies on
linux and 24.04 happens to have the best ones for it.

Do the following to ensure your environment is set up correctly:
- Only run `sudo apt update && sudo apt upgrade` if you haven't already.
- Run `sudo apt install git g++ make llvm clang clang-format`.
- Only run `sudo apt install alsa xorg openbox` if you don't already have an audio and window
  manager.

### Mac
Not yet supported.

## Updating SciterJS
If you need to update SciterJS to a newer version, after getting the new SDK from their GitLab,
replace the following files of this project with the ones from the SDK:
- `binary/windows/sciter.dll` with `bin/windows/x64/sciter.dll`
- `binary/linux/libsciter.so` with `bin/linux/x64/libsciter.so`
- `external/include/sciter` with `include` except `sciter-win-main.cpp`, `sciter-gtk-main.cpp` and
  `sciter-osx-main.mm`, which all go insisde `external/source`.

## Updating Any of the Linux Dependencies
These include `external/include/gtk`, `external/include/cairo`, `external/include/harfbuzz`,
`external/include/graphene`, `external/include/glib`, `external/include/pango` and
`external/include/gdk-pixbuf`. Their current versions can be found in
`external/gtk_version_info.txt`.

These are all the dependencies that SciterJS requires to run on linux, and you can get them all when
you run `sudo apt install libgtk-4-dev libcairo2-dev libharfbuzz-dev libgraphene-1.0-dev
libglib2.0-dev libpango1.0-dev libgdk-pixbuf2.0-dev`.

You then need to replace each folder with the corresponding folder(s) of your linux distribution
which should be located as follows:
- `/usr/include/gtk-4.0`
- `/usr/include/cairo`
- `/usr/include/harfbuzz`
- `/usr/include/graphene-1.0` and `/usr/lib/x86_64-linux-gnu/graphene-1.0/include`
- `/usr/include/glib-2.0` and `/usr/lib/x86_64-linux-gnu/glib-2.0/include`
- `/usr/include/pango-1.0`
- `/usr/include/gdk-pixbuf-2.0`
