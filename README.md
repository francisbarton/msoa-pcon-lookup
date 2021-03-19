
# MSOA <-> Westminster Constituency lookup

(England and Wales only)

## Premises:

a. All Wards nest completely within LA boundaries
b. All MSOAs nest completely within LA boundaries
c. (alt to a and b: no Ward or MSOA is split between more than 1 LA)
d. All Wards nest completely within Constituency boundaries
e. However, many MSOAs _do not_ nest within Constituency boundaries

[The House of Commons Library][hocl-bb] provides Constituency:MSOA data downloads, [for example for broadband data (xlsx link)][hocl-xl].

This provides an excellent _constituency-centric_ interface to all sorts of datasets.

[hocl-bb]: https://commonslibrary.parliament.uk/constituency-data-broadband-coverage-and-speeds/
[hocl-xl]: https://data.parliament.uk/resources/constituencystatistics/Broadband-speeds-2020.xlsx



But if you want to access their datasets from the perspective of a set of MSOAs within an LA, it's harder to know how to get the data you want.
Many MSOAs contain part of more than 1 (but never, I think, more than 2) constituenc[y|ies].

This repo aims to provide a lookup for MSOA to LA to Constituency to Region.

(An aside: I wonder if, or how many, constituencies cross a regional border.
I kind of hope that none does, but it's certainly possible in theory — I'm pretty sure they can cross upper tier authority boundaries.)

The lookup will provide a % figure for the area of an MSOA that is within any constituency it overlaps.
This will enable a best-fit approach — where an MSOA is allocated to a single constituency which has the greatest part of its area — or alternatively the filtering out of small % overlaps as negligible.

