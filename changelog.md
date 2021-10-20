# 10/21

Refactor the hellhole that is trawl, based around .each_acronym
Add some more complex tests to document_test.rb
Changed PATTERN to capture singular as a[0], aligning with the comments

# 6/21

Added pandoc as a parser, which can use .odt but not much else of use (not PDF or RTF, both of which it can write).

# 6/21

No longer catch hyphens in or at the end under any circumstances -- it wasn't working anyway and is questionable whether it should (lots of ambiguous cases).  (#40)

# 4/17

Fix #4, files with .DOCX extension failed with UTF-8 error

# 3/17

Add dictionaries and definitions
Add single-user mode using devise (email config not sorted and can't be public)

# 2/17

Add support for 2-letter acronyms
Fix accidental inclusion of numbers, e.g. 2016

# History of PATTERN

## Retired on 15.6.21:

Because: it matches R[E
PATTERN = /[\W]([A-Z][A-z0-9&-+]*[A-Z0-9+-](s)?)[\W]/ # liberal, 2-letter minimum,

## Retired on 15.6.21:

Because: it matches Australia-
PATTERN = /[\W]([A-Z][a-zA-Z0-9&-+]*[A-Z0-9+-](s)?)[\W]/ # liberal, 2-letter minimum,

## Failing on 24.6.21:

Because: IS-LM shows up as "IS" and "LM" separately
PATTERN = /[\W]([A-Z][a-zA-Z0-9&-+]*[A-Z][0-9+-]?(s)?)[\W]/ # liberal, 2-letter minimum, must
start with letter and have another capital before the end junk

## Retired on 20.10.21:

Because: refactoring is using named acronyms and finding the plural as ac[0] as documented
24.6.21: Hyphen has been cut out completely, inside and at end
so IS-LM picks up IS and LM separately
PATTERN = /[\W]([A-Z][a-zA-Z0-9\&\+]*[A-Z][0-9\+]*(s)?)[\W]/ # liberal, 2-letter minimum,
must start with letter and have another capital before the "end junk", which can only contain numbers/pluses (to avoid camelcase)
