Virtual TreeView - IDE packages
==============================

You do NOT need any of this to use Virtual TreeView. It exists only to put the
components on the IDE tool palette so you can drop a tree on a form at design
time. If you create the tree in code, ignore this folder and read "Using the
source directly" at the end.


What is here
------------

VirtualTreesReg.pas   Registration and the design-time property editors.
VirtualTrees.dcr      The palette icons.

Both of those files are shared by all four package projects, which sit beside
them here:

  VirtualTreesVCL_Runtime.dpk   Runtime package, VCL. Contains the tree units.
  VirtualTreesVCL_Design.dpk    Design package, VCL. Registers the components.
  VirtualTreesVCL.groupproj     Builds both of the above.

  VirtualTreesFMX_Runtime.dpk   Runtime package, FireMonkey.
  VirtualTreesFMX_Design.dpk    Design package, FireMonkey.
  VirtualTreesFMX.groupproj     Builds both of the above.

The design package is the one that gets installed into the IDE; it requires
the runtime package, so the runtime package must be built first.

Only RAD Studio 12 is supported, so the projects are written for it directly
rather than kept in a per-version folder. Anyone needing an older Delphi can
build their own packages from the units in Source.

The library suffix is pinned to 290, the RAD Studio 12 package version, so
what gets built is VirtualTreesVCL_Runtime290.bpl and so on.

It is written out rather than left as {$LIBSUFFIX AUTO} on purpose. With AUTO,
the design package records its dependency on the runtime package as the literal
name VirtualTreesFMX_RuntimeAUTO.bpl, which is not what the compiler produced,
and installing it fails with "Can't load package ... AUTO.bpl".

Moving to a newer RAD Studio therefore means changing that number in eight
places: {$LIBSUFFIX} in the four .dpk files and <DllSuffix> in the four .dproj
files. Two things are here so that nobody has to discover this the hard way:

  DelphiVersion.inc   Included by all four .dpk files. It refuses to compile
                      under a RAD Studio the packages have not been set for, and
                      says what to do instead. A wrong suffix otherwise produces
                      no error until the design package is installed, and then
                      only "Can't load package ...290.bpl".

  README FIRST - OTHER DELPHI VERSIONS.txt
                      The whole procedure, for someone who has just hit that
                      message.


PatchPackagesForDelphi
----------------------

A one-window utility that reads the suffix out of every .dpk and .dproj in this
folder and writes a new one into all of them at once, so the eight cannot end up
disagreeing with each other.

  Detect installed   asks the registry which RAD Studio versions are installed
                     and reads the suffix out of the rtl<nnn>.bpl in each one's
                     bin folder, so the number comes from the installation
                     rather than from a guess about what the next version
                     numbers itself. Every folder searched is logged.
  Patch              rewrites the suffix, keeping a dated copy of each file in
                     _Backup first.

The built .exe is kept in this folder and committed to the repository - somebody
whose Delphi is not 12 needs it before these packages will compile at all. To
rebuild it, open PatchPackagesForDelphi\PatchPackagesForDelphi.dpr; the IDE
writes the .dproj on first save. Point the output directory at "..", so the .exe
lands beside the packages it patches.

The files are edited as raw bytes, so a byte order mark or a line ending the IDE
put there is left exactly as it was. Close the package projects in the IDE before
patching: an open project will write its own copy back over the change.

Patch also brings DelphiVersion.inc in step: it writes the suffix there as a
symbol, and adds a line pairing this RAD Studio with it, working the version
symbol out from the suffix - 290 belongs to VER360, 280 to VER350. Version lines
are added rather than replaced, so a folder that has been built with several RAD
Studios goes on accepting all of them.

That pairing is what lets the compiler catch a suffix meant for another RAD
Studio. {$LIBSUFFIX} takes a string literal, which the compiler cannot compare
against anything, so the same number is repeated in DelphiVersion.inc in a form
it can test. Patching the eight files without it would leave the packages
building cleanly and failing at install, which is the whole problem this is
here to prevent.


IMPORTANT: VCL and FMX cannot both be installed
-----------------------------------------------

Both design packages register components with the same names
(TVirtualStringTree, TVirtualDrawTree). The IDE will not accept two packages
registering the same component class, so only one of the two may be installed
at a time.

This is a limitation of design-time registration, not of the code. Projects of
either framework can still be compiled from source at any time, whichever
package happens to be installed - see "Using the source directly" below.


Installing
----------

1. Open Tools > Options > Language > Delphi > Library. For every platform you
   build for, add the Source folder of this repository to the Library path,
   for example:

       Q:\...\FmxVirtualTreeView\Source

2. Open VirtualTreesVCL.groupproj (VCL) or VirtualTreesFMX.groupproj (FMX).

3. Select the Release configuration.

4. Build VirtualTreesVCL_Runtime (or VirtualTreesFMX_Runtime) for Win32, then
   for Win64.
   The design package is Win32 only, because the IDE itself is a 32-bit
   program.

5. Right-click VirtualTreesVCL_Design (or VirtualTreesFMX_Design) and choose
   Install.

The components appear on the palette page "Virtual Controls".


Checking that it worked
-----------------------

1. View > Tool Palette, and search for "Virtual". The page "Virtual Controls"
   should hold TVirtualStringTree and TVirtualDrawTree.

2. Start a new application of the matching framework and drop a
   TVirtualStringTree on the form. Generic palette icons instead of the tree
   ones mean the .dcr did not reach the design package; that is cosmetic, see
   the .dcr section at the end.

3. Under VCL, three things come from VirtualTreesReg and are worth a look:
   double click the tree to open the column collection editor; select
   ClipboardFormats in the Object Inspector and expand it, to see the formats
   as checkable subproperties; and drop a TActionList, double click it, and
   look for the category "VirtualTree".

   Under FMX only the two components are registered, so none of that applies.

4. Compile and run that form once. A design package that loads is not proof
   that an application using the components links.

   Dropping a tree on a form makes the IDE write the library's units into the
   form's uses clause, and the compiler then has to find them. A build that
   stops with

       F2613 Unit 'VirtualTrees.BaseAncestorFMX' not found

   means the Source folder is not on the Library path for the platform being
   built. That path is kept per platform, so it has to be added separately for
   Win32, Win64 and Android64 - adding it for Win32 alone leaves the other two
   failing exactly like this. This is step 1 of Installing, and it is the step
   that is easiest to skip, because everything up to the first compile works
   without it.


Uninstalling
------------

1. Component > Install Packages.
2. Select "Virtual TreeView components" in the list and click Remove.
3. Close the IDE.
4. Optionally delete the built .bpl and .dcp files. The IDE writes them to
   the public BPL folder, normally:

       C:\Users\Public\Documents\Embarcadero\Studio\23.0\Bpl
       C:\Users\Public\Documents\Embarcadero\Studio\23.0\Dcp

5. Remove the Source folder from the Library path if you no longer want it
   there.

To switch frameworks, uninstall one design package before installing the
other. The runtime packages do not conflict and may both stay built.


Using the source directly (recommended)
---------------------------------------

Nothing forces you to install anything. Add the Source folder to your
project's search path, list the units in the project's uses clause, and
create the tree in code. This avoids the VCL/FMX conflict completely, keeps
each project pinned to the source you tested it against, and means no BPL
has to be shipped or version-matched.

The two demo projects do it this way; look at their .dpr files to see the
unit lists for each framework.

No conditional defines are needed, for either framework. RAD Studio defines
FRAMEWORK_FMX by itself for a FireMonkey project, and every unit in the
library derives its own VT_FMX / VT_VCL switch from that, so the right half of
the source is selected for you.

(The two FMX package projects do carry FRAMEWORK_FMX in their conditional
defines. That is only because a package project is not an application, and it
costs nothing: the symbol is already set for FireMonkey projects, so defining
it again is a no-op. Do not copy that into your own projects.)


VirtualTreesReg.pas
-------------------

The unit is shared by both frameworks. It selects its framework the same way
every other unit in this library does:

    {$IFDEF FRAMEWORK_FMX}
      {$DEFINE VT_FMX}
    {$ELSE}
      {$DEFINE VT_VCL}
    {$ENDIF}

So the same file produces the FMX registration in the FMX design package and
the VCL registration in the VCL design package. Do not add the unit to a
runtime package or to an application - it uses DesignIntf and will drag the
design-time IDE units in with it.

Under VCL it registers:

  - TVirtualStringTree and TVirtualDrawTree on the "Virtual Controls" page
  - a component editor that opens the column collection on double click
  - a property editor that shows ClipboardFormats as checkable subproperties
  - the standard actions from VirtualTrees.Actions (Check All, Uncheck All,
    Select All, Copy, Cut, Paste, Delete), which appear in the action list
    editor under the category "VirtualTree"
  - property categories, so the Object Inspector groups the tree's ~200
    published properties sensibly

Under FMX it registers the two components only. The property editors depend
on VCL design-time units that have no FireMonkey equivalent.


VirtualTrees.dcr - the palette icons
------------------------------------

A .dcr is nothing special: it is an ordinary compiled Windows resource file
(.res) that has simply been renamed. It holds one bitmap per component, and
the resource name must be the component's class name in upper case:

    TVIRTUALSTRINGTREE
    TVIRTUALDRAWTREE

The file already here works. You only need the following if you want to
change an icon or add one for a new component.

1. Draw the bitmaps. One per component, 24x24 pixels. Windows Paint is
   enough - set Image > Attributes to 24 x 24 and save as 16 Color Bitmap.
   The bottom-left pixel's colour is treated as transparent, so paint the
   background in a colour you do not use in the icon itself; clFuchsia
   (255,0,255) is the usual choice. Save them next to this file as, say,
   vst.bmp and vdt.bmp.

2. Write a plain text file VirtualTrees.rc containing one line per icon:

       TVIRTUALSTRINGTREE BITMAP "vst.bmp"
       TVIRTUALDRAWTREE   BITMAP "vdt.bmp"

   The name on the left is what matters - it must match the class name,
   upper case, no quotes.

3. Compile it with the resource compiler that ships with RAD Studio. From a
   command prompt in this folder:

       "%BDS%\bin\brcc32.exe" -foVirtualTrees.res VirtualTrees.rc

   If %BDS% is not set, the path is normally
   C:\Program Files (x86)\Embarcadero\Studio\23.0\bin\brcc32.exe

4. Rename the result:

       ren VirtualTrees.res VirtualTrees.dcr

5. Rebuild and reinstall the design package. The .rc and the .bmp files are
   only build inputs; the .dcr is the only file the package needs.

If your RAD Studio installation still has Tools > Image Editor, that does the
same job interactively: File > New > Component Resource, add a 24x24 bitmap,
rename the resource to the upper-case class name, save as .dcr. It was
dropped from recent versions, which is why the command-line route is given
first here.

The design packages link the file with

    {$R 'VirtualTrees.dcr'}

so a new .dcr takes effect on the next rebuild of the design package. If a
component has no matching resource the IDE just draws a default icon - a
missing or wrong .dcr is cosmetic, never a build error, and that is also why
a mistyped resource name fails silently.
