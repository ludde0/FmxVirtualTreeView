BUILDING THESE PACKAGES WITH A DELPHI OTHER THAN 13
===================================================

Short version: run PatchPackagesForDelphi.exe in this folder, press Detect
installed, pick your RAD Studio's suffix, press Patch.


Why anything is needed at all
-----------------------------

A Delphi package carries a library suffix. RAD Studio 13 uses 370, which is why
its own runtime package is called rtl370.bpl; RAD Studio 12 uses 290. These
projects have that number written into them in eight places - {$LIBSUFFIX} in
the four .dpk files, and <DllSuffix> in the four .dproj files.

Build them with a different RAD Studio and nothing would complain at first. The
packages would compile. Then installing the design package would fail with

    Can't load package VirtualTreesFMX_Runtime370.bpl

because the runtime package was built under the suffix your Delphi uses, while
the design package was told to ask for 370.

That error says nothing about the cause, so DelphiVersion.inc stops it earlier.
It names the suffix the packages carry and the RAD Studios that suffix is right
for, and refuses to compile when the two do not match - either because this
Delphi is not one anybody has built these with, or because the suffix belongs to
a different one.


What to do
----------

1. Run PatchPackagesForDelphi.exe, in this folder.

   If it is not here, the repository does not ship it built for your machine -
   open PatchPackagesForDelphi\PatchPackagesForDelphi.dpr, set the output
   directory to "..", and build it.

2. Press "Detect installed". It reads the suffix out of the rtl<nnn>.bpl of
   every RAD Studio the registry knows about, so the number comes from your
   installation rather than from a guess. With several installed, the newest is
   filled in; type the one you want if that is not it.

3. Press "Patch". All eight files are written, and the originals are kept in
   _Backup.

4. Nothing, normally. DelphiVersion.inc already accepts RAD Studio 12 (suffix
   290) and RAD Studio 13 (suffix 370). For any other version, Patch adds a
   line for it and says so in the log.

   If it reports that it could not, open DelphiVersion.inc and add the line it
   prints, next to the ones already there. Every RAD Studio defines a version
   symbol of its own: Delphi 12 is VER360, Delphi 13 is VER370, and each release
   numbers ten higher than the one before it.

5. Close the package projects in the IDE before or after patching - an open
   project will write its own copy back over the change - then build and install
   as described in ReadMe.txt.

The .dproj files are saved by RAD Studio 13. If an older IDE will not open
one, delete it and let the IDE recreate it from the .dpk, then run Patch once
more so <DllSuffix> is set again.


Doing it by hand instead
------------------------

There is nothing magic in the tool. Set {$LIBSUFFIX 'nnn'} in all four .dpk
files and <DllSuffix>nnn</DllSuffix> in all four .dproj files to the number in
your rtl<nnn>.bpl, change {$DEFINE VT_SUFFIX_nnn} in DelphiVersion.inc to the
same number, then step 4 above. The tool exists so the nine cannot disagree with
each other.


Which versions are tested
-------------------------

The packages are set up for RAD Studio 13 and tested with it. RAD Studio 12 was
the previous target and is still accepted by DelphiVersion.inc. Anything older
is untested - that is a statement about what has been tried, not a restriction
in the code. The library itself has no version-specific code and the packages
are ordinary package projects. If it works for you on another Delphi, good; if
it does not, the source is there to fix.
