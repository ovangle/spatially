part of geometry_tests;

final lstr1 = new Linestring();
final lstr2 = new Linestring([new Point(x: 0.0, y: 0.0)]);
final lstr3 = new Linestring([new Point(x: 1.0, y: 0.0),
                              new Point(x: 0.0, y: 0.0),
                              new Point(x: 0.0, y: 1.0),
                              new Point(x: 1.0, y: 1.0)]);
final lstr4 = new Linestring([new Point(x: 0.5, y: 0.5), 
                              new Point(x: 1.0, y: 0.0), 
                              new Point(x: 0.0, y: 0.0),
                              new Point(x: 0.0, y: 1.0)]);
final lstr5 = new Linestring([new Point(x: 0.0, y: 0.25),
                              new Point(x: 0.75, y: 1.0),
                              new Point(x: 0.0, y: 1.0)]);