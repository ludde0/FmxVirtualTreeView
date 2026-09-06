BUILDING THESE PACKAGES WITH A DELPHI OTHER THAN 12
===================================================

Short version: run PatchPackagesForDelphi.exe in this folder, press Detect
installed, press Patch, then change one line in DelphiVersion.inc.


Why anything is needed at all
-----------------------------

A Delphi package carries a library suffix. RAD Studio 12 uses 290, which is why
its own runtime package is called rtl290.bpl. These projects have that number
written into them in eight places - {$LIBSUFFIX} in the four .dpk files, and
<DllSuffix> in the four .dproj files.

Build them with a different RAD Studio and nothing would complain at first. The
packages would compile. Then installing the design package would fail with

    Can't load package VirtualTreesFMX_Runtime290.bpl

because the runtime package was built under the suffix your Delphi uses, while
the design package was told to ask for 290.

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
   installation rather than from a guess.

3. Press "Patch". All eight files are written, and the originals are kept in
   _Backup.

4. Nothing, normally. Patch also adds your RAD Studio to the list of versions
   DelphiVersion.inc accepts, and says so in the log.

   If it reports that it could not, open DelphiVersion.inc and add the line it
   prints, next to the one already there. Every RAD Studio defines a version
   symbol of its own: Delphi 12 is VER360, and each release numbers ten higher
   than the one before it.

5. Close the package projects in the IDE before or after patching - an open
   project will write its own copy back over the change - then build and install
   as described in ReadMe.txt.


Doing it by hand instead
------------------------

There is nothing magic in the tool. Set {$LIBSUFFIX 'nnn'} in all four .dpk
files and <DllSuffix>nnn</DllSuffix> in all four .dproj files to the number in
your rtl<nnn>.bpl, then step 4 above. The tool exists so the eight cannot
disagree with each other.


Only Delphi 12 is supported
---------------------------

That is a statement about what has been tested, not a restriction in the code.
The library itself has no version-specific code and the packages are ordinary
package projects. If it works for you on a newer Delphi, good; if it does not,
the source is there to fix.
