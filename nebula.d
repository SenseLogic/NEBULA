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
import std.algorithm : max;
import std.conv : to;
import std.file : write;
import std.math : cos, round, sin, sqrt, PI;
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
        X = 0.0,
        Y = 0.0,
        Z = 0.0;

    // -- INQUIRIES

    double GetDistance(
        VECTOR_3 position_vector
        )
    {
        double
            x_distance,
            y_distance,
            z_distance;

        x_distance = position_vector.X - X;
        y_distance = position_vector.Y - Y;
        z_distance = position_vector.Z - Z;

        return sqrt( x_distance * x_distance + y_distance * y_distance + z_distance * z_distance );
    }

    // ~~

    long GetPointCount(
        VECTOR_3 position_vector,
        double point_distance
        )
    {
        return 1 + ( GetDistance( position_vector ) / point_distance ).to!long();
    }

    // ~~

    long GetCellIndex(
        float one_over_precision
        )
    {
        return .GetCellIndex( X, Y, Z, one_over_precision );
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

    void AddScaledVector(
        ref VECTOR_3 vector,
        float factor
        )
    {
        X += vector.X * factor;
        Y += vector.Y * factor;
        Z += vector.Z * factor;
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

    void SetInterpolatedVector(
        VECTOR_3 first_vector,
        VECTOR_3 second_vector,
        double interpolation_factor
        )
    {
        X = first_vector.X + ( second_vector.X - first_vector.X ) * interpolation_factor;
        Y = first_vector.Y + ( second_vector.Y - first_vector.Y ) * interpolation_factor;
        Z = first_vector.Z + ( second_vector.Z - first_vector.Z ) * interpolation_factor;
    }

    // ~~

    void SetFromCellIndex(
        long cell_index,
        float cell_offset,
        float precision
        )
    {
        X = ( GetCellXIndex( cell_index ).to!float() + cell_offset ) * precision;
        Y = ( GetCellYIndex( cell_index ).to!float() + cell_offset ) * precision;
        Z = ( GetCellZIndex( cell_index ).to!float() + cell_offset ) * precision;
    }
}

// ~~

struct VECTOR_4
{
    // -- ATTRIBUTES

    float
        X = 0.0,
        Y = 0.0,
        Z = 0.0,
        W = 0.0;

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

    // ~~

    void Translate(
        float x_translation,
        float y_translation,
        float z_translation,
        float w_translation
        )
    {
        X += x_translation;
        Y += y_translation;
        Z += z_translation;
        W += w_translation;
    }

    // ~~

    void Scale(
        float x_scaling,
        float y_scaling,
        float z_scaling,
        float w_scaling
        )
    {
        X *= x_scaling;
        Y *= y_scaling;
        Z *= z_scaling;
        W *= w_scaling;
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
        float one_over_precision
        )
    {
        return PositionVector.GetCellIndex( one_over_precision );
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

    void MultiplyScalar(
        float factor
        )
    {
        PositionVector.MultiplyScalar( factor );
        ColorVector.MultiplyScalar( factor );
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

    // ~~

    void SetPositionFromCellIndex(
        long cell_index,
        float offset,
        float precision
        )
    {
        PositionVector.SetFromCellIndex( cell_index, offset, precision );
    }

    // ~~

    void SetCenterPosition(
        long cell_index,
        float precision
        )
    {
        PositionVector.SetFromCellIndex( cell_index, 0.0, precision );
    }

    // ~~

    void SetClippedPosition(
        long cell_index,
        float ratio,
        float precision
        )
    {
        VECTOR_3
            minimum_position_vector,
            maximum_position_vector;

        minimum_position_vector.SetFromCellIndex( cell_index, ratio, precision );
        maximum_position_vector.SetFromCellIndex( cell_index, 1.0 - ratio, precision );
        PositionVector.Clip( minimum_position_vector, maximum_position_vector );
    }
}

// ~~

class CLOUD
{
    // -- ATTRIBUTES

    POINT[]
        PointArray;

    // -- INQUIRIES

    void WriteXyzCloudFile(
        string file_path
        )
    {
        File
            file;

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

    void WritePtsCloudFile(
        string file_path
        )
    {
        File
            file;

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
        long cell_index,
        float precision
        )
    {
        Index = cell_index;
        PointCount = 0;
        Point.SetCenterPosition( cell_index, precision );
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

    void SetAveragePoint(
        )
    {
        if ( PointCount > 1 )
        {
            Point.MultiplyScalar( 1.0 / PointCount.to!float() );
            PointCount = 1;
        }
    }

    // ~~

    void SetAveragePosition(
        )
    {
        if ( PointCount > 1 )
        {
            Point.PositionVector.MultiplyScalar( 1.0 / PointCount.to!float() );
            PointCount = 1;
        }
    }

    // ~~

    void SetCenterPosition(
        float precision
        )
    {
        Point.SetCenterPosition( Index, precision );
    }

    // ~~

    void SetClippedPosition(
        float ratio,
        float precision
        )
    {
        Point.SetClippedPosition( Index, ratio, precision );
    }
}

// ~~

class GRID
{
    // -- ATTRIBUTES

    float
        Precision,
        OneOverPrecision;
    CELL[ long ]
        CellMap;

    // -- CONSTRUCTORS

    this(
        float precision
        )
    {
        Precision = precision;
        OneOverPrecision = 1.0 / precision;
    }

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
            cell.SetEmpty( cell_index, Precision );
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

        cell_index = point.GetCellIndex( OneOverPrecision );
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

    void SetAveragePoint(
        )
    {
        foreach ( cell_index, ref cell; CellMap )
        {
            cell.SetAveragePoint();
        }
    }

    // ~~

    void AddEmptyCell(
        long cell_index
        )
    {
        float
            cell_position_offset;
        float[ 3 ]
            offset_factor_array;
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
        VECTOR_3
            cell_position_vector,
            near_cell_position_vector,
            offset_factor_vector;

        offset_factor_array = [ -1.0, 0.0, 1.0 ];

        found_cell = cell_index in CellMap;

        if ( found_cell is null )
        {
            cell.SetEmpty( cell_index, Precision );
            cell_position_vector = cell.Point.PositionVector;
            cell.PointCount = 1;
            cell_position_offset = Precision * 0.5;

            for ( x_offset = -1;
                  x_offset <= 1;
                  ++x_offset )
            {
                offset_factor_vector.X = offset_factor_array[ x_offset + 1 ];

                for ( y_offset = -1;
                      y_offset <= 1;
                      ++y_offset )
                {
                    offset_factor_vector.Y = offset_factor_array[ y_offset + 1 ];

                    for ( z_offset = -1;
                          z_offset <= 1;
                          ++z_offset )
                    {
                        if ( x_offset != 0
                             || y_offset != 0
                             || z_offset != 0 )
                        {
                            near_cell_index = GetOffsetCellIndex( cell_index, x_offset, y_offset, z_offset );
                            found_near_cell = near_cell_index in CellMap;

                            if ( found_near_cell !is null
                                 && found_near_cell.PointCount > 0 )
                            {
                                offset_factor_vector.Z = offset_factor_array[ z_offset + 1 ];

                                near_cell_position_vector = cell_position_vector;
                                near_cell_position_vector.AddScaledVector( offset_factor_vector, cell_position_offset );

                                cell.Point.PositionVector.AddVector( near_cell_position_vector );
                                ++cell.PointCount;
                            }
                        }
                    }
                }
            }

            cell.SetAveragePosition();
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
                            AddEmptyCell( GetOffsetCellIndex( cell_index, x_offset, y_offset, z_offset ) );
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

        SetAveragePoint();
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

    void WriteObjMeshFile(
        string file_path,
        bool point_has_color
        )
    {
        long
            point_index_index;
        File
            file;

        try
        {
            file.open( file_path, "w" );

            if ( point_has_color )
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

    void ReadObjMeshFile(
        string file_path
        )
    {
        long
            first_point_index,
            part_index;
        long[]
            point_index_array;
        string
            line;
        string[]
            part_array;
        File
            file;
        POINT
            point;

        writeln( "Reading file : ", file_path );

        first_point_index = PointIndexArray.length;

        try
        {
            file.open( file_path, "r" );

            foreach ( file_line; file.byLine() )
            {
                line = file_line.to!string().strip();

                if ( line.startsWith( "v " ) )
                {
                    part_array = line.split( ' ' );

                    point.PositionVector.X = part_array[ 1 ].to!float();
                    point.PositionVector.Y = part_array[ 2 ].to!float();
                    point.PositionVector.Z = part_array[ 3 ].to!float();

                    Mesh.PointArray ~= point;
                }
                else if ( line.startsWith( "f " ) )
                {
                    part_array = line.split( ' ' );
                    point_index_array = [];

                    for ( part_index = 1;
                          part_index < part_array.length;
                          ++part_index )
                    {
                        point_index_array
                            ~= first_point_index
                               + part_array[ part_index ].split( '/' )[ 0 ].to!long()
                               - 1;
                    }

                    for ( part_index = 1;
                          part_index + 1 < part_array.length;
                          ++part_index )
                    {
                        Mesh.PointIndexArray ~= point_index_array[ 0 ];
                        Mesh.PointIndexArray ~= point_index_array[ part_index ];
                        Mesh.PointIndexArray ~= point_index_array[ part_index + 1 ];
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

        writeln( "Triangulating cloud : ", grid.Precision );

        grid.AddEmptyCells();

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
                            GetOffsetCellIndex( cell.Index, x_offset, y_offset, z_offset )
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
    Precision;
float
    XFieldFactor,
    YFieldFactor,
    ZFieldFactor;
long
    BFieldIndex,
    IFieldIndex,
    GFieldIndex,
    RFieldIndex,
    XFieldIndex,
    YFieldIndex,
    ZFieldIndex;
CLOUD
    Cloud;
GRID
    Grid;
MESH
    Mesh;
VECTOR_3
    PositionOffsetVector,
    PositionRotationVector,
    PositionScalingVector,
    PositionTranslationVector;
VECTOR_4
    ColorOffsetVector,
    ColorScalingVector,
    ColorTranslationVector;

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
    long cell_x_index,
    long cell_y_index,
    long cell_z_index
    )
{
    return
        ( ( cell_x_index + CellBasis ) << CellXShift )
        | ( ( cell_y_index + CellBasis ) << CellYShift )
        | ( ( cell_z_index + CellBasis ) << CellZShift );
}

// ~~

long GetCellIndex(
    float x,
    float y,
    float z,
    float one_over_precision
    )
{
    return
        GetCellIndex(
            ( x * one_over_precision ).round().to!long(),
            ( y * one_over_precision ).round().to!long(),
            ( z * one_over_precision ).round().to!long()
            );
}

// ~~

long GetCellXIndex(
    long cell_index
    )
{
    return ( ( cell_index >> CellXShift ) & CellMask ) - CellBasis;
}

// ~~

long GetCellYIndex(
    long cell_index
    )
{
    return ( ( cell_index >> CellYShift ) & CellMask ) - CellBasis;
}

// ~~

long GetCellZIndex(
    long cell_index
    )
{
    return ( ( cell_index >> CellZShift ) & CellMask ) - CellBasis;
}

// ~~

long GetOffsetCellIndex(
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

void SetPrecision(
    float precision
    )
{
    Precision = precision;
}

// ~~

bool HasCloud(
    )
{
    if ( Cloud is null )
    {
        if ( Grid !is null )
        {
            Cloud = Grid.GetCloud();
        }
        else if ( Mesh !is null )
        {
            Cloud = Mesh.GetCloud();
        }
    }

    Grid = null;
    Mesh = null;

    return Cloud !is null;
}

// ~~

bool HasGrid(
    )
{
    if ( Grid is null
         && Precision != 0.0
         && HasCloud() )
    {
        Grid = new GRID( Precision );
        Grid.SetFromCloud( Cloud );
    }

    Cloud = null;
    Mesh = null;

    return Grid !is null;
}

// ~~

bool HasMesh(
    )
{
    if ( Mesh is null
         && HasGrid() )
    {
        Mesh = new MESH();
        Mesh.SetFromGrid( Grid );
    }

    Cloud = null;
    Grid = null;

    return Mesh !is null;
}

// ~~

bool HasCloudOrGrid(
    float precision
    )
{
    if ( precision == 0.0 )
    {
        if ( !HasCloud() )
        {
            Cloud = new CLOUD();
        }

        SetPrecision( precision );
    }
    else
    {
        if ( Grid !is null
             && Grid.Precision != precision )
        {
            Cloud = Grid.GetCloud();
            Grid = null;
            Mesh = null;
        }

        SetPrecision( precision );

        if ( !HasGrid() )
        {
            Grid = new GRID( precision );
        }
    }

    return true;
}

// ~~

void AddPoint(
    ref POINT point
    )
{
    point.PositionVector.Translate(
        PositionOffsetVector.X,
        PositionOffsetVector.Y,
        PositionOffsetVector.Z
        );

    point.PositionVector.Scale(
        PositionScalingVector.X,
        PositionScalingVector.Y,
        PositionScalingVector.Z
        );

    if ( PositionRotationVector.Z != 0.0 )
    {
        point.PositionVector.RotateAroundZ(
            PositionRotationVector.Z.cos(),
            PositionRotationVector.Z.sin()
            );
    }

    if ( PositionRotationVector.X != 0.0 )
    {
        point.PositionVector.RotateAroundX(
            PositionRotationVector.X.cos(),
            PositionRotationVector.X.sin()
            );
    }

    if ( PositionRotationVector.Y != 0.0 )
    {
        point.PositionVector.RotateAroundY(
            PositionRotationVector.Y.cos(),
            PositionRotationVector.Y.sin()
            );
    }

    point.PositionVector.Translate(
        PositionTranslationVector.X,
        PositionTranslationVector.Y,
        PositionTranslationVector.Z
        );

    point.ColorVector.Translate(
        ColorOffsetVector.X,
        ColorOffsetVector.Y,
        ColorOffsetVector.Z,
        ColorOffsetVector.W
        );

    point.ColorVector.Scale(
        ColorScalingVector.X,
        ColorScalingVector.Y,
        ColorScalingVector.Z,
        ColorScalingVector.W
        );

    point.ColorVector.Translate(
        ColorTranslationVector.X,
        ColorTranslationVector.Y,
        ColorTranslationVector.Z,
        ColorTranslationVector.W
        );

    if ( Cloud !is null )
    {
        Cloud.AddPoint( point );
    }
    else if ( Grid !is null )
    {
        Grid.AddPoint( point );
    }
}

// ~~

void SetLineFormat(
    string line_format
    )
{
    XFieldIndex = line_format.indexOf( 'X' );
    XFieldFactor = 1.0;
    YFieldIndex = line_format.indexOf( 'Y' );
    YFieldFactor = 1.0;
    ZFieldIndex = line_format.indexOf( 'Z' );
    ZFieldFactor = 1.0;
    RFieldIndex = line_format.indexOf( 'R' );
    GFieldIndex = line_format.indexOf( 'G' );
    BFieldIndex = line_format.indexOf( 'B' );
    IFieldIndex = line_format.indexOf( 'I' );

    if ( XFieldIndex < 0 )
    {
        XFieldIndex = line_format.indexOf( 'x' );
        XFieldFactor = -1.0;
    }

    if ( YFieldIndex < 0 )
    {
        YFieldIndex = line_format.indexOf( 'y' );
        YFieldFactor = -1.0;
    }

    if ( ZFieldIndex < 0 )
    {
        ZFieldIndex = line_format.indexOf( 'z' );
        ZFieldFactor = -1.0;
    }
}

// ~~

void ReadCloudFile(
    string file_path,
    float precision,
    long skipped_line_count,
    long minimum_field_count,
    long maximum_field_count,
    string line_prefix,
    string line_format
    )
{
    string
        line;
    string[]
        field_array;
    File
        file;
    POINT
        point;

    writeln( "Reading file : ", file_path, " ", precision );

    SetLineFormat( line_format );

    if ( HasCloudOrGrid( precision ) )
    {
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
                                if ( XFieldIndex >= 0
                                     && XFieldIndex < field_array.length )
                                {
                                    point.PositionVector.X = field_array[ XFieldIndex ].to!float() * XFieldFactor;
                                }

                                if ( YFieldIndex >= 0
                                     && YFieldIndex < field_array.length )
                                {
                                    point.PositionVector.Y = field_array[ YFieldIndex ].to!float() * YFieldFactor;
                                }

                                if ( ZFieldIndex >= 0
                                     && ZFieldIndex < field_array.length )
                                {
                                    point.PositionVector.Z = field_array[ ZFieldIndex ].to!float() * ZFieldFactor;
                                }

                                if ( RFieldIndex >= 0
                                     && RFieldIndex < field_array.length )
                                {
                                    point.ColorVector.X = field_array[ RFieldIndex ].to!float();
                                }

                                if ( GFieldIndex >= 0
                                     && GFieldIndex < field_array.length )
                                {
                                    point.ColorVector.Y = field_array[ GFieldIndex ].to!float();
                                }

                                if ( BFieldIndex >= 0
                                     && BFieldIndex < field_array.length )
                                {
                                    point.ColorVector.Z = field_array[ BFieldIndex ].to!float();
                                }

                                if ( IFieldIndex >= 0
                                     && IFieldIndex < field_array.length )
                                {
                                    point.ColorVector.W = field_array[ IFieldIndex ].to!float();
                                }
                            }
                            catch ( Exception exception )
                            {
                                Abort( "Can't read line : " ~ line );
                            }

                            AddPoint( point );
                        }
                    }
                }
            }

            if ( Grid !is null )
            {
                Grid.SetAveragePoint();
            }

            file.close();
        }
        catch ( Exception exception )
        {
            Abort( "Can't read file : " ~ file_path, exception );
        }
    }
}

// ~~

void ReadXyzCloudFile(
    string file_path,
    float precision
    )
{
    ReadCloudFile( file_path, precision, 0, 3, 3, "", "XYZ" );
}

// ~~

void ReadPtsCloudFile(
    string file_path,
    float precision
    )
{
    ReadCloudFile( file_path, precision, 0, 3, 7, "", "XYZIRGB" );
}

// ~~

void ReadObjCloudFile(
    string file_path,
    float precision
    )
{
    ReadCloudFile( file_path, precision, 0, 4, 7, "v ", "_XYZRGB" );
}

// ~~

void ReadObjMeshFile(
    string file_path
    )
{
    Cloud = null;
    Grid = null;
    Mesh = new MESH();
    Mesh.ReadObjMeshFile( file_path );
}

// ~~

void TessellateMesh(
    float precision,
    float tessellation
    )
{
    writeln( "Tesselating mesh : ", precision, " ", tessellation );
}

// ~~

void TranslateCloud(
    float x_translation,
    float y_translation,
    float z_translation
    )
{
    writeln( "Translating cloud : ", x_translation, " ", y_translation, " ", z_translation );

    Cloud.Translate( x_translation, y_translation, z_translation );
}

// ~~

void ScaleCloud(
    float x_scaling,
    float y_scaling,
    float z_scaling
    )
{
    writeln( "Scaling cloud : ", x_scaling, " ", y_scaling, " ", z_scaling );

    Cloud.Scale( x_scaling, y_scaling, z_scaling );
}

// ~~

void RotateCloudAroundX(
    float x_rotation_angle
    )
{
    writeln( "Rotating cloud around X : ", x_rotation_angle );

    Cloud.RotateAroundX( x_rotation_angle * DegreeToRadianFactor );
}

// ~~

void RotateCloudAroundY(
    float y_rotation_angle
    )
{
    writeln( "Rotating cloud around Y : ", y_rotation_angle );

    Cloud.RotateAroundY( y_rotation_angle * DegreeToRadianFactor );
}

// ~~

void RotateCloudAroundZ(
    float z_rotation_angle
    )
{
    writeln( "Rotating cloud around Y : ", z_rotation_angle );

    Cloud.RotateAroundZ( z_rotation_angle * DegreeToRadianFactor );
}

// ~~

void DecimateCloud(
    float precision
    )
{
    writeln( "Decimating cloud : ", precision );

    SetPrecision( precision );
    Grid = new GRID( precision );
    Grid.SetFromCloud( Cloud );
    Cloud = null;
}

// ~~

void WriteXyzCloudFile(
    string file_path
    )
{
    writeln( "Writing file : ", file_path );

    Cloud.WriteXyzCloudFile( file_path );
}

// ~~

void WritePtsCloudFile(
    string file_path
    )
{
    writeln( "Writing file : ", file_path );

    Cloud.WritePtsCloudFile( file_path );
}

// ~~

void WriteObjMeshFile(
    string file_path
    )
{
    writeln( "Writing file : ", file_path );

    Mesh.WriteObjMeshFile( file_path, false );
}

// ~~

void main(
    string[] argument_array
    )
{
    string
        option;

    SetPrecision( 0.01 );
    PositionOffsetVector.SetNull();
    PositionScalingVector.SetUnit();
    PositionRotationVector.SetNull();
    PositionTranslationVector.SetNull();
    ColorOffsetVector.SetNull();
    ColorScalingVector.SetUnit();
    ColorTranslationVector.SetNull();
    Cloud = null;
    Grid = null;
    Mesh = null;

    argument_array = argument_array[ 1 .. $ ];

    while ( argument_array.length >= 1
            && argument_array[ 0 ].startsWith( "--" ) )
    {
        option = argument_array[ 0 ];
        argument_array = argument_array[ 1 .. $ ];

        if ( option == "--position-offset"
             && argument_array.length >= 3
             && IsReal( argument_array[ 0 ] )
             && IsReal( argument_array[ 1 ] )
             && IsReal( argument_array[ 2 ] ) )
        {
            PositionOffsetVector.X = argument_array[ 0 ].to!float();
            PositionOffsetVector.Y = argument_array[ 1 ].to!float();
            PositionOffsetVector.Z = argument_array[ 2 ].to!float();

            argument_array = argument_array[ 3 .. $ ];
        }
        else if ( option == "--position-scaling"
                  && argument_array.length >= 3
                  && IsReal( argument_array[ 0 ] )
                  && IsReal( argument_array[ 1 ] )
                  && IsReal( argument_array[ 2 ] ) )
        {
            PositionScalingVector.X = argument_array[ 0 ].to!float();
            PositionScalingVector.Y = argument_array[ 1 ].to!float();
            PositionScalingVector.Z = argument_array[ 2 ].to!float();

            argument_array = argument_array[ 3 .. $ ];
        }
        else if ( option == "--position-rotation"
                  && argument_array.length >= 3
                  && IsReal( argument_array[ 0 ] )
                  && IsReal( argument_array[ 1 ] )
                  && IsReal( argument_array[ 2 ] ) )
        {
            PositionRotationVector.X = argument_array[ 0 ].to!float() * DegreeToRadianFactor;
            PositionRotationVector.Y = argument_array[ 1 ].to!float() * DegreeToRadianFactor;
            PositionRotationVector.Z = argument_array[ 2 ].to!float() * DegreeToRadianFactor;

            argument_array = argument_array[ 3 .. $ ];
        }
        else if ( option == "--position-translation"
                  && argument_array.length >= 3
                  && IsReal( argument_array[ 0 ] )
                  && IsReal( argument_array[ 1 ] )
                  && IsReal( argument_array[ 2 ] ) )
        {
            PositionTranslationVector.X = argument_array[ 0 ].to!float();
            PositionTranslationVector.Y = argument_array[ 1 ].to!float();
            PositionTranslationVector.Z = argument_array[ 2 ].to!float();

            argument_array = argument_array[ 3 .. $ ];
        }
        else if ( option == "--color-offset"
                  && argument_array.length >= 4
                  && IsReal( argument_array[ 0 ] )
                  && IsReal( argument_array[ 1 ] )
                  && IsReal( argument_array[ 2 ] )
                  && IsReal( argument_array[ 3 ] ) )
        {
            ColorOffsetVector.X = argument_array[ 0 ].to!float();
            ColorOffsetVector.Y = argument_array[ 1 ].to!float();
            ColorOffsetVector.Z = argument_array[ 2 ].to!float();
            ColorOffsetVector.W = argument_array[ 3 ].to!float();

            argument_array = argument_array[ 3 .. $ ];
        }
        else if ( option == "--color-scaling"
                  && argument_array.length >= 4
                  && IsReal( argument_array[ 0 ] )
                  && IsReal( argument_array[ 1 ] )
                  && IsReal( argument_array[ 2 ] )
                  && IsReal( argument_array[ 3 ] ) )
        {
            ColorScalingVector.X = argument_array[ 0 ].to!float();
            ColorScalingVector.Y = argument_array[ 1 ].to!float();
            ColorScalingVector.Z = argument_array[ 2 ].to!float();
            ColorScalingVector.W = argument_array[ 3 ].to!float();

            argument_array = argument_array[ 3 .. $ ];
        }
        else if ( option == "--color-translation"
                  && argument_array.length >= 4
                  && IsReal( argument_array[ 0 ] )
                  && IsReal( argument_array[ 1 ] )
                  && IsReal( argument_array[ 2 ] )
                  && IsReal( argument_array[ 3 ] ) )
        {
            ColorTranslationVector.X = argument_array[ 0 ].to!float();
            ColorTranslationVector.Y = argument_array[ 1 ].to!float();
            ColorTranslationVector.Z = argument_array[ 2 ].to!float();
            ColorTranslationVector.W = argument_array[ 3 ].to!float();

            argument_array = argument_array[ 3 .. $ ];
        }
        else if ( option == "--read-cloud"
                  && argument_array.length >= 7
                  && IsReal( argument_array[ 1 ] )
                  && IsInteger( argument_array[ 2 ] )
                  && IsInteger( argument_array[ 3 ] )
                  && IsInteger( argument_array[ 4 ] ) )
        {
            ReadCloudFile(
                argument_array[ 0 ],
                argument_array[ 1 ].to!float(),
                argument_array[ 2 ].to!long(),
                argument_array[ 3 ].to!long(),
                argument_array[ 4 ].to!long(),
                argument_array[ 5 ],
                argument_array[ 6 ]
                );

            argument_array = argument_array[ 7 .. $ ];
        }
        else if ( option == "--read-xyz-cloud"
                  && argument_array.length >= 2
                  && IsReal( argument_array[ 1 ] ) )
        {
            ReadXyzCloudFile(
                argument_array[ 0 ],
                argument_array[ 1 ].to!float()
                );

            argument_array = argument_array[ 2 .. $ ];
        }
        else if ( option == "--read-pts-cloud"
                  && argument_array.length >= 2
                  && IsReal( argument_array[ 1 ] ) )
        {
            ReadPtsCloudFile(
                argument_array[ 0 ],
                argument_array[ 1 ].to!float()
                );

            argument_array = argument_array[ 2 .. $ ];
        }
        else if ( option == "--read-obj-cloud"
                  && argument_array.length >= 3
                  && IsReal( argument_array[ 1 ] ) )
        {
            ReadObjCloudFile(
                argument_array[ 0 ],
                argument_array[ 1 ].to!float()
                );

            argument_array = argument_array[ 3 .. $ ];
        }
        else if ( option == "--read-obj-mesh"
                  && argument_array.length >= 1 )
        {
            ReadObjMeshFile(
                argument_array[ 0 ]
                );

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--tessellate"
                  && argument_array.length >= 2
                  && IsReal( argument_array[ 0 ] )
                  && IsReal( argument_array[ 1 ] )
                  && HasMesh() )
        {
            TessellateMesh(
                argument_array[ 0 ].to!float(),
                argument_array[ 1 ].to!float()
                );

            argument_array = argument_array[ 2 .. $ ];
        }
        else if ( option == "--translate"
                  && argument_array.length >= 3
                  && IsReal( argument_array[ 0 ] )
                  && IsReal( argument_array[ 1 ] )
                  && IsReal( argument_array[ 2 ] )
                  && HasCloud() )
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
                  && HasCloud() )
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
                  && HasCloud() )
        {
            RotateCloudAroundX( argument_array[ 0 ].to!float() );

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--rotate-y"
                  && argument_array.length >= 1
                  && IsReal( argument_array[ 0 ] )
                  && HasCloud() )
        {
            RotateCloudAroundY( argument_array[ 0 ].to!float() );

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--rotate-z"
                  && argument_array.length >= 1
                  && IsReal( argument_array[ 0 ] )
                  && HasCloud() )
        {
            RotateCloudAroundZ( argument_array[ 0 ].to!float() );

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--decimate"
                  && argument_array.length >= 1
                  && IsReal( argument_array[ 0 ] )
                  && HasCloud() )
        {
            DecimateCloud( argument_array[ 0 ].to!float() );

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--write-xyz-cloud"
                  && argument_array.length >= 1
                  && HasCloud() )
        {
            WriteXyzCloudFile( argument_array[ 0 ] );

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--write-pts-cloud"
                  && argument_array.length >= 1
                  && HasCloud() )
        {
            WritePtsCloudFile( argument_array[ 0 ] );

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--write-obj-mesh"
                  && argument_array.length >= 1
                  && HasMesh() )
        {
            WriteObjMeshFile( argument_array[ 0 ] );

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
        writeln( "    --position-offset <x> <y> <z>" );
        writeln( "    --position-scaling <x> <y> <z>" );
        writeln( "    --position-rotation <x> <y> <z>" );
        writeln( "    --position-translation <x> <y> <z>" );
        writeln( "    --color-offset <r> <g> <b> <i>" );
        writeln( "    --color-scaling <r> <g> <b> <i>" );
        writeln( "    --color-translation <r> <g> <b> <i>" );
        writeln( "    --read-cloud <file path> <precision> <skipped line count> <minimum field count> <maximum field count> <line prefix> <line format>" );
        writeln( "    --read-xyz-cloud <file path> <precision>" );
        writeln( "    --read-pts-cloud <file path> <precision>" );
        writeln( "    --read-obj-cloud <file path> <precision>" );
        writeln( "    --read-obj-mesh <file path>" );
        writeln( "    --tessellate <distance> <precision>" );
        writeln( "    --translate <x> <y> <z>" );
        writeln( "    --scale <x> <y> <z>" );
        writeln( "    --rotate-x <degree angle>" );
        writeln( "    --rotate-y <degree angle>" );
        writeln( "    --rotate-z <degree angle>" );
        writeln( "    --decimate <precision>" );
        writeln( "    --write-xyz-cloud <file path>" );
        writeln( "    --write-pts-cloud <file path>" );
        writeln( "    --write-obj-mesh <file path>" );
        writeln( "Examples :" );
        writeln( "    nebula --read-cloud cloud.xyz 0 0 3 3 \"\" xZY --write-xyz-cloud flipped_cloud.xyz" );
        writeln( "    nebula --read-cloud cloud.pts 0 1 7 7 \"\" xZYIRGB --write-pts-cloud flipped_cloud.pts" );
        writeln( "    nebula --read-pts-cloud cloud.pts 0 --write-xyz-cloud converted_cloud.xyz" );
        writeln( "    nebula --read-pts-cloud cloud.pts 0 --scale 2 2 2 --rotate-z 45 --write-pts-cloud scaled_cloud.pts" );
        writeln( "    nebula --read-xyz-cloud cloud.xyz 0 --position-scaling 2 2 2 --read-xyz-cloud cloud.xyz --write-xyz-cloud merged_clouds.xyz" );
        writeln( "    nebula --read-pts-cloud cloud.pts 0.01 --write-pts-cloud decimated_cloud.pts" );
        writeln( "    nebula --read-pts-cloud cloud.pts 0.01 --write-obj-mesh triangulated_cloud.obj" );
        Abort( "Invalid arguments : " ~ argument_array.to!string() );
    }
}
