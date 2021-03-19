
# MSOA <-> Westminster Constituency lookup

(England and Wales only)

### Some premises:

* All Wards nest completely within LA boundaries
* All MSOAs nest completely within LA boundaries
* (alt to a and b: no Ward or MSOA is split between more than 1 LA)
* All Wards nest completely within Constituency boundaries
* However, many MSOAs _do not_ nest within Constituency boundaries

### Motivation

[The House of Commons Library][hocl-bb] provides Constituency:MSOA data downloads, [for example for broadband data (xlsx link)][hocl-xl].

This provides an excellent _constituency-centric_ interface to all sorts of datasets.

[hocl-bb]: https://commonslibrary.parliament.uk/constituency-data-broadband-coverage-and-speeds/
[hocl-xl]: https://data.parliament.uk/resources/constituencystatistics/Broadband-speeds-2020.xlsx



But if you want to access their datasets from the perspective of a set of MSOAs within an LA, it's harder to know how to get the data you want.
Many MSOAs contain part of more than 1 constituency*.


\* I suspected no MSOA contained part of more than 2 constituencies, but there is at least one that does: E02000217 Croydon Minster & Waddon North contains parts of Croydon Central, Croydon North and Croydon South.
There may be others.

E02000291 Enfield Town South & Bush Hill Park contains parts of Edmonton, Enfield North and Enfield, Southgate.

E02001370 Everton East: Liverpool, Walton; Liverpool, Wavertree; Liverpool, West Derby.

E02006852 Far Headingley & Weetwood: Leeds North East, Leeds North West and Leeds West.

OK there's quite a few.

This repo aims to provide a lookup for MSOA to LA to Constituency to Region.

_(An aside: I wonder if, or how many, constituencies cross a regional border.
I kind of hope that none does, but it's certainly possible in theory — I'm pretty sure they can cross upper tier authority boundaries.)_

The lookup will provide a % figure for the area of an MSOA that is within any constituency it overlaps.
This will enable a best-fit approach — where an MSOA is allocated to a single constituency which has the greatest part of its area — or alternatively the filtering out of small % overlaps as negligible.

