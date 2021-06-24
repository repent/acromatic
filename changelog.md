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