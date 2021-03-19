
# MSOA <-> Westminster Constituency lookup

(England and Wales only)

### Some premises:

* All Wards nest completely within LA boundaries
* All MSOAs nest completely within LA boundaries
* (alt to a and b: no Ward or MSOA is split between more than 1 LA)
* All Wards nest completely within Constituency boundaries
* However, many MSOAs _do not_ sit neatly within Constituency boundaries

### Motivation

[The House of Commons Library][hocl-bb] provides Constituency:MSOA data downloads, [for example for broadband data (xlsx link)][hocl-xl].

This provides an excellent _constituency-centric_ interface to all sorts of datasets.
The broadband data linked above shows **7,989** rows of Constituency:MSOA overlaps in England and Wales.
I think that means that is what I should end up with here as well?
(Yes I realise I could just copy those columns over and I'd basically be done, but I'm hoping for a little more added value and a little more learning for myself in doing it this way.)

[hocl-bb]: https://commonslibrary.parliament.uk/constituency-data-broadband-coverage-and-speeds/
[hocl-xl]: https://data.parliament.uk/resources/constituencystatistics/Broadband-speeds-2020.xlsx



But if you want to access their datasets from the perspective of a set of MSOAs within an LA, it's harder to know how to get the data you want.
Many MSOAs contain part of more than 1 constituency*.


\* I suspected that no MSOA contained part of more than 2 constituencies, but there is at least one that does: E02000217 _Croydon Minster & Waddon North_ contains parts of Croydon Central, Croydon North and Croydon South.
There may be others... OK there's quite a few, including:

* E02000291 _Enfield Town South & Bush Hill Park_ contains parts of Edmonton, Enfield North and Enfield, Southgate [3]
* E02001370 _Everton East_: Liverpool, Walton; Liverpool, Wavertree; Liverpool, West Derby [3]
* E02006852 _Far Headingley & Weetwood_: Leeds North East, Leeds North West and Leeds West [3]
* and more to come.

This repo aims to provide a lookup for MSOA to LA to Constituency to Region.

_(An aside: I wonder if, or how many, constituencies cross a regional border.
For sanity's sake, I kind of hope that none does, but it's possible in theory — they can cross lower-tier authority boundaries so I'm pretty sure they could cross upper tier authority boundaries too... and then anything's possible :wink:)_

The lookup will provide a % figure for the area of an MSOA that is within any constituency it overlaps.
This will also enable a best-fit approach — where an MSOA is allocated to a single constituency which has the greatest part of its area — or alternatively the filtering out of small % overlaps as negligible.

