/*
    This file is part of the Nebula distribution.

    https://github.com/senselogic/NEBULA

    Copyright (C) 2021 Eric Pelzer (ecstatic.coder@gmail.com)

    Nebula is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3.

    Nebula is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Nebula.  If not, see <http://www.gnu.org/licenses/>.
*/

// -- IMPORTS

import core.stdc.stdlib : exit;
import std.conv : to;
import std.file : write;
import std.math : cos, floor, sin, PI;
import std.stdio : readln, writeln, File;
import std.string : format, indexOf, split, startsWith, strip;

// -- CONSTANTS

enum
    CellXShift = 0,
    CellYShift = 20,
    CellZShift = 40,
    CellShift = 20,
    CellBasis = 1 << ( CellShift - 1 ),
    CellMask = ( 1 << CellShift ) - 1,
    DegreeToRadianFactor = PI / 180.0;
const long[][]
    EdgePointIndexArrayArray =
    [
        [],
        [ 0, 8, 3 ],
        [ 0, 1, 9 ],
        [ 1, 8, 3, 9, 8, 1 ],
        [ 1, 2, 10 ],
        [ 0, 8, 3, 1, 2, 10 ],
        [ 9, 2, 10, 0, 2, 9 ],
        [ 2, 8, 3, 2, 10, 8, 10, 9, 8 ],
        [ 3, 11, 2 ],
        [ 0, 11, 2, 8, 11, 0 ],
        [ 1, 9, 0, 2, 3, 11 ],
        [ 1, 11, 2, 1, 9, 11, 9, 8, 11 ],
        [ 3, 10, 1, 11, 10, 3 ],
        [ 0, 10, 1, 0, 8, 10, 8, 11, 10 ],
        [ 3, 9, 0, 3, 11, 9, 11, 10, 9 ],
        [ 9, 8, 10, 10, 8, 11 ],
        [ 4, 7, 8 ],
        [ 4, 3, 0, 7, 3, 4 ],
        [ 0, 1, 9, 8, 4, 7 ],
        [ 4, 1, 9, 4, 7, 1, 7, 3, 1 ],
        [ 1, 2, 10, 8, 4, 7 ],
        [ 3, 4, 7, 3, 0, 4, 1, 2, 10 ],
        [ 9, 2, 10, 9, 0, 2, 8, 4, 7 ],
        [ 2, 10, 9, 2, 9, 7, 2, 7, 3, 7, 9, 4 ],
        [ 8, 4, 7, 3, 11, 2 ],
        [ 11, 4, 7, 11, 2, 4, 2, 0, 4 ],
        [ 9, 0, 1, 8, 4, 7, 2, 3, 11 ],
        [ 4, 7, 11, 9, 4, 11, 9, 11, 2, 9, 2, 1 ],
        [ 3, 10, 1, 3, 11, 10, 7, 8, 4 ],
        [ 1, 11, 10, 1, 4, 11, 1, 0, 4, 7, 11, 4 ],
        [ 4, 7, 8, 9, 0, 11, 9, 11, 10, 11, 0, 3 ],
        [ 4, 7, 11, 4, 11, 9, 9, 11, 10 ],
        [ 9, 5, 4 ],
        [ 9, 5, 4, 0, 8, 3 ],
        [ 0, 5, 4, 1, 5, 0 ],
        [ 8, 5, 4, 8, 3, 5, 3, 1, 5 ],
        [ 1, 2, 10, 9, 5, 4 ],
        [ 3, 0, 8, 1, 2, 10, 4, 9, 5 ],
        [ 5, 2, 10, 5, 4, 2, 4, 0, 2 ],
        [ 2, 10, 5, 3, 2, 5, 3, 5, 4, 3, 4, 8 ],
        [ 9, 5, 4, 2, 3, 11 ],
        [ 0, 11, 2, 0, 8, 11, 4, 9, 5 ],
        [ 0, 5, 4, 0, 1, 5, 2, 3, 11 ],
        [ 2, 1, 5, 2, 5, 8, 2, 8, 11, 4, 8, 5 ],
        [ 10, 3, 11, 10, 1, 3, 9, 5, 4 ],
        [ 4, 9, 5, 0, 8, 1, 8, 10, 1, 8, 11, 10 ],
        [ 5, 4, 0, 5, 0, 11, 5, 11, 10, 11, 0, 3 ],
        [ 5, 4, 8, 5, 8, 10, 10, 8, 11 ],
        [ 9, 7, 8, 5, 7, 9 ],
        [ 9, 3, 0, 9, 5, 3, 5, 7, 3 ],
        [ 0, 7, 8, 0, 1, 7, 1, 5, 7 ],
        [ 1, 5, 3, 3, 5, 7 ],
        [ 9, 7, 8, 9, 5, 7, 10, 1, 2 ],
        [ 10, 1, 2, 9, 5, 0, 5, 3, 0, 5, 7, 3 ],
        [ 8, 0, 2, 8, 2, 5, 8, 5, 7, 10, 5, 2 ],
        [ 2, 10, 5, 2, 5, 3, 3, 5, 7 ],
        [ 7, 9, 5, 7, 8, 9, 3, 11, 2 ],
        [ 9, 5, 7, 9, 7, 2, 9, 2, 0, 2, 7, 11 ],
        [ 2, 3, 11, 0, 1, 8, 1, 7, 8, 1, 5, 7 ],
        [ 11, 2, 1, 11, 1, 7, 7, 1, 5 ],
        [ 9, 5, 8, 8, 5, 7, 10, 1, 3, 10, 3, 11 ],
        [ 5, 7, 0, 5, 0, 9, 7, 11, 0, 1, 0, 10, 11, 10, 0 ],
        [ 11, 10, 0, 11, 0, 3, 10, 5, 0, 8, 0, 7, 5, 7, 0 ],
        [ 11, 10, 5, 7, 11, 5 ],
        [ 10, 6, 5 ],
        [ 0, 8, 3, 5, 10, 6 ],
        [ 9, 0, 1, 5, 10, 6 ],
        [ 1, 8, 3, 1, 9, 8, 5, 10, 6 ],
        [ 1, 6, 5, 2, 6, 1 ],
        [ 1, 6, 5, 1, 2, 6, 3, 0, 8 ],
        [ 9, 6, 5, 9, 0, 6, 0, 2, 6 ],
        [ 5, 9, 8, 5, 8, 2, 5, 2, 6, 3, 2, 8 ],
        [ 2, 3, 11, 10, 6, 5 ],
        [ 11, 0, 8, 11, 2, 0, 10, 6, 5 ],
        [ 0, 1, 9, 2, 3, 11, 5, 10, 6 ],
        [ 5, 10, 6, 1, 9, 2, 9, 11, 2, 9, 8, 11 ],
        [ 6, 3, 11, 6, 5, 3, 5, 1, 3 ],
        [ 0, 8, 11, 0, 11, 5, 0, 5, 1, 5, 11, 6 ],
        [ 3, 11, 6, 0, 3, 6, 0, 6, 5, 0, 5, 9 ],
        [ 6, 5, 9, 6, 9, 11, 11, 9, 8 ],
        [ 5, 10, 6, 4, 7, 8 ],
        [ 4, 3, 0, 4, 7, 3, 6, 5, 10 ],
        [ 1, 9, 0, 5, 10, 6, 8, 4, 7 ],
        [ 10, 6, 5, 1, 9, 7, 1, 7, 3, 7, 9, 4 ],
        [ 6, 1, 2, 6, 5, 1, 4, 7, 8 ],
        [ 1, 2, 5, 5, 2, 6, 3, 0, 4, 3, 4, 7 ],
        [ 8, 4, 7, 9, 0, 5, 0, 6, 5, 0, 2, 6 ],
        [ 7, 3, 9, 7, 9, 4, 3, 2, 9, 5, 9, 6, 2, 6, 9 ],
        [ 3, 11, 2, 7, 8, 4, 10, 6, 5 ],
        [ 5, 10, 6, 4, 7, 2, 4, 2, 0, 2, 7, 11 ],
        [ 0, 1, 9, 4, 7, 8, 2, 3, 11, 5, 10, 6 ],
        [ 9, 2, 1, 9, 11, 2, 9, 4, 11, 7, 11, 4, 5, 10, 6 ],
        [ 8, 4, 7, 3, 11, 5, 3, 5, 1, 5, 11, 6 ],
        [ 5, 1, 11, 5, 11, 6, 1, 0, 11, 7, 11, 4, 0, 4, 11 ],
        [ 0, 5, 9, 0, 6, 5, 0, 3, 6, 11, 6, 3, 8, 4, 7 ],
        [ 6, 5, 9, 6, 9, 11, 4, 7, 9, 7, 11, 9 ],
        [ 10, 4, 9, 6, 4, 10 ],
        [ 4, 10, 6, 4, 9, 10, 0, 8, 3 ],
        [ 10, 0, 1, 10, 6, 0, 6, 4, 0 ],
        [ 8, 3, 1, 8, 1, 6, 8, 6, 4, 6, 1, 10 ],
        [ 1, 4, 9, 1, 2, 4, 2, 6, 4 ],
        [ 3, 0, 8, 1, 2, 9, 2, 4, 9, 2, 6, 4 ],
        [ 0, 2, 4, 4, 2, 6 ],
        [ 8, 3, 2, 8, 2, 4, 4, 2, 6 ],
        [ 10, 4, 9, 10, 6, 4, 11, 2, 3 ],
        [ 0, 8, 2, 2, 8, 11, 4, 9, 10, 4, 10, 6 ],
        [ 3, 11, 2, 0, 1, 6, 0, 6, 4, 6, 1, 10 ],
        [ 6, 4, 1, 6, 1, 10, 4, 8, 1, 2, 1, 11, 8, 11, 1 ],
        [ 9, 6, 4, 9, 3, 6, 9, 1, 3, 11, 6, 3 ],
        [ 8, 11, 1, 8, 1, 0, 11, 6, 1, 9, 1, 4, 6, 4, 1 ],
        [ 3, 11, 6, 3, 6, 0, 0, 6, 4 ],
        [ 6, 4, 8, 11, 6, 8 ],
        [ 7, 10, 6, 7, 8, 10, 8, 9, 10 ],
        [ 0, 7, 3, 0, 10, 7, 0, 9, 10, 6, 7, 10 ],
        [ 10, 6, 7, 1, 10, 7, 1, 7, 8, 1, 8, 0 ],
        [ 10, 6, 7, 10, 7, 1, 1, 7, 3 ],
        [ 1, 2, 6, 1, 6, 8, 1, 8, 9, 8, 6, 7 ],
        [ 2, 6, 9, 2, 9, 1, 6, 7, 9, 0, 9, 3, 7, 3, 9 ],
        [ 7, 8, 0, 7, 0, 6, 6, 0, 2 ],
        [ 7, 3, 2, 6, 7, 2 ],
        [ 2, 3, 11, 10, 6, 8, 10, 8, 9, 8, 6, 7 ],
        [ 2, 0, 7, 2, 7, 11, 0, 9, 7, 6, 7, 10, 9, 10, 7 ],
        [ 1, 8, 0, 1, 7, 8, 1, 10, 7, 6, 7, 10, 2, 3, 11 ],
        [ 11, 2, 1, 11, 1, 7, 10, 6, 1, 6, 7, 1 ],
        [ 8, 9, 6, 8, 6, 7, 9, 1, 6, 11, 6, 3, 1, 3, 6 ],
        [ 0, 9, 1, 11, 6, 7 ],
        [ 7, 8, 0, 7, 0, 6, 3, 11, 0, 11, 6, 0 ],
        [ 7, 11, 6 ],
        [ 7, 6, 11 ],
        [ 3, 0, 8, 11, 7, 6 ],
        [ 0, 1, 9, 11, 7, 6 ],
        [ 8, 1, 9, 8, 3, 1, 11, 7, 6 ],
        [ 10, 1, 2, 6, 11, 7 ],
        [ 1, 2, 10, 3, 0, 8, 6, 11, 7 ],
        [ 2, 9, 0, 2, 10, 9, 6, 11, 7 ],
        [ 6, 11, 7, 2, 10, 3, 10, 8, 3, 10, 9, 8 ],
        [ 7, 2, 3, 6, 2, 7 ],
        [ 7, 0, 8, 7, 6, 0, 6, 2, 0 ],
        [ 2, 7, 6, 2, 3, 7, 0, 1, 9 ],
        [ 1, 6, 2, 1, 8, 6, 1, 9, 8, 8, 7, 6 ],
        [ 10, 7, 6, 10, 1, 7, 1, 3, 7 ],
        [ 10, 7, 6, 1, 7, 10, 1, 8, 7, 1, 0, 8 ],
        [ 0, 3, 7, 0, 7, 10, 0, 10, 9, 6, 10, 7 ],
        [ 7, 6, 10, 7, 10, 8, 8, 10, 9 ],
        [ 6, 8, 4, 11, 8, 6 ],
        [ 3, 6, 11, 3, 0, 6, 0, 4, 6 ],
        [ 8, 6, 11, 8, 4, 6, 9, 0, 1 ],
        [ 9, 4, 6, 9, 6, 3, 9, 3, 1, 11, 3, 6 ],
        [ 6, 8, 4, 6, 11, 8, 2, 10, 1 ],
        [ 1, 2, 10, 3, 0, 11, 0, 6, 11, 0, 4, 6 ],
        [ 4, 11, 8, 4, 6, 11, 0, 2, 9, 2, 10, 9 ],
        [ 10, 9, 3, 10, 3, 2, 9, 4, 3, 11, 3, 6, 4, 6, 3 ],
        [ 8, 2, 3, 8, 4, 2, 4, 6, 2 ],
        [ 0, 4, 2, 4, 6, 2 ],
        [ 1, 9, 0, 2, 3, 4, 2, 4, 6, 4, 3, 8 ],
        [ 1, 9, 4, 1, 4, 2, 2, 4, 6 ],
        [ 8, 1, 3, 8, 6, 1, 8, 4, 6, 6, 10, 1 ],
        [ 10, 1, 0, 10, 0, 6, 6, 0, 4 ],
        [ 4, 6, 3, 4, 3, 8, 6, 10, 3, 0, 3, 9, 10, 9, 3 ],
        [ 10, 9, 4, 6, 10, 4 ],
        [ 4, 9, 5, 7, 6, 11 ],
        [ 0, 8, 3, 4, 9, 5, 11, 7, 6 ],
        [ 5, 0, 1, 5, 4, 0, 7, 6, 11 ],
        [ 11, 7, 6, 8, 3, 4, 3, 5, 4, 3, 1, 5 ],
        [ 9, 5, 4, 10, 1, 2, 7, 6, 11 ],
        [ 6, 11, 7, 1, 2, 10, 0, 8, 3, 4, 9, 5 ],
        [ 7, 6, 11, 5, 4, 10, 4, 2, 10, 4, 0, 2 ],
        [ 3, 4, 8, 3, 5, 4, 3, 2, 5, 10, 5, 2, 11, 7, 6 ],
        [ 7, 2, 3, 7, 6, 2, 5, 4, 9 ],
        [ 9, 5, 4, 0, 8, 6, 0, 6, 2, 6, 8, 7 ],
        [ 3, 6, 2, 3, 7, 6, 1, 5, 0, 5, 4, 0 ],
        [ 6, 2, 8, 6, 8, 7, 2, 1, 8, 4, 8, 5, 1, 5, 8 ],
        [ 9, 5, 4, 10, 1, 6, 1, 7, 6, 1, 3, 7 ],
        [ 1, 6, 10, 1, 7, 6, 1, 0, 7, 8, 7, 0, 9, 5, 4 ],
        [ 4, 0, 10, 4, 10, 5, 0, 3, 10, 6, 10, 7, 3, 7, 10 ],
        [ 7, 6, 10, 7, 10, 8, 5, 4, 10, 4, 8, 10 ],
        [ 6, 9, 5, 6, 11, 9, 11, 8, 9 ],
        [ 3, 6, 11, 0, 6, 3, 0, 5, 6, 0, 9, 5 ],
        [ 0, 11, 8, 0, 5, 11, 0, 1, 5, 5, 6, 11 ],
        [ 6, 11, 3, 6, 3, 5, 5, 3, 1 ],
        [ 1, 2, 10, 9, 5, 11, 9, 11, 8, 11, 5, 6 ],
        [ 0, 11, 3, 0, 6, 11, 0, 9, 6, 5, 6, 9, 1, 2, 10 ],
        [ 11, 8, 5, 11, 5, 6, 8, 0, 5, 10, 5, 2, 0, 2, 5 ],
        [ 6, 11, 3, 6, 3, 5, 2, 10, 3, 10, 5, 3 ],
        [ 5, 8, 9, 5, 2, 8, 5, 6, 2, 3, 8, 2 ],
        [ 9, 5, 6, 9, 6, 0, 0, 6, 2 ],
        [ 1, 5, 8, 1, 8, 0, 5, 6, 8, 3, 8, 2, 6, 2, 8 ],
        [ 1, 5, 6, 2, 1, 6 ],
        [ 1, 3, 6, 1, 6, 10, 3, 8, 6, 5, 6, 9, 8, 9, 6 ],
        [ 10, 1, 0, 10, 0, 6, 9, 5, 0, 5, 6, 0 ],
        [ 0, 3, 8, 5, 6, 10 ],
        [ 10, 5, 6 ],
        [ 11, 5, 10, 7, 5, 11 ],
        [ 11, 5, 10, 11, 7, 5, 8, 3, 0 ],
        [ 5, 11, 7, 5, 10, 11, 1, 9, 0 ],
        [ 10, 7, 5, 10, 11, 7, 9, 8, 1, 8, 3, 1 ],
        [ 11, 1, 2, 11, 7, 1, 7, 5, 1 ],
        [ 0, 8, 3, 1, 2, 7, 1, 7, 5, 7, 2, 11 ],
        [ 9, 7, 5, 9, 2, 7, 9, 0, 2, 2, 11, 7 ],
        [ 7, 5, 2, 7, 2, 11, 5, 9, 2, 3, 2, 8, 9, 8, 2 ],
        [ 2, 5, 10, 2, 3, 5, 3, 7, 5 ],
        [ 8, 2, 0, 8, 5, 2, 8, 7, 5, 10, 2, 5 ],
        [ 9, 0, 1, 5, 10, 3, 5, 3, 7, 3, 10, 2 ],
        [ 9, 8, 2, 9, 2, 1, 8, 7, 2, 10, 2, 5, 7, 5, 2 ],
        [ 1, 3, 5, 3, 7, 5 ],
        [ 0, 8, 7, 0, 7, 1, 1, 7, 5 ],
        [ 9, 0, 3, 9, 3, 5, 5, 3, 7 ],
        [ 9, 8, 7, 5, 9, 7 ],
        [ 5, 8, 4, 5, 10, 8, 10, 11, 8 ],
        [ 5, 0, 4, 5, 11, 0, 5, 10, 11, 11, 3, 0 ],
        [ 0, 1, 9, 8, 4, 10, 8, 10, 11, 10, 4, 5 ],
        [ 10, 11, 4, 10, 4, 5, 11, 3, 4, 9, 4, 1, 3, 1, 4 ],
        [ 2, 5, 1, 2, 8, 5, 2, 11, 8, 4, 5, 8 ],
        [ 0, 4, 11, 0, 11, 3, 4, 5, 11, 2, 11, 1, 5, 1, 11 ],
        [ 0, 2, 5, 0, 5, 9, 2, 11, 5, 4, 5, 8, 11, 8, 5 ],
        [ 9, 4, 5, 2, 11, 3 ],
        [ 2, 5, 10, 3, 5, 2, 3, 4, 5, 3, 8, 4 ],
        [ 5, 10, 2, 5, 2, 4, 4, 2, 0 ],
        [ 3, 10, 2, 3, 5, 10, 3, 8, 5, 4, 5, 8, 0, 1, 9 ],
        [ 5, 10, 2, 5, 2, 4, 1, 9, 2, 9, 4, 2 ],
        [ 8, 4, 5, 8, 5, 3, 3, 5, 1 ],
        [ 0, 4, 5, 1, 0, 5 ],
        [ 8, 4, 5, 8, 5, 3, 9, 0, 5, 0, 3, 5 ],
        [ 9, 4, 5 ],
        [ 4, 11, 7, 4, 9, 11, 9, 10, 11 ],
        [ 0, 8, 3, 4, 9, 7, 9, 11, 7, 9, 10, 11 ],
        [ 1, 10, 11, 1, 11, 4, 1, 4, 0, 7, 4, 11 ],
        [ 3, 1, 4, 3, 4, 8, 1, 10, 4, 7, 4, 11, 10, 11, 4 ],
        [ 4, 11, 7, 9, 11, 4, 9, 2, 11, 9, 1, 2 ],
        [ 9, 7, 4, 9, 11, 7, 9, 1, 11, 2, 11, 1, 0, 8, 3 ],
        [ 11, 7, 4, 11, 4, 2, 2, 4, 0 ],
        [ 11, 7, 4, 11, 4, 2, 8, 3, 4, 3, 2, 4 ],
        [ 2, 9, 10, 2, 7, 9, 2, 3, 7, 7, 4, 9 ],
        [ 9, 10, 7, 9, 7, 4, 10, 2, 7, 8, 7, 0, 2, 0, 7 ],
        [ 3, 7, 10, 3, 10, 2, 7, 4, 10, 1, 10, 0, 4, 0, 10 ],
        [ 1, 10, 2, 8, 7, 4 ],
        [ 4, 9, 1, 4, 1, 7, 7, 1, 3 ],
        [ 4, 9, 1, 4, 1, 7, 0, 8, 1, 8, 7, 1 ],
        [ 4, 0, 3, 7, 4, 3 ],
        [ 4, 8, 7 ],
        [ 9, 10, 8, 10, 11, 8 ],
        [ 3, 0, 9, 3, 9, 11, 11, 9, 10 ],
        [ 0, 1, 10, 0, 10, 8, 8, 10, 11 ],
        [ 3, 1, 10, 11, 3, 10 ],
        [ 1, 2, 11, 1, 11, 9, 9, 11, 8 ],
        [ 3, 0, 9, 3, 9, 11, 1, 2, 9, 2, 11, 9 ],
        [ 0, 2, 11, 8, 0, 11 ],
        [ 3, 2, 11 ],
        [ 2, 3, 8, 2, 8, 10, 10, 8, 9 ],
        [ 9, 10, 2, 0, 9, 2 ],
        [ 2, 3, 8, 2, 8, 10, 0, 1, 8, 1, 10, 8 ],
        [ 1, 10, 2 ],
        [ 1, 3, 8, 9, 1, 8 ],
        [ 0, 9, 1 ],
        [ 0, 3, 8 ],
        []
    ];

// -- TYPE

struct VECTOR_3
{
    // -- ATTRIBUTES

    float
        X = 0.0f,
        Y = 0.0f,
        Z = 0.0f;

    // -- INQUIRIES

    long GetCellIndex(
        )
    {
        long
            cell_x_index,
            cell_y_index,
            cell_z_index;

        cell_x_index = CellBasis + ( X * OneOverCellSize ).floor().to!long();
        cell_y_index = CellBasis + ( Y * OneOverCellSize ).floor().to!long();
        cell_z_index = CellBasis + ( Z * OneOverCellSize ).floor().to!long();

        return
            ( cell_x_index << CellXShift )
            | ( cell_y_index << CellYShift )
            | ( cell_z_index << CellZShift );
    }

    // -- OPERATIONS

    void SetNull(
        )
    {
        X = 0.0;
        Y = 0.0;
        Z = 0.0;
    }

    // ~~

    void SetUnit(
        )
    {
        X = 1.0;
        Y = 1.0;
        Z = 1.0;
    }

    // ~~

    void AddVector(
        ref VECTOR_3 vector
        )
    {
        X += vector.X;
        Y += vector.Y;
        Z += vector.Z;
    }

    // ~~

    void MultiplyVector(
        ref VECTOR_3 vector
        )
    {
        X *= vector.X;
        Y *= vector.Y;
        Z *= vector.Z;
    }

    // ~~

    void MultiplyScalar(
        float scalar
        )
    {
        X *= scalar;
        Y *= scalar;
        Z *= scalar;
    }

    // ~~

    void SetAverageVector(
        ref VECTOR_3 first_vector,
        ref VECTOR_3 second_vector
        )
    {
        X = ( first_vector.X + second_vector.X ) * 0.5;
        Y = ( first_vector.Y + second_vector.Y ) * 0.5;
        Z = ( first_vector.Z + second_vector.Z ) * 0.5;
    }

    // ~~

    void Clip(
        ref VECTOR_3 minimum_vector,
        ref VECTOR_3 maximum_vector
        )
    {
        if ( X < minimum_vector.X )
        {
            X = minimum_vector.X;
        }

        if ( Y < minimum_vector.Y )
        {
            Y = minimum_vector.Y;
        }

        if ( Z < minimum_vector.Z )
        {
            Z = minimum_vector.Z;
        }

        if ( X > maximum_vector.X )
        {
            X = maximum_vector.X;
        }

        if ( Y > maximum_vector.Y )
        {
            Y = maximum_vector.Y;
        }

        if ( Z > maximum_vector.Z )
        {
            Z = maximum_vector.Z;
        }
    }

    // ~~

    void Translate(
        float x_translation,
        float y_translation,
        float z_translation
        )
    {
        X += x_translation;
        Y += y_translation;
        Z += z_translation;
    }

    // ~~

    void Scale(
        float x_scaling,
        float y_scaling,
        float z_scaling
        )
    {
        X *= x_scaling;
        Y *= y_scaling;
        Z *= z_scaling;
    }

    // ~~

    void RotateAroundX(
        float x_angle_cosinus,
        float x_angle_sinus
        )
    {
        float
            y;

        y = Y;
        Y = Y * x_angle_cosinus - Z * x_angle_sinus;
        Z = y * x_angle_sinus + Z * x_angle_cosinus;
    }

    // ~~

    void RotateAroundY(
        float y_angle_cosinus,
        float y_angle_sinus
        )
    {
        float
            x;

        x = X;
        X = X * y_angle_cosinus + Z * y_angle_sinus;
        Z = Z * y_angle_cosinus - x * y_angle_sinus;
    }

    // ~~

    void RotateAroundZ(
        float z_angle_cosinus,
        float z_angle_sinus
        )
    {
        float
            x,
            y;

        x = X;
        X = X * z_angle_cosinus - Y * z_angle_sinus;
        Y = x * z_angle_sinus + Y * z_angle_cosinus;
    }

    // ~~

    void SetFromCellIndex(
        long cell_index,
        float cell_offset
        )
    {
        long
            cell_x_index,
            cell_y_index,
            cell_z_index;

        cell_x_index = ( cell_index >> CellXShift ) & CellMask;
        cell_y_index = ( cell_index >> CellYShift ) & CellMask;
        cell_z_index = ( cell_index >> CellZShift ) & CellMask;

        X = ( ( cell_x_index - CellBasis ).to!float() + cell_offset ) * CellSize;
        Y = ( ( cell_y_index - CellBasis ).to!float() + cell_offset ) * CellSize;
        Z = ( ( cell_z_index - CellBasis ).to!float() + cell_offset ) * CellSize;
    }
}

// ~~

struct VECTOR_4
{
    // -- ATTRIBUTES

    float
        X = 0.0f,
        Y = 0.0f,
        Z = 0.0f,
        W = 0.0f;

    // -- OPERATIONS

    void SetNull(
        )
    {
        X = 0.0;
        Y = 0.0;
        Z = 0.0;
        W = 0.0;
    }

    // ~~

    void SetUnit(
        )
    {
        X = 1.0;
        Y = 1.0;
        Z = 1.0;
        W = 1.0;
    }

    // ~~

    void AddVector(
        ref VECTOR_4 vector
        )
    {
        X += vector.X;
        Y += vector.Y;
        Z += vector.Z;
        W += vector.W;
    }

    // ~~

    void MultiplyVector(
        ref VECTOR_4 vector
        )
    {
        X *= vector.X;
        Y *= vector.Y;
        Z *= vector.Z;
        W *= vector.W;
    }

    // ~~

    void MultiplyScalar(
        float scalar
        )
    {
        X *= scalar;
        Y *= scalar;
        Z *= scalar;
        W *= scalar;
    }

    // ~~

    void SetAverageVector(
        ref VECTOR_4 first_vector,
        ref VECTOR_4 second_vector
        )
    {
        X = ( first_vector.X + second_vector.X ) * 0.5;
        Y = ( first_vector.Y + second_vector.Y ) * 0.5;
        Z = ( first_vector.Z + second_vector.Z ) * 0.5;
        W = ( first_vector.W + second_vector.W ) * 0.5;
    }
}

// ~~

struct POINT
{
    // -- ATTRIBUTES

    VECTOR_3
        PositionVector;
    VECTOR_4
        ColorVector;

    // -- INQUIRIES

    long GetCellIndex(
        )
    {
        return PositionVector.GetCellIndex();
    }

    // -- OPERATIONS

    void SetNull(
        )
    {
        PositionVector.SetNull();
        ColorVector.SetNull();
    }

    // ~~

    void SetUnit(
        )
    {
        PositionVector.SetUnit();
        ColorVector.SetUnit();
    }

    // ~~

    void AddPoint(
        ref POINT point
        )
    {
        PositionVector.AddVector( point.PositionVector );
        ColorVector.AddVector( point.ColorVector );
    }

    // ~~

    void MultiplyPoint(
        ref POINT point
        )
    {
        PositionVector.MultiplyVector( point.PositionVector );
        ColorVector.MultiplyVector( point.ColorVector );
    }

    // ~~

    void MultiplyScalar(
        float factor
        )
    {
        PositionVector.MultiplyScalar( factor );
        ColorVector.MultiplyScalar( factor );
    }

    // ~~

    void SetFromCellIndex(
        long cell_index,
        float offset
        )
    {
        PositionVector.SetFromCellIndex( cell_index, offset );
    }

    // ~~

    void SetMiddlePoint(
        long cell_index
        )
    {
        PositionVector.SetFromCellIndex( cell_index, 0.5 );
    }

    // ~~

    void SetClippedPoint(
        long cell_index,
        float ratio
        )
    {
        VECTOR_3
            minimum_position_vector,
            maximum_position_vector;

        minimum_position_vector.SetFromCellIndex( cell_index, ratio );
        maximum_position_vector.SetFromCellIndex( cell_index, 1.0 - ratio );
        PositionVector.Clip( minimum_position_vector, maximum_position_vector );
    }

    // ~~

    void SetAveragePoint(
        ref POINT first_point,
        ref POINT second_point
        )
    {
        PositionVector.SetAverageVector( first_point.PositionVector, second_point.PositionVector );
        ColorVector.SetAverageVector( first_point.ColorVector, second_point.ColorVector );
    }
}

// ~~

class CLOUD
{
    // -- ATTRIBUTES

    POINT[]
        PointArray;

    // -- INQUIRIES

    void WriteXyzFile(
        string file_path
        )
    {
        File
            file;

        writeln( "Writing file : ", file_path );

        try
        {
            file.open( file_path, "w" );

            foreach ( ref point; PointArray )
            {
                file.write(
                    format(
                        "%.7f %.7f %.7f\n",
                        point.PositionVector.X,
                        point.PositionVector.Y,
                        point.PositionVector.Z
                        )
                    );
            }

            file.close();
        }
        catch ( Exception exception )
        {
            Abort( "Can't write file : " ~ file_path, exception );
        }
    }

    // ~~

    void WritePtsFile(
        string file_path
        )
    {
        File
            file;

        writeln( "Writing file : ", file_path );

        try
        {
            file.open( file_path, "w" );
            file.write( format( "%d\n", PointArray.length ) );

            foreach ( ref point; PointArray )
            {
                file.write(
                    format(
                        "%.7f %.7f %.7f %.7f %.7f %.7f %.7f\n",
                        point.PositionVector.X,
                        point.PositionVector.Y,
                        point.PositionVector.Z,
                        point.ColorVector.W,
                        point.ColorVector.X,
                        point.ColorVector.Y,
                        point.ColorVector.Z
                        )
                    );
            }

            file.close();
        }
        catch ( Exception exception )
        {
            Abort( "Can't write file : " ~ file_path, exception );
        }
    }


    // -- OPERATIONS

    void AddPoint(
        ref POINT point
        )
    {
        PointArray ~= point;
    }

    // ~~

    void ReadFile(
        string file_path,
        long skipped_line_count,
        long minimum_field_count,
        long maximum_field_count,
        string line_prefix,
        string line_format,
        ref POINT factor_point,
        ref POINT offset_point
        )
    {
        long
            b_field_index,
            i_field_index,
            g_field_index,
            r_field_index,
            x_field_index,
            y_field_index,
            z_field_index;
        string
            line;
        string[]
            field_array;
        File
            file;
        POINT
            point;

        x_field_index = line_format.indexOf( 'x' );
        y_field_index = line_format.indexOf( 'y' );
        z_field_index = line_format.indexOf( 'z' );
        r_field_index = line_format.indexOf( 'r' );
        g_field_index = line_format.indexOf( 'g' );
        b_field_index = line_format.indexOf( 'b' );
        i_field_index = line_format.indexOf( 'i' );

        writeln( "Reading file : ", file_path );

        try
        {
            file.open( file_path, "r" );

            foreach ( file_line; file.byLine() )
            {
                if ( skipped_line_count > 0 )
                {
                    --skipped_line_count;
                }
                else
                {
                    line = file_line.to!string().strip();

                    if ( line_prefix.length == 0
                         || line.startsWith( line_prefix ) )
                    {
                        field_array = line.split( ' ' );

                        if ( field_array.length >= minimum_field_count
                             && field_array.length <= maximum_field_count )
                        {
                            point.SetNull();

                            try
                            {
                                if ( x_field_index >= 0
                                     && x_field_index < field_array.length )
                                {
                                    point.PositionVector.X = field_array[ x_field_index ].to!float();
                                }

                                if ( y_field_index >= 0
                                     && y_field_index < field_array.length )
                                {
                                    point.PositionVector.Y = field_array[ y_field_index ].to!float();
                                }

                                if ( z_field_index >= 0
                                     && z_field_index < field_array.length )
                                {
                                    point.PositionVector.Z = field_array[ z_field_index ].to!float();
                                }

                                if ( r_field_index >= 0
                                     && r_field_index < field_array.length )
                                {
                                    point.ColorVector.X = field_array[ r_field_index ].to!float();
                                }

                                if ( g_field_index >= 0
                                     && g_field_index < field_array.length )
                                {
                                    point.ColorVector.Y = field_array[ g_field_index ].to!float();
                                }

                                if ( b_field_index >= 0
                                     && b_field_index < field_array.length )
                                {
                                    point.ColorVector.Z = field_array[ b_field_index ].to!float();
                                }

                                if ( i_field_index >= 0
                                     && i_field_index < field_array.length )
                                {
                                    point.ColorVector.W = field_array[ i_field_index ].to!float();
                                }

                                point.MultiplyPoint( factor_point );
                                point.AddPoint( offset_point );

                                AddPoint( point );
                            }
                            catch ( Exception exception )
                            {
                                Abort( "Can't read line : " ~ line );
                            }
                        }
                    }
                }
            }

            file.close();
        }
        catch ( Exception exception )
        {
            Abort( "Can't read file : " ~ file_path, exception );
        }
    }

    // ~~

    void ReadXyzFile(
        string file_path,
        ref POINT factor_point,
        ref POINT offset_point
        )
    {
        ReadFile( file_path, 0, 3, 3, "", "xyz", factor_point, offset_point );
    }

    // ~~

    void ReadPtsFile(
        string file_path,
        ref POINT factor_point,
        ref POINT offset_point
        )
    {
        ReadFile( file_path, 0, 3, 7, "", "xyzirgb", factor_point, offset_point );
    }

    // ~~

    void ReadObjFile(
        string file_path,
        ref POINT factor_point,
        ref POINT offset_point
        )
    {
        ReadFile( file_path, 0, 4, 7, "v ", "_xyzrgb", factor_point, offset_point );
    }

    // ~~

    void Translate(
        float x_translation,
        float y_translation,
        float z_translation
        )
    {
        foreach ( ref point; PointArray )
        {
            point.PositionVector.Translate( x_translation, y_translation, z_translation );
        }
    }

    // ~~

    void Scale(
        float x_scaling,
        float y_scaling,
        float z_scaling
        )
    {
        foreach ( ref point; PointArray )
        {
            point.PositionVector.Scale( x_scaling, y_scaling, z_scaling );
        }
    }

    // ~~

    void RotateAroundX(
        float x_rotation_angle
        )
    {
        float
            x_rotation_cosinus,
            x_rotation_sinus;

        x_rotation_cosinus = x_rotation_angle.cos();
        x_rotation_sinus = x_rotation_angle.sin();

        foreach ( ref point; PointArray )
        {
            point.PositionVector.RotateAroundX( x_rotation_cosinus, x_rotation_sinus );
        }
    }

    // ~~

    void RotateAroundY(
        float y_rotation_angle
        )
    {
        float
            y_rotation_cosinus,
            y_rotation_sinus;

        y_rotation_cosinus = y_rotation_angle.cos();
        y_rotation_sinus = y_rotation_angle.sin();

        foreach ( ref point; PointArray )
        {
            point.PositionVector.RotateAroundX( y_rotation_cosinus, y_rotation_sinus );
        }
    }

    // ~~

    void RotateAroundZ(
        float z_rotation_angle
        )
    {
        float
            z_rotation_cosinus,
            z_rotation_sinus;

        z_rotation_cosinus = z_rotation_angle.cos();
        z_rotation_sinus = z_rotation_angle.sin();

        foreach ( ref point; PointArray )
        {
            point.PositionVector.RotateAroundX( z_rotation_cosinus, z_rotation_sinus );
        }
    }
}

// ~~

struct CELL
{
    // -- ATTRIBUTES

    long
        Index,
        PointCount;
    POINT
        Point;

    // -- OPERATIONS

    void SetEmpty(
        long cell_index
        )
    {
        Index = cell_index;
        PointCount = 0;
        Point.SetMiddlePoint( cell_index );
    }

    // ~~

    void AddCell(
        ref CELL cell
        )
    {
        PointCount += cell.PointCount;
        Point.AddPoint( cell.Point );
    }

    // ~~

    void SetPoint(
        long cell_index,
        ref POINT point
        )
    {
        Index = cell_index;
        PointCount = 1;
        Point = point;
    }

    // ~~

    void AddPoint(
        ref POINT point
        )
    {
        ++PointCount;
        Point.AddPoint( point );
    }

    // ~~

    void SetMiddlePoint(
        )
    {
        Point.SetMiddlePoint( Index );
    }

    // ~~

    void SetClippedPoint(
        float ratio
        )
    {
        Point.SetClippedPoint( Index, ratio );
    }

    // ~~

    void SetAveragePoint(
        )
    {
        if ( PointCount > 1 )
        {
            Point.MultiplyScalar( 1.0 / PointCount.to!float() );
        }
    }
}

// ~~

class GRID
{
    // -- ATTRIBUTES

    CELL[ long ]
        CellMap;

    // -- INQUIRIES

    void GetCell(
        ref CELL cell,
        long cell_index
        )
    {
        CELL*
            found_cell;

        found_cell = cell_index in CellMap;

        if ( found_cell !is null )
        {
            cell = *found_cell;
        }
        else
        {
            cell.SetEmpty( cell_index );
        }
    }

    // ~~

    CLOUD GetCloud(
        )
    {
        CLOUD
            cloud;

        cloud = new CLOUD();

        foreach ( ref cell; CellMap.byValue )
        {
            if ( cell.PointCount > 0 )
            {
                cloud.AddPoint( cell.Point );
            }
        }

        return cloud;
    }

    // -- OPERATIONS

    void AddPoint(
        ref POINT point
        )
    {
        long
            cell_index;
        CELL
            cell;
        CELL*
            found_cell;

        cell_index = point.GetCellIndex();
        found_cell = cell_index in CellMap;

        if ( found_cell is null )
        {
            cell.SetPoint( cell_index, point );
            CellMap[ cell_index ] = cell;
        }
        else
        {
            found_cell.AddPoint( point );
        }
    }

    // ~~

    void AddEmptyCell(
        long cell_index
        )
    {
        long
            near_cell_index,
            x_offset,
            y_offset,
            z_offset;
        CELL
            cell;
        CELL*
            found_cell,
            found_near_cell;

        found_cell = cell_index in CellMap;

        if ( found_cell is null )
        {
            cell.SetEmpty( cell_index );

            for ( x_offset = -1;
                  x_offset <= 1;
                  ++x_offset )
            {
                for ( y_offset = -1;
                      y_offset <= 1;
                      ++y_offset )
                {
                    for ( z_offset = -1;
                          z_offset <= 1;
                          ++z_offset )
                    {
                        if ( x_offset != 0
                             || y_offset != 0
                             || z_offset != 0 )
                        {
                            near_cell_index = GetCellIndex( cell_index, x_offset, y_offset, z_offset );
                            found_near_cell = near_cell_index in CellMap;

                            if ( found_near_cell !is null
                                 && found_near_cell.PointCount > 0 )
                            {
                                cell.AddCell( *found_near_cell );
                            }
                        }
                    }
                }
            }

            cell.SetAveragePoint();
            cell.SetClippedPoint( 0.01 );
            cell.PointCount = 0;
            CellMap[ cell_index ] = cell;
        }
    }

    // ~~

    void AddEmptyCells(
        )
    {
        long
            x_offset,
            y_offset,
            z_offset;
        long[]
            cell_index_array;

        foreach ( cell_index; CellMap.byKey )
        {
            cell_index_array ~= cell_index;
        }

        foreach ( cell_index; cell_index_array )
        {
            for ( x_offset = -1;
                  x_offset <= 1;
                  ++x_offset )
            {
                for ( y_offset = -1;
                      y_offset <= 1;
                      ++y_offset )
                {
                    for ( z_offset = -1;
                          z_offset <= 1;
                          ++z_offset )
                    {
                        if ( x_offset != 0
                             || y_offset != 0
                             || z_offset != 0 )
                        {
                            AddEmptyCell( GetCellIndex( cell_index, x_offset, y_offset, z_offset ) );
                        }
                    }
                }
            }
        }
    }

    // ~~

    void SetFromCloud(
        CLOUD cloud
        )
    {
        foreach ( ref point; cloud.PointArray )
        {
            AddPoint( point );
        }

        foreach ( cell_index, ref cell; CellMap )
        {
            cell.SetAveragePoint();
        }

        AddEmptyCells();
    }
}

// ~~

struct CUBE
{
    // -- ATTRIBUTES

    CELL[ 8 ]
        CellArray;

    // -- INQUIRIES

    ulong GetCaseMask(
        )
    {
        ulong
            case_mask;

        case_mask = 0;

        if ( CellArray[ 0 ].PointCount > 0 )
        {
            case_mask |= 1;
        }

        if ( CellArray[ 4 ].PointCount > 0 )
        {
            case_mask |= 2;
        }

        if ( CellArray[ 5 ].PointCount > 0 )
        {
            case_mask |= 4;
        }

        if ( CellArray[ 1 ].PointCount > 0 )
        {
            case_mask |= 8;
        }

        if ( CellArray[ 2 ].PointCount > 0 )
        {
            case_mask |= 16;
        }

        if ( CellArray[ 6 ].PointCount > 0 )
        {
            case_mask |= 32;
        }

        if ( CellArray[ 7 ].PointCount > 0 )
        {
            case_mask |= 64;
        }

        if ( CellArray[ 3 ].PointCount > 0 )
        {
            case_mask |= 128;
        }

        return case_mask;
    }

    // ~~

    void GetEdgePoint(
        ref POINT edge_point,
        long first_cell_index,
        long second_cell_index
        )
    {
        edge_point.SetAveragePoint(
            CellArray[ first_cell_index ].Point,
            CellArray[ second_cell_index ].Point
            );
    }
}

// ~~

class MESH
{
    // -- ATTRIBUTES

    POINT[]
        PointArray;
    long[]
        PointIndexArray;
    long[ POINT ]
        PointIndexMap;

    // -- INQUIRIES

    CLOUD GetCloud(
        )
    {
        CLOUD
            cloud;

        cloud = new CLOUD();
        cloud.PointArray = PointArray;

        return cloud;
    }

    // ~~

    void WriteObjFile(
        string file_path,
        bool has_color
        )
    {
        long
            point_index_index;
        File
            file;

        writeln( "Writing file : ", file_path );

        try
        {
            file.open( file_path, "w" );

            if ( has_color )
            {
                foreach ( ref point; PointArray )
                {
                    file.write(
                        format(
                            "v %.7f %.7f %.7f %.7f %.7f %.7f %.7f\n",
                            point.PositionVector.X,
                            point.PositionVector.Y,
                            point.PositionVector.Z,
                            point.ColorVector.W,
                            point.ColorVector.X,
                            point.ColorVector.Y,
                            point.ColorVector.Z
                            )
                        );
                }
            }
            else
            {
                foreach ( ref point; PointArray )
                {
                    file.write(
                        format(
                            "v %.7f %.7f %.7f\n",
                            point.PositionVector.X,
                            point.PositionVector.Y,
                            point.PositionVector.Z
                            )
                        );
                }
            }

            if ( PointIndexArray.length > 0 )
            {
                for ( point_index_index = 0;
                      point_index_index < PointIndexArray.length;
                      point_index_index += 3 )
                {
                    file.write(
                        format(
                            "f %d %d %d\n",
                            PointIndexArray[ point_index_index ] + 1,
                            PointIndexArray[ point_index_index + 1 ] + 1,
                            PointIndexArray[ point_index_index + 2 ] + 1
                            )
                        );
                }
            }

            file.close();
        }
        catch ( Exception exception )
        {
            Abort( "Can't write file : " ~ file_path, exception );
        }
    }

    // -- OPERATIONS

    void AddPoint(
        ref POINT point
        )
    {
        long
            point_index;
        long*
            found_point_index;

        found_point_index = point in PointIndexMap;

        if ( found_point_index is null )
        {
            point_index = PointArray.length;
            PointArray ~= point;
            PointIndexMap[ point ] = point_index;
        }
        else
        {
            point_index = *found_point_index;
        }

        PointIndexArray ~= point_index;
    }

    // ~~

    void TriangulateCube(
        ref CUBE cube
        )
    {
        ulong
            case_mask;
        POINT[ 12 ]
            edge_point_array;

        case_mask = cube.GetCaseMask();

        cube.GetEdgePoint( edge_point_array[ 0 ], 0, 4 );
        cube.GetEdgePoint( edge_point_array[ 1 ], 4, 5 );
        cube.GetEdgePoint( edge_point_array[ 2 ], 5, 1 );
        cube.GetEdgePoint( edge_point_array[ 3 ], 1, 0 );
        cube.GetEdgePoint( edge_point_array[ 4 ], 2, 6 );
        cube.GetEdgePoint( edge_point_array[ 5 ], 6, 7 );
        cube.GetEdgePoint( edge_point_array[ 6 ], 7, 3 );
        cube.GetEdgePoint( edge_point_array[ 7 ], 3, 2 );
        cube.GetEdgePoint( edge_point_array[ 8 ], 0, 2 );
        cube.GetEdgePoint( edge_point_array[ 9 ], 4, 6 );
        cube.GetEdgePoint( edge_point_array[ 10 ], 5, 7 );
        cube.GetEdgePoint( edge_point_array[ 11 ], 1, 3 );

        foreach ( edge_point_index; EdgePointIndexArrayArray[ case_mask ] )
        {
            AddPoint( edge_point_array[ edge_point_index ] );
        }
    }

    // ~~

    void SetFromGrid(
        GRID grid
        )
    {
        long
            cube_cell_index,
            x_offset,
            y_offset,
            z_offset;
        CUBE
            cube;

        foreach ( ref cell; grid.CellMap )
        {
            cube_cell_index = 0;

            for ( x_offset = 0;
                  x_offset <= 1;
                  ++x_offset )
            {
                for ( y_offset = 0;
                      y_offset <= 1;
                      ++y_offset )
                {
                    for ( z_offset = 0;
                          z_offset <= 1;
                          ++z_offset )
                    {
                        grid.GetCell(
                            cube.CellArray[ cube_cell_index ],
                            GetCellIndex( cell.Index, x_offset, y_offset, z_offset )
                            );

                        ++cube_cell_index;
                    }
                }
            }

            TriangulateCube( cube );
        }
    }
}

// -- VARIABLES

float
    CellSize,
    OneOverCellSize;
CLOUD
    Cloud;
GRID
    Grid;
MESH
    Mesh;
POINT
    OffsetPoint,
    FactorPoint;

// -- FUNCTIONS

void PrintError(
    string message
    )
{
    writeln( "*** ERROR : ", message );
}

// ~~

void Abort(
    string message
    )
{
    PrintError( message );

    exit( -1 );
}

// ~~

void Abort(
    string message,
    Exception exception
    )
{
    PrintError( message );
    PrintError( exception.msg );

    exit( -1 );
}

// ~~

void WriteText(
    string file_path,
    string file_text
    )
{
    writeln( "Writing file : ", file_path );

    try
    {
        file_path.write( file_text );
    }
    catch ( Exception exception )
    {
        Abort( "Can't write file : " ~ file_path, exception );
    }
}

// ~~

bool IsInteger(
    string text
    )
{
    long
        character_index;

    character_index = 0;

    if ( character_index < text.length
         && text[ character_index ] == '-' )
    {
        ++character_index;
    }

    while ( character_index < text.length
            && text[ character_index ] >= '0'
            && text[ character_index ] <= '9' )
    {
        ++character_index;
    }

    return
        character_index > 0
        && character_index == text.length;
}

// ~~

bool IsReal(
    string text
    )
{
    long
        character_index;

    character_index = 0;

    if ( character_index < text.length
         && text[ character_index ] == '-' )
    {
        ++character_index;
    }

    while ( character_index < text.length
            && text[ character_index ] >= '0'
            && text[ character_index ] <= '9' )
    {
        ++character_index;
    }

    if ( character_index < text.length
         && text[ character_index ] == '.' )
    {
        ++character_index;
    }

    while ( character_index < text.length
            && text[ character_index ] >= '0'
            && text[ character_index ] <= '9' )
    {
        ++character_index;
    }

    return
        character_index > 0
        && character_index == text.length;
}

// ~~

long GetCellIndex(
    long cell_index,
    long x_offset,
    long y_offset,
    long z_offset
    )
{
    long
        cell_x_index,
        cell_y_index,
        cell_z_index;

    cell_x_index = ( ( cell_index >> CellXShift ) & CellMask ) + x_offset;
    cell_y_index = ( ( cell_index >> CellYShift ) & CellMask ) + y_offset;
    cell_z_index = ( ( cell_index >> CellZShift ) & CellMask ) + z_offset;

    return
        ( cell_x_index << CellXShift )
        | ( cell_y_index << CellYShift )
        | ( cell_z_index << CellZShift );
}

// ~~

void ReadCloud(
    string file_path,
    long skipped_line_count,
    long field_count,
    string line_prefix,
    string line_format
    )
{
    if ( Cloud is null )
    {
        Cloud = new CLOUD();
    }

    Cloud.ReadFile( file_path, skipped_line_count, field_count, field_count, line_prefix, line_format, FactorPoint, OffsetPoint );
}

// ~~

void ReadXyzCloud(
    string file_path
    )
{
    if ( Cloud is null )
    {
        Cloud = new CLOUD();
    }

    Cloud.ReadXyzFile( file_path, FactorPoint, OffsetPoint );
}

// ~~

void ReadPtsCloud(
    string file_path
    )
{
    if ( Cloud is null )
    {
        Cloud = new CLOUD();
    }

    Cloud.ReadPtsFile( file_path, FactorPoint, OffsetPoint );
}

// ~~

void ReadObjCloud(
    string file_path
    )
{
    if ( Cloud is null )
    {
        Cloud = new CLOUD();
    }

    Cloud.ReadObjFile( file_path, FactorPoint, OffsetPoint );
}

// ~~

void TranslateCloud(
    float x_translation,
    float y_translation,
    float z_translation
    )
{
    Cloud.Translate( x_translation, y_translation, z_translation );
}

// ~~

void ScaleCloud(
    float x_scaling,
    float y_scaling,
    float z_scaling
    )
{
    Cloud.Scale( x_scaling, y_scaling, z_scaling );
}

// ~~

void RotateCloudAroundX(
    float x_rotation_angle
    )
{
    Cloud.RotateAroundX( x_rotation_angle );
}

// ~~

void RotateCloudAroundY(
    float y_rotation_angle
    )
{
    Cloud.RotateAroundY( y_rotation_angle );
}

// ~~

void RotateCloudAroundZ(
    float z_rotation_angle
    )
{
    Cloud.RotateAroundZ( z_rotation_angle );
}

// ~~

void DecimateCloud(
    float precision
    )
{
    CellSize = precision;
    OneOverCellSize = 1.0 / precision;
    Grid = new GRID();
    Grid.SetFromCloud( Cloud );
    Cloud = Grid.GetCloud();
}

// ~~

void TriangulateCloud(
    float precision
    )
{
    DecimateCloud( precision );
    Mesh = new MESH();
    Mesh.SetFromGrid( Grid );
    Cloud = Mesh.GetCloud();
}

// ~~

void WriteXyzCloud(
    string file_path
    )
{
    Cloud.WriteXyzFile( file_path );
}

// ~~

void WritePtsCloud(
    string file_path
    )
{
    Cloud.WritePtsFile( file_path );
}

// ~~

void WriteObjMesh(
    string file_path
    )
{
    Mesh.WriteObjFile( file_path, false );
}

// ~~

void main(
    string[] argument_array
    )
{
    string
        option;

    CellSize = 0.01;
    OneOverCellSize = 100.0;
    FactorPoint.SetUnit();
    OffsetPoint.SetNull();
    Cloud = null;
    Grid = null;
    Mesh = null;

    argument_array = argument_array[ 1 .. $ ];

    while ( argument_array.length >= 1
            && argument_array[ 0 ].startsWith( "--" ) )
    {
        option = argument_array[ 0 ];
        argument_array = argument_array[ 1 .. $ ];

        if ( option == "--position-factor"
             && argument_array.length >= 3
             && IsReal( argument_array[ 0 ] )
             && IsReal( argument_array[ 1 ] )
             && IsReal( argument_array[ 2 ] ) )
        {
            FactorPoint.PositionVector.X = argument_array[ 0 ].to!float();
            FactorPoint.PositionVector.Y = argument_array[ 1 ].to!float();
            FactorPoint.PositionVector.Z = argument_array[ 2 ].to!float();

            argument_array = argument_array[ 3 .. $ ];
        }
        else if ( option == "--position-offset"
                  && argument_array.length >= 3
             && IsReal( argument_array[ 0 ] )
             && IsReal( argument_array[ 1 ] )
             && IsReal( argument_array[ 2 ] ) )
        {
            OffsetPoint.PositionVector.X = argument_array[ 0 ].to!float();
            OffsetPoint.PositionVector.Y = argument_array[ 1 ].to!float();
            OffsetPoint.PositionVector.Z = argument_array[ 2 ].to!float();

            argument_array = argument_array[ 3 .. $ ];
        }
        else if ( option == "--color-factor"
                  && argument_array.length >= 4
                  && IsReal( argument_array[ 0 ] )
                  && IsReal( argument_array[ 1 ] )
                  && IsReal( argument_array[ 2 ] )
                  && IsReal( argument_array[ 3 ] ) )
        {
            FactorPoint.ColorVector.X = argument_array[ 0 ].to!float();
            FactorPoint.ColorVector.Y = argument_array[ 1 ].to!float();
            FactorPoint.ColorVector.Z = argument_array[ 2 ].to!float();
            FactorPoint.ColorVector.W = argument_array[ 3 ].to!float();

            argument_array = argument_array[ 3 .. $ ];
        }
        else if ( option == "--color-offset"
                  && argument_array.length >= 4
                  && IsReal( argument_array[ 0 ] )
                  && IsReal( argument_array[ 1 ] )
                  && IsReal( argument_array[ 2 ] )
                  && IsReal( argument_array[ 3 ] ) )
        {
            OffsetPoint.ColorVector.X = argument_array[ 0 ].to!float();
            OffsetPoint.ColorVector.Y = argument_array[ 1 ].to!float();
            OffsetPoint.ColorVector.Z = argument_array[ 2 ].to!float();
            OffsetPoint.ColorVector.W = argument_array[ 3 ].to!float();

            argument_array = argument_array[ 3 .. $ ];
        }
        else if ( option == "--read"
                  && argument_array.length >= 5
                  && IsInteger( argument_array[ 1 ] )
                  && IsInteger( argument_array[ 2 ] ) )
        {
            ReadCloud(
                argument_array[ 0 ],
                argument_array[ 1 ].to!long(),
                argument_array[ 2 ].to!long(),
                argument_array[ 3 ],
                argument_array[ 4 ]
                );

            argument_array = argument_array[ 4 .. $ ];
        }
        else if ( option == "--read-xyz"
                  && argument_array.length >= 1 )
        {
            ReadXyzCloud( argument_array[ 0 ] );

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--read-pts"
                  && argument_array.length >= 1 )
        {
            ReadPtsCloud( argument_array[ 0 ] );

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--read-obj"
                  && argument_array.length >= 1 )
        {
            ReadObjCloud( argument_array[ 0 ] );

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--translate"
                  && argument_array.length >= 3
                  && IsReal( argument_array[ 0 ] )
                  && IsReal( argument_array[ 1 ] )
                  && IsReal( argument_array[ 2 ] )
                  && Cloud !is null )
        {
            TranslateCloud(
                argument_array[ 0 ].to!float(),
                argument_array[ 1 ].to!float(),
                argument_array[ 2 ].to!float()
                );

            argument_array = argument_array[ 3 .. $ ];
        }
        else if ( option == "--scale"
                  && argument_array.length >= 3
                  && IsReal( argument_array[ 0 ] )
                  && IsReal( argument_array[ 1 ] )
                  && IsReal( argument_array[ 2 ] )
                  && Cloud !is null )
        {
            ScaleCloud(
                argument_array[ 0 ].to!float(),
                argument_array[ 1 ].to!float(),
                argument_array[ 2 ].to!float()
                );

            argument_array = argument_array[ 3 .. $ ];
        }
        else if ( option == "--rotate-x"
                  && argument_array.length >= 1
                  && IsReal( argument_array[ 0 ] )
                  && Cloud !is null )
        {
            RotateCloudAroundX( argument_array[ 0 ].to!float() * DegreeToRadianFactor );

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--rotate-y"
                  && argument_array.length >= 1
                  && IsReal( argument_array[ 0 ] )
                  && Cloud !is null )
        {
            RotateCloudAroundY( argument_array[ 0 ].to!float() * DegreeToRadianFactor );

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--rotate-z"
                  && argument_array.length >= 1
                  && IsReal( argument_array[ 0 ] )
                  && Cloud !is null )
        {
            RotateCloudAroundZ( argument_array[ 0 ].to!float() * DegreeToRadianFactor );

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--decimate"
                  && argument_array.length >= 1
                  && IsReal( argument_array[ 0 ] )
                  && Cloud !is null )
        {
            DecimateCloud( argument_array[ 0 ].to!float() );

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--triangulate"
                  && argument_array.length >= 1
                  && IsReal( argument_array[ 0 ] )
                  && Cloud !is null )
        {
            TriangulateCloud( argument_array[ 0 ].to!float() );

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--write-xyz"
                  && argument_array.length >= 1
                  && Cloud !is null )
        {
            WriteXyzCloud( argument_array[ 0 ] );

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--write-pts"
                  && argument_array.length >= 1
                  && Cloud !is null )
        {
            WritePtsCloud( argument_array[ 0 ] );

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--write-obj"
                  && argument_array.length >= 1
                  && Mesh !is null )
        {
            WriteObjMesh( argument_array[ 0 ] );

            argument_array = argument_array[ 1 .. $ ];
        }
        else
        {
            break;
        }
    }

    if ( argument_array.length != 0 )
    {
        writeln( "Usage :" );
        writeln( "    nebula <options>" );
        writeln( "Options :" );
        writeln( "    --position-factor <x> <y> <z>" );
        writeln( "    --position-offset <x> <y> <z>" );
        writeln( "    --color-factor <r> <g> <b> <i>" );
        writeln( "    --color-offset <r> <g> <b> <i>" );
        writeln( "    --read <file path> <skipped line count> <field count> <line prefix> <line format>" );
        writeln( "    --read-xyz <file path>" );
        writeln( "    --read-pts <file path>" );
        writeln( "    --read-obj <file path>" );
        writeln( "    --translate <x> <y> <z>" );
        writeln( "    --scale <x> <y> <z>" );
        writeln( "    --rotate-x <degree angle>" );
        writeln( "    --rotate-y <degree angle>" );
        writeln( "    --rotate-z <degree angle>" );
        writeln( "    --decimate <precision>" );
        writeln( "    --triangulate <precision>" );
        writeln( "    --write-xyz <file path>" );
        writeln( "    --write-pts <file path>" );
        writeln( "    --write-obj <file path>" );
        writeln( "Examples :" );
        writeln( "    nebula --read-pts cloud.pts --write-xyz cloud.xyz" );
        writeln( "    nebula --read-pts cloud.pts --scale 2 2 2 --rotate-z 45 --write-pts scaled_cloud.pts" );
        writeln( "    nebula --read-pts cloud.pts --decimate 0.01 --write-pts decimated_cloud.pts" );
        writeln( "    nebula --read-pts cloud.pts --triangulate 0.01 --write-obj triangulated_mesh.obj" );
        Abort( "Invalid arguments : " ~ argument_array.to!string() );
    }
}
