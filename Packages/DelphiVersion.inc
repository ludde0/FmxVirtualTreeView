// Which RAD Studio these package projects are set up for, and which library suffix belongs to it.
//
// The suffix is written into {$LIBSUFFIX} in each .dpk and <DllSuffix> in each .dproj. It is a
// string literal in both places, so the compiler cannot compare it against anything - which is
// why it is repeated here as a symbol, which the compiler can.
//
// A suffix that does not belong to the compiler building it fails nowhere useful: the packages
// compile, and the design package then asks the IDE for a runtime BPL under a name that was
// never built - "Can't load package ...370.bpl", which says nothing about why. The test below
// catches both halves of that: a RAD Studio nobody has built these with, and a RAD Studio that
// is fine but carrying a suffix meant for a different one.
//
// Included by all four .dpk files, so this is the only place either number is stated.
//
// PatchPackagesForDelphi writes the VT_SUFFIX_ line, and adds a version line when it patches.
//
// The test is built from {$IFDEF} rather than a comparison on CompilerVersion. Inside a package
// header a directive of the form {$IF <expression>} is not evaluated - it is rejected with
// "E2026 Constant expression expected" whatever the expression says - while {$IFDEF} and
// {$MESSAGE} work normally. The {$MESSAGE} text is an ordinary string literal, so it has to stay
// under 256 characters.
//
// To add a RAD Studio by hand: build the packages with it, then add one line to the list below.
// Delphi 12 is VER360 and Delphi 13 is VER370; each release numbers ten higher than the one
// before it.

{$DEFINE VT_SUFFIX_370}

{$DEFINE VT_WRONG_DELPHI}

// One line per RAD Studio, pairing it with the library suffix that belongs to it.
{$IFDEF VER360}{$IFDEF VT_SUFFIX_290}{$UNDEF VT_WRONG_DELPHI}{$ENDIF}{$ENDIF}   // RAD Studio 12
{$IFDEF VER370}{$IFDEF VT_SUFFIX_370}{$UNDEF VT_WRONG_DELPHI}{$ENDIF}{$ENDIF}   // RAD Studio 13

{$IFDEF VT_WRONG_DELPHI}
  {$MESSAGE FATAL 'The library suffix these packages carry does not belong to the RAD Studio building them. Run PatchPackagesForDelphi.exe in the Packages folder, then read README FIRST - OTHER DELPHI VERSIONS.txt'}
{$ENDIF}
