# SPATIALLY
## An OGS compliant GIS library for Dart

### Overview

Intended as a port of a large subset of the *JTS* library functionality, so that
web applications may benefit from access to a full suite of spatial algorithms an
opertions. A full port was not desirable, as many of the extensibility options of
*JTS* were redundant and an aim to reduce exported file size was a goal of the project

## Usage

All basic utility functions are exported via 

     'package:spatially/spatially.dart'
     
which provides implementations for the standard 
* `Point`
* `Linestring`
* `Polygon`
* `MultiPoint`
* `MultiLinestring`
* `MultiPolygon`
* `GeometryList`

GeoJSON and WKT conversion from spatially geometries is available in
     'package:spatially/convert/convert.dart'
     
And most more advanced operations supported by *JTS* are exported via the 
various `spatially` modules.
