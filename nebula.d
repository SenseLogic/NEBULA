/*
    This file is part of the Nebula distribution.

    https://github.com/senselogic/NEBULA

    Copyright (C) 2021 Eric Pelzer (ecstatic.coder@gmail.com)

    Nebula is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, version 3.

    Nebula is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Nebula.  If not, see <http://www.gnu.org/licenses/>.
*/

// -- IMPORTS

import core.stdc.stdlib : exit;
import std.algorithm : max;
import std.conv : to;
import std.file : write;
import std.math : cos, round, sin, sqrt, PI;
import std.stdio : readln, writeln, File;
import std.string : endsWith, format, indexOf, replace, split, startsWith, strip;
import pcf.cell;
import pcf.cloud;
import pcf.component;
import pcf.compression;
import pcf.scan;

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

// -- TYPES

union SCALAR
{
    long
        Natural;
    double
        Real64;
    float[ 2 ]
        Real32Array;
}

// ~~

class PROPERTY
{
    // -- ATTRIBUTES

    string
        Name,
        Value;

    // -- OPERATIONS

    void SetFromText(
        string text
        )
    {
        string[]
            part_array;

        part_array = text.split( "=" );

        Name = part_array[ 0 ];

        if ( part_array.length > 1 )
        {
            Value = part_array[ 1 ];
        }
    }
}

// ~~

class TAG
{
    // -- ATTRIBUTES

    string
        Name,
        Text;
    PROPERTY[]
        PropertyArray;
    TAG[]
        SubTagArray;

    // -- INQUIRIES

    bool FindTag(
        ref TAG found_tag,
        string tag_name
        )
    {
        if ( Name == tag_name )
        {
            found_tag = this;

            return true;
        }
        else
        {
            foreach ( sub_tag; SubTagArray )
            {
                if ( sub_tag.FindTag( found_tag, tag_name ) )
                {
                    return true;
                }
            }

            return false;
        }
    }

    // ~~

    bool HasPropertyValue(
        string property_name
        )
    {
        foreach ( property; PropertyArray )
        {
            if ( property.Name == property_name )
            {
                return true;
            }
        }

        return false;
    }

    // ~~

    string GetPropertyValue(
        string property_name,
        string default_property_value = ""
        )
    {
        foreach ( property; PropertyArray )
        {
            if ( property.Name == property_name )
            {
                return property.Value;
            }
        }

        return default_property_value;
    }

    // ~~

    void Dump(
        long level = 0
        )
    {
        string
            line;

        line = level.to!string() ~ " : " ~ Name;

        foreach ( property; PropertyArray )
        {
            line ~= " " ~ property.Name ~ "=\"" ~ property.Value ~ "\"";
        }

        writeln( line );

        if ( level >= 0 )
        {
            foreach ( sub_tag; SubTagArray )
            {
                sub_tag.Dump( level + 1 );
            }
        }
    }

    // -- OPERATIONS

    void SetFromText(
        string text
        )
    {
        string[]
            part_array;
        PROPERTY
            property;

        part_array = text.replace( "\"", "" ).replace( "'", "" ).split( " " );

        Name = part_array[ 0 ];

        foreach ( property_text; part_array[ 1 .. $ ] )
        {
            if ( property_text != "" )
            {
                property = new PROPERTY();
                property.SetFromText( property_text );
                PropertyArray ~= property;
            }
        }
    }
}

// ~~

class DOCUMENT : TAG
{
    // -- OPERATIONS

    override void SetFromText(
        string text
        )
    {
        long
            post_tag_character_index,
            tag_character_index;
        string
            tag_text;
        TAG
            tag;
        TAG[]
            tag_array;

        text = text.replace( "\r", "" ).replace( "\n", " " ).replace( "\t", " " );

        while ( text.indexOf( "  " ) >= 0 )
        {
            text = text.replace( "  ", " " );
        }

        for ( tag_character_index = 0;
              tag_character_index < text.length;
              ++tag_character_index )
        {
            if ( text[ tag_character_index ] == '<' )
            {
                post_tag_character_index = tag_character_index;

                while ( text[ post_tag_character_index ] != '>' )
                {
                    ++post_tag_character_index;
                }

                tag_text = text[ tag_character_index + 1 .. post_tag_character_index ];

                if ( !tag_text.startsWith( '?' )
                     && !tag_text.startsWith( '!' ) )
                {
                    if ( tag_text.startsWith( "/" ) )
                    {
                        tag_array = tag_array[ 0 .. $ - 1 ];
                    }
                    else
                    {
                        tag = new TAG();

                        if ( tag_text.endsWith( "/" ) )
                        {
                            tag.SetFromText( tag_text[ 0 .. $ - 1 ] );
                        }
                        else
                        {
                            tag.SetFromText( tag_text );
                        }

                        if ( tag_array.length == 0 )
                        {
                            SubTagArray ~= tag;
                        }
                        else
                        {
                            tag_array[ $ - 1 ].SubTagArray ~= tag;
                        }

                        if ( !tag_text.endsWith( "/" ) )
                        {
                            tag_array ~= tag;
                        }
                    }
                }

                tag_character_index = post_tag_character_index;
            }
            else
            {
                if ( tag_array.length > 0 )
                {
                    tag_array[ $ - 1 ].Text ~= text[ tag_character_index ];
                }
            }
        }
    }
}

// ~~

class BUFFER
{
    // -- ATTRIBUTES

    BUFFER
        PriorBuffer,
        NextBuffer;
    long
        FileByteIndex,
        PostFileByteIndex;
    ubyte[ 1024 ]
        ByteArray;
}

// ~~

class POINT_FIELD
{
    // -- ATTRIBUTES

    string
        Name,
        Type;
    bool
        IsReal;
    double
        Scale = 1.0,
        MinimumReal,
        MaximumReal;
    long
        MinimumInteger,
        MaximumInteger,
        BitCount;
    long[]
        ByteCountArray,
        ByteIndexArray;
    long
        ChunkIndex,
        BitIndex;
}

// ~~

class E57_FILE
{
    // -- CONSTANTS

    enum
        MaximumBufferCount = 8;

    // -- ATTRIBUTES

    File
        File_;
    long
        FileByteCount,
        DocumentByteIndex,
        DocumentByteCount;
    BUFFER
        FirstBuffer;
    long
        BufferCount;
    string
        DocumentText;
    DOCUMENT
        Document;
    bool
        IsCompressed;
    long
        PointCount,
        VectorByteIndex,
        VectorIndexDepth,
        VectorByteCount,
        VectorChunkCount;
    long[]
        VectorChunkByteCountArray;
    long
        PointBitCount,
        PointIndex;
    POINT_FIELD[]
        PointFieldArray;
    long
        XPointFieldIndex,
        YPointFieldIndex,
        ZPointFieldIndex,
        RPointFieldIndex,
        GPointFieldIndex,
        BPointFieldIndex,
        IPointFieldIndex;

    // -- CONSTRUCTORS

    long GetFileByteIndex(
        long byte_index
        )
    {
        return byte_index + ( byte_index / 1020 ) * 4;
    }

    // ~~

    long GetByteIndex(
        long file_byte_index
        )
    {
        return file_byte_index - ( file_byte_index >> 10 ) * 4;
    }

    // ~~

    void WriteDocument(
        string document_file_path
        )
    {
        WriteText( document_file_path, DocumentText.strip() ~ "\n" );
    }

    // ~~

    void WriteImages(
        string image_folder_path
        )
    {
        double
            rotation_w,
            rotation_x,
            rotation_y,
            rotation_z,
            translation_x,
            translation_y,
            translation_z;
        long
            image_count,
            image_file_byte_index,
            image_file_byte_count;
        string
            image_file_path;
        ubyte[]
            image_byte_array;
        TAG
            images_2D_tag,
            jpeg_image_tag,
            pinhole_representation_tag,
            pose_tag,
            rotation_tag,
            rotation_x_tag,
            rotation_y_tag,
            rotation_z_tag,
            rotation_w_tag,
            translation_tag,
            translation_x_tag,
            translation_y_tag,
            translation_z_tag;

        if ( Document.FindTag( images_2D_tag, "images2D" ) )
        {
            foreach ( sub_tag; images_2D_tag.SubTagArray )
            {
                translation_x = 0.0;
                translation_y = 0.0;
                translation_z = 0.0;

                rotation_w = 0.0;
                rotation_x = 0.0;
                rotation_y = 0.0;
                rotation_z = 0.0;

                if ( sub_tag.FindTag( pose_tag, "pose" )
                     && pose_tag.FindTag( translation_tag, "translation" )
                     && translation_tag.FindTag( translation_x_tag, "x" )
                     && translation_tag.FindTag( translation_y_tag, "y" )
                     && translation_tag.FindTag( translation_z_tag, "z" )
                     && pose_tag.FindTag( rotation_tag, "rotation" )
                     && rotation_tag.FindTag( rotation_w_tag, "w" )
                     && rotation_tag.FindTag( rotation_x_tag, "x" )
                     && rotation_tag.FindTag( rotation_y_tag, "y" )
                     && rotation_tag.FindTag( rotation_z_tag, "z" ) )
                {
                    translation_x = translation_x_tag.Text.GetReal64();
                    translation_y = translation_y_tag.Text.GetReal64();
                    translation_z = translation_z_tag.Text.GetReal64();

                    rotation_w = rotation_w_tag.Text.GetReal64();
                    rotation_x = rotation_x_tag.Text.GetReal64();
                    rotation_y = rotation_y_tag.Text.GetReal64();
                    rotation_z = rotation_z_tag.Text.GetReal64();
                }

                if ( sub_tag.FindTag( pinhole_representation_tag, "pinholeRepresentation" )
                     && pinhole_representation_tag.FindTag( jpeg_image_tag, "jpegImage" )
                     && jpeg_image_tag.HasPropertyValue( "fileOffset" )
                     && jpeg_image_tag.HasPropertyValue( "length" ) )
                {
                    image_file_byte_index = jpeg_image_tag.GetPropertyValue( "fileOffset" ).to!long() + 16;
                    image_file_byte_count = jpeg_image_tag.GetPropertyValue( "length" ).to!long();

                    if ( image_count == 0 )
                    {
                        image_file_byte_index += 4;
                    }

                    image_byte_array = ReadByteArray( GetByteIndex( image_file_byte_index ), image_file_byte_count );

                    ++image_count;

                    image_file_path
                        = image_folder_path
                          ~ "image_"
                          ~ image_count.to!string()
                          ~ "_translation_"
                          ~ translation_x.GetText()
                          ~ "_"
                          ~ translation_y.GetText()
                          ~ "_"
                          ~ translation_z.GetText()
                          ~ "_rotation_"
                          ~ rotation_w.GetText()
                          ~ "_"
                          ~ rotation_x.GetText()
                          ~ "_"
                          ~ rotation_y.GetText()
                          ~ "_"
                          ~ rotation_z.GetText()
                          ~ ".jpg";

                    WriteByteArray( image_file_path, image_byte_array );
                }
            }
        }
    }

    // -- OPERATIONS

    void Open(
        string file_path
        )
    {
        File_.open( file_path, "r" );
        FileByteCount = ReadNatural( 16, 8 );
        XPointFieldIndex = -1;
        YPointFieldIndex = -1;
        ZPointFieldIndex = -1;
        RPointFieldIndex = -1;
        GPointFieldIndex = -1;
        BPointFieldIndex = -1;
        IPointFieldIndex = -1;
    }

    // ~~

    BUFFER GetBuffer(
        long file_byte_index
        )
    {
        BUFFER
            buffer,
            last_buffer,
            next_buffer,
            prior_buffer;

        for ( buffer = FirstBuffer;
              buffer !is null;
              buffer = buffer.NextBuffer )
        {
            last_buffer = buffer;

            if ( file_byte_index >= buffer.FileByteIndex
                 && file_byte_index < buffer.PostFileByteIndex )
            {
                if ( FirstBuffer !is buffer )
                {
                    prior_buffer = buffer.PriorBuffer;
                    next_buffer = buffer.NextBuffer;

                    if ( prior_buffer !is null )
                    {
                        prior_buffer.NextBuffer = next_buffer;
                    }

                    if ( next_buffer !is null )
                    {
                        next_buffer.PriorBuffer = prior_buffer;
                    }

                    buffer.PriorBuffer = null;
                    buffer.NextBuffer = FirstBuffer;

                    FirstBuffer.PriorBuffer = buffer;
                    FirstBuffer = buffer;
                }

                return buffer;
            }
        }

        if ( BufferCount < MaximumBufferCount )
        {
            buffer = new BUFFER();
            buffer.PriorBuffer = null;
            buffer.NextBuffer = FirstBuffer;

            if ( FirstBuffer !is null )
            {
                FirstBuffer.PriorBuffer = buffer;
            }
        }
        else
        {
            buffer = last_buffer;
        }

        buffer.FileByteIndex = ( file_byte_index >> 10 ) << 10;
        buffer.PostFileByteIndex = buffer.FileByteIndex + 1024;
        File_.seek( buffer.FileByteIndex );
        File_.rawRead( buffer.ByteArray );
        FirstBuffer = buffer;

        return buffer;
    }

    // ~~

    ubyte ReadByte(
        long byte_index
        )
    {
        long
            file_byte_index;
        BUFFER
            buffer;

        file_byte_index = GetFileByteIndex( byte_index );
        buffer = GetBuffer( file_byte_index );

        return buffer.ByteArray[ file_byte_index - buffer.FileByteIndex ];
    }

    // ~~

    ulong ReadNatural(
        long byte_index,
        long byte_count
        )
    {
        long
            read_byte_index;
        ulong
            natural,
            read_byte;

        natural = 0;

        for ( read_byte_index = 0;
              read_byte_index < byte_count;
              ++read_byte_index )
        {
            read_byte = ReadByte( byte_index + read_byte_index );
            natural |= read_byte << ( read_byte_index << 3 );
        }

        return natural;
    }

    // ~~

    ulong ReadNatural(
        long byte_index,
        long bit_index,
        long bit_count
        )
    {
        long
            bit_offset,
            read_bit_index,
            read_byte_index;
        ubyte
            read_byte;
        ulong
            natural;

        natural = 0;

        for ( read_bit_index = 0;
              read_bit_index < bit_count;
              ++read_bit_index )
        {
            bit_offset = bit_index + read_bit_index;
            read_byte_index = byte_index + ( bit_offset >> 3 );
            read_byte = ReadByte( read_byte_index );

            if ( read_byte & ( 1u << ( bit_offset & 7 ) ) )
            {
                natural |= 1u << read_bit_index;
            }
        }

        return natural;
    }

    // ~~

    void ReadByteArray(
        ubyte[] byte_array,
        long byte_index,
        long byte_count
        )
    {
        long
            read_byte_index;

        for ( read_byte_index = 0;
              read_byte_index < byte_count;
              ++read_byte_index )
        {
            byte_array[ read_byte_index ] = ReadByte( byte_index + read_byte_index );
        }
    }

    // ~~

    ubyte[] ReadByteArray(
        long byte_index,
        long byte_count
        )
    {
        long
            read_byte_index;
        ubyte[]
            byte_array;

        for ( read_byte_index = 0;
              read_byte_index < byte_count;
              ++read_byte_index )
        {
            byte_array ~= ReadByte( byte_index + read_byte_index );
        }

        return byte_array;
    }

    // ~~

    string ReadText(
        long byte_index,
        long byte_count
        )
    {
        long
            read_byte_index;
        string
            text;

        for ( read_byte_index = 0;
              read_byte_index < byte_count;
              ++read_byte_index )
        {
            text ~= cast( char )ReadByte( byte_index + read_byte_index );
        }

        return text;
    }

    // ~~

    void ReadVector(
        )
    {
        long
            point_field_byte_count,
            point_field_byte_index,
            point_field_count,
            point_field_index,
            vector_byte_index,
            vector_chunk_byte_count,
            vector_chunk_count,
            vector_chunk_index;

        vector_byte_index = VectorByteIndex;

        VectorIndexDepth = ReadNatural( vector_byte_index, 8 );
        vector_byte_index += 8;

        VectorByteCount = ReadNatural( vector_byte_index, 8 );
        vector_byte_index += 24;

        while ( vector_byte_index < DocumentByteIndex )
        {
            vector_chunk_count = ReadNatural( vector_byte_index, 2 );
            vector_byte_index += 2;

            vector_chunk_byte_count = ReadNatural( vector_byte_index, 2 ) + 1;
            vector_byte_index += 2;

            VectorChunkByteCountArray ~= vector_chunk_byte_count;

            point_field_count = ReadNatural( vector_byte_index, 2 );
            vector_byte_index += 2;

            point_field_byte_index = vector_byte_index + point_field_count * 2;

            for ( point_field_index = 0;
                  point_field_index < point_field_count;
                  ++point_field_index )
            {
                point_field_byte_count = ReadNatural( vector_byte_index, 2 );
                vector_byte_index += 2;

                PointFieldArray[ point_field_index ].ByteIndexArray ~= point_field_byte_index;
                PointFieldArray[ point_field_index ].ByteCountArray ~= point_field_byte_count;
                point_field_byte_index += point_field_byte_count;
            }

            vector_byte_index = point_field_byte_index;
        }
    }

    // ~~

    void ReadDocument(
        bool points_are_read
        )
    {
        long
            point_field_index;
        string
            point_field_minimum,
            point_field_maximum,
            point_field_name,
            point_field_precision,
            point_field_scale,
            point_field_type;
        POINT_FIELD
            point_field;
        TAG
            points_tag,
            prototype_tag;

        DocumentByteIndex = GetByteIndex( ReadNatural( 24, 8 ) );
        DocumentByteCount = ReadNatural( 32, 8 );
        DocumentText = ReadText( DocumentByteIndex, DocumentByteCount );
        Document = new DOCUMENT();
        Document.SetFromText( DocumentText );

        if ( points_are_read
             && Document.FindTag( points_tag, "points" )
             && points_tag.FindTag( prototype_tag, "prototype" )
             && prototype_tag.GetPropertyValue( "type" ) == "Structure" )
        {
            IsCompressed = ( points_tag.GetPropertyValue( "type" ) == "CompressedVector" );
            PointCount = points_tag.GetPropertyValue( "recordCount" ).to!long();
            VectorByteIndex = GetByteIndex( points_tag.GetPropertyValue( "fileOffset" ).to!long() );
            PointBitCount = 0;

            foreach ( point_field_tag; prototype_tag.SubTagArray )
            {
                point_field_name = point_field_tag.Name;
                point_field_type = point_field_tag.GetPropertyValue( "type" );
                point_field_minimum = point_field_tag.GetPropertyValue( "minimum", "0" );
                point_field_maximum = point_field_tag.GetPropertyValue( "maximum", "0" );
                point_field_scale = point_field_tag.GetPropertyValue( "scale", "1.0" );
                point_field_precision = point_field_tag.GetPropertyValue( "precision" );

                point_field = new POINT_FIELD();
                point_field.Name = point_field_name;
                point_field.Type = point_field_type;
                point_field.IsReal = ( point_field_type == "Float" );
                point_field.Scale = point_field_scale.to!float();

                if ( point_field.IsReal )
                {
                    point_field.MinimumReal = point_field_minimum.to!float();
                    point_field.MaximumReal = point_field_maximum.to!float();

                    if ( point_field_precision == "single" )
                    {
                        point_field.BitCount = 32;
                    }
                    else
                    {
                        point_field.BitCount = 64;
                    }
                }
                else
                {
                    point_field.MinimumInteger = point_field_minimum.to!long();
                    point_field.MaximumInteger = point_field_maximum.to!long();
                    point_field.BitCount = 1;

                    while ( ( 1u << ( point_field.BitCount - 1 ) ) < point_field.MaximumInteger )
                    {
                        ++point_field.BitCount;
                    }
                }

                PointBitCount += point_field.BitCount;
                point_field_index = PointFieldArray.length;
                PointFieldArray ~= point_field;

                if ( point_field_name == "cartesianX" )
                {
                    XPointFieldIndex = point_field_index;
                }
                else if ( point_field_name == "cartesianY" )
                {
                    YPointFieldIndex = point_field_index;
                }
                else if ( point_field_name == "cartesianZ" )
                {
                    ZPointFieldIndex = point_field_index;
                }
                else if ( point_field_name == "colorRed" )
                {
                    RPointFieldIndex = point_field_index;
                }
                else if ( point_field_name == "colorGreen" )
                {
                    GPointFieldIndex = point_field_index;
                }
                else if ( point_field_name == "colorBlue" )
                {
                    BPointFieldIndex = point_field_index;
                }
                else if ( point_field_name == "intensity" )
                {
                    IPointFieldIndex = point_field_index;
                }
            }

            ReadVector();
        }
    }

    // ~~

    float GetPointFieldValue(
        long point_field_index
        )
    {
        POINT_FIELD
            point_field;
        SCALAR
            scalar;

        if ( point_field_index >= 0 )
        {
            point_field = PointFieldArray[ point_field_index ];

            if ( point_field.BitIndex >= point_field.ByteCountArray[ point_field.ChunkIndex ] * 8 )
            {
                ++point_field.ChunkIndex;
                point_field.BitIndex = 0;
            }

            scalar.Natural
                = ReadNatural(
                    point_field.ByteIndexArray[ point_field.ChunkIndex ],
                    point_field.BitIndex,
                    point_field.BitCount
                    );

            point_field.BitIndex += point_field.BitCount;

            if ( point_field.IsReal )
            {
                if ( point_field.BitCount == 32 )
                {
                    return scalar.Real32Array[ 0 ];
                }
                else
                {
                    return scalar.Real64.to!float();
                }
            }
            else
            {
                return
                    ( ( point_field.MinimumInteger + scalar.Natural ).to!double()
                      * point_field.Scale ).to!float();
            }
        }
        else
        {
            return 0.0;
        }
    }

    // ~~

    bool ReadPoint(
        ref POINT point
        )
    {
        if ( PointIndex < PointCount )
        {
            point.PositionVector.X = GetPointFieldValue( XPointFieldIndex );
            point.PositionVector.Y = GetPointFieldValue( YPointFieldIndex );
            point.PositionVector.Z = GetPointFieldValue( ZPointFieldIndex );
            point.ColorVector.X = GetPointFieldValue( RPointFieldIndex );
            point.ColorVector.Y = GetPointFieldValue( GPointFieldIndex );
            point.ColorVector.Z = GetPointFieldValue( BPointFieldIndex );
            point.ColorVector.W = GetPointFieldValue( IPointFieldIndex );

            ++PointIndex;

            return true;
        }
        else
        {
            return false;
        }
    }

    // ~~

    void Close(
        )
    {
        File_.close();
    }
}

// ~~

struct VECTOR_3
{
    // -- ATTRIBUTES

    float
        X = 0.0,
        Y = 0.0,
        Z = 0.0;

    // -- INQUIRIES

    float GetDistance(
        ref VECTOR_3 position_vector
        )
    {
        float
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
        ref VECTOR_3 position_vector,
        float point_distance
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
        ref VECTOR_3 first_vector,
        ref VECTOR_3 second_vector,
        float interpolation_factor
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

    // ~~

    void SetInterpolatedVector(
        ref VECTOR_4 first_vector,
        ref VECTOR_4 second_vector,
        float interpolation_factor
        )
    {
        X = first_vector.X + ( second_vector.X - first_vector.X ) * interpolation_factor;
        Y = first_vector.Y + ( second_vector.Y - first_vector.Y ) * interpolation_factor;
        Z = first_vector.Z + ( second_vector.Z - first_vector.Z ) * interpolation_factor;
        W = first_vector.W + ( second_vector.W - first_vector.W ) * interpolation_factor;
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

    POINT GetTransformedPoint(
        )
    {
        POINT
            transformed_point;

        transformed_point = this;

        transformed_point.PositionVector.Translate(
            PositionOffsetVector.X,
            PositionOffsetVector.Y,
            PositionOffsetVector.Z
            );

        transformed_point.PositionVector.Scale(
            PositionScalingVector.X,
            PositionScalingVector.Y,
            PositionScalingVector.Z
            );

        if ( PositionRotationVector.Z != 0.0 )
        {
            transformed_point.PositionVector.RotateAroundZ(
                PositionRotationVector.Z.cos(),
                PositionRotationVector.Z.sin()
                );
        }

        if ( PositionRotationVector.X != 0.0 )
        {
            transformed_point.PositionVector.RotateAroundX(
                PositionRotationVector.X.cos(),
                PositionRotationVector.X.sin()
                );
        }

        if ( PositionRotationVector.Y != 0.0 )
        {
            transformed_point.PositionVector.RotateAroundY(
                PositionRotationVector.Y.cos(),
                PositionRotationVector.Y.sin()
                );
        }

        transformed_point.PositionVector.Translate(
            PositionTranslationVector.X,
            PositionTranslationVector.Y,
            PositionTranslationVector.Z
            );

        transformed_point.ColorVector.Translate(
            ColorOffsetVector.X,
            ColorOffsetVector.Y,
            ColorOffsetVector.Z,
            ColorOffsetVector.W
            );

        transformed_point.ColorVector.Scale(
            ColorScalingVector.X,
            ColorScalingVector.Y,
            ColorScalingVector.Z,
            ColorScalingVector.W
            );

        transformed_point.ColorVector.Translate(
            ColorTranslationVector.X,
            ColorTranslationVector.Y,
            ColorTranslationVector.Z,
            ColorTranslationVector.W
            );

        return transformed_point;
    }

    // ~~

    long GetCellIndex(
        float one_over_precision
        )
    {
        return PositionVector.GetCellIndex( one_over_precision );
    }

    // ~~

    long GetPointCount(
        POINT point,
        float point_distance
        )
    {
        return PositionVector.GetPointCount( point.PositionVector, point_distance );
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
        POINT point
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

    void SetInterpolatedPoint(
        ref POINT first_point,
        ref POINT second_point,
        float interpolation_factor
        )
    {
        PositionVector.SetInterpolatedVector( first_point.PositionVector, second_point.PositionVector, interpolation_factor );
        ColorVector.SetInterpolatedVector( first_point.ColorVector, second_point.ColorVector, interpolation_factor );
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

    string GetLine(
        string line_format
        )
    {
        return
            line_format
                .replace( "{{point_count}}", PointArray.length.GetText() )
                .replace( "\\n", "\n" )
                .replace( "\\r", "\r" )
                .replace( "\\t", "\t" );
    }

    // ~~

    string GetLine(
        ref POINT point,
        string line_format
        )
    {
        return
            GetLine(
                line_format
                    .replace( "{{x}}", ( -point.PositionVector.X ).GetText() )
                    .replace( "{{y}}", ( -point.PositionVector.Y ).GetText() )
                    .replace( "{{z}}", ( -point.PositionVector.Z ).GetText() )
                    .replace( "{{X}}", point.PositionVector.X.GetText() )
                    .replace( "{{Y}}", point.PositionVector.Y.GetText() )
                    .replace( "{{Z}}", point.PositionVector.Z.GetText() )
                    .replace( "{{R}}", point.ColorVector.X.GetText() )
                    .replace( "{{G}}", point.ColorVector.Y.GetText() )
                    .replace( "{{B}}", point.ColorVector.Z.GetText() )
                    .replace( "{{I}}", point.ColorVector.W.GetText() )
                );
    }

    // ~~

    void WriteCloudFile(
        string file_path,
        string header_format,
        string line_format,
        string footer_format
        )
    {
        string
            footer,
            header,
            line;
        File
            file;

        try
        {
            file.open( file_path, "w" );
            file.write( GetLine( header_format ) );

            foreach ( ref point; PointArray )
            {
                file.write( GetLine( point, line_format ) );
            }

            file.write( GetLine( footer_format ) );
            file.close();
        }
        catch ( Exception exception )
        {
            Abort( "Can't write file : " ~ file_path, exception );
        }
    }

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
                    point.PositionVector.X.GetText(),
                    " ",
                    point.PositionVector.Y.GetText(),
                    " ",
                    point.PositionVector.Z.GetText(),
                    "\n"
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
                    point.PositionVector.X.GetText(),
                    " ",
                    point.PositionVector.Y.GetText(),
                    " ",
                    point.PositionVector.Z.GetText(),
                    " ",
                    point.ColorVector.W.GetText(),
                    " ",
                    point.ColorVector.X.GetText(),
                    " ",
                    point.ColorVector.Y.GetText(),
                    " ",
                    point.ColorVector.Z.GetText(),
                    "\n"
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

    void WritePcfCloudFile(
        string file_path
        )
    {
        pcf.cloud.CELL
            cell;
        pcf.cloud.CLOUD
            cloud;
        pcf.scan.SCAN
            scan;

        cloud = new pcf.cloud.CLOUD();

        scan = new pcf.scan.SCAN();
        scan.PointCount = PointArray.length;
        scan.ColumnCount = scan.PointCount;
        scan.RowCount = 1;
        scan.ComponentArray ~= new pcf.component.COMPONENT( "X", pcf.compression.COMPRESSION.Discretization, 8, 0.001, 0.0, 0.0 );
        scan.ComponentArray ~= new pcf.component.COMPONENT( "Y", pcf.compression.COMPRESSION.Discretization, 8, 0.001, 0.0, 0.0 );
        scan.ComponentArray ~= new pcf.component.COMPONENT( "Z", pcf.compression.COMPRESSION.Discretization, 8, 0.001, 0.0, 0.0 );
        scan.ComponentArray ~= new pcf.component.COMPONENT( "I", pcf.compression.COMPRESSION.Discretization, 8, 1.0 / 255.0, 0.0, 1.0 );
        scan.ComponentArray ~= new pcf.component.COMPONENT( "R", pcf.compression.COMPRESSION.Discretization, 8, 1.0, 0.0, 255.0 );
        scan.ComponentArray ~= new pcf.component.COMPONENT( "G", pcf.compression.COMPRESSION.Discretization, 8, 1.0, 0.0, 255.0 );
        scan.ComponentArray ~= new pcf.component.COMPONENT( "B", pcf.compression.COMPRESSION.Discretization, 8, 1.0, 0.0, 255.0 );

        foreach ( ref point; PointArray )
        {
            cell = scan.GetCell( point.PositionVector.X, point.PositionVector.Y, point.PositionVector.Z );
            cell.AddComponentValue( scan.ComponentArray, 0, point.PositionVector.X );
            cell.AddComponentValue( scan.ComponentArray, 1, point.PositionVector.Y );
            cell.AddComponentValue( scan.ComponentArray, 2, point.PositionVector.Z );
            cell.AddComponentValue( scan.ComponentArray, 3, point.ColorVector.W );
            cell.AddComponentValue( scan.ComponentArray, 4, point.ColorVector.X );
            cell.AddComponentValue( scan.ComponentArray, 5, point.ColorVector.Y );
            cell.AddComponentValue( scan.ComponentArray, 6, point.ColorVector.Z );
            ++cell.PointCount;

            cloud.ScanArray ~= scan;
        }

        cloud.WritePcfFile( file_path );
    }

    // -- OPERATIONS

    void AddPoint(
        POINT point
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
        POINT point
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
        POINT point
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

    // ~~

    void SetFromMesh(
        MESH mesh
        )
    {
        float
            first_interpolation_factor,
            second_interpolation_factor;
        long
            first_edge_point_count,
            first_point_count,
            first_point_index,
            point_index_index,
            second_edge_point_count,
            second_point_count,
            second_point_index;
        POINT
            first_interpolated_point,
            first_point,
            point,
            second_interpolated_point,
            second_point,
            third_point;

        for ( point_index_index = 0;
              point_index_index + 2 < mesh.PointIndexArray.length;
              point_index_index += 3 )
        {
            first_point = mesh.PointArray[ mesh.PointIndexArray[ point_index_index ] ];
            second_point = mesh.PointArray[ mesh.PointIndexArray[ point_index_index + 1 ] ];
            third_point = mesh.PointArray[ mesh.PointIndexArray[ point_index_index + 2 ] ];

            first_edge_point_count = first_point.GetPointCount( second_point, Precision );
            second_edge_point_count = first_point.GetPointCount( third_point, Precision );
            first_point_count = max( first_edge_point_count, second_edge_point_count );

            for ( first_point_index = 0;
                  first_point_index <= first_point_count;
                  ++first_point_index )
            {
                first_interpolation_factor = first_point_index.to!float() / first_point_count.to!float();

                first_interpolated_point.SetInterpolatedPoint(
                    first_point,
                    second_point,
                    first_interpolation_factor
                    );

                second_interpolated_point.SetInterpolatedPoint(
                    first_point,
                    third_point,
                    first_interpolation_factor
                    );

                second_point_count = first_interpolated_point.GetPointCount( second_interpolated_point, Precision );

                for ( second_point_index = 0;
                      second_point_index <= second_point_count;
                      ++second_point_index )
                {
                    second_interpolation_factor = second_point_index.to!float() / second_point_count.to!float();

                    point.SetInterpolatedPoint(
                        first_interpolated_point,
                        second_interpolated_point,
                        second_interpolation_factor
                        );

                    AddPoint( point );
                }
            }
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
                        "v ",
                        point.PositionVector.X.GetText(),
                        " ",
                        point.PositionVector.Y.GetText(),
                        " ",
                        point.PositionVector.Z.GetText(),
                        " ",
                        point.ColorVector.W.GetText(),
                        " ",
                        point.ColorVector.X.GetText(),
                        " ",
                        point.ColorVector.Y.GetText(),
                        " ",
                        point.ColorVector.Z.GetText(),
                        "\n"
                        );
                }
            }
            else
            {
                foreach ( ref point; PointArray )
                {
                    file.write(
                        "v ",
                        point.PositionVector.X.GetText(),
                        " ",
                        point.PositionVector.Y.GetText(),
                        " ",
                        point.PositionVector.Z.GetText(),
                        "\n"
                        );
                }
            }

            if ( PointIndexArray.length > 0 )
            {
                for ( point_index_index = 0;
                      point_index_index + 2 < PointIndexArray.length;
                      point_index_index += 3 )
                {
                    file.write(
                        "f ",
                        ( PointIndexArray[ point_index_index ] + 1 ).GetText(),
                        " ",
                        ( PointIndexArray[ point_index_index + 1 ] + 1 ).GetText(),
                        " ",
                        ( PointIndexArray[ point_index_index + 2 ] + 1 ).GetText(),
                        "\n"
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
            part_index,
            point_index_index;
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

        first_point_index = PointArray.length;

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

                    PointArray ~= point.GetTransformedPoint();
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

                    for ( point_index_index = 1;
                          point_index_index + 1 < point_index_array.length;
                          ++point_index_index )
                    {
                        PointIndexArray ~= point_index_array[ 0 ];
                        PointIndexArray ~= point_index_array[ point_index_index ];
                        PointIndexArray ~= point_index_array[ point_index_index + 1 ];
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
        POINT point
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

double GetReal64(
    string text
    )
{
    if ( text == "" )
    {
        return 0.0;
    }
    else
    {
        return text.to!double();
    }
}

// ~~

string GetText(
    long integer
    )
{
    return integer.to!string();
}

// ~~

string GetText(
    float real_
    )
{
    string
        text;

    text = format( "%f", real_ );

    if ( text.indexOf( '.' ) >= 0 )
    {
        while ( text.endsWith( '0') )
        {
            text = text[ 0 .. $ - 1 ];
        }

        if ( text.endsWith( '.' ) )
        {
            text = text[ 0 .. $ - 1 ];
        }
    }

    if ( text == "-0" )
    {
        return "0";
    }
    else
    {
        return text;
    }
}

// ~~

string GetText(
    double real_
    )
{
    string
        text;

    text = format( "%f", real_ );

    if ( text.indexOf( '.' ) >= 0 )
    {
        while ( text.endsWith( '0') )
        {
            text = text[ 0 .. $ - 1 ];
        }

        if ( text.endsWith( '.' ) )
        {
            text = text[ 0 .. $ - 1 ];
        }
    }

    if ( text == "-0" )
    {
        return "0";
    }
    else
    {
        return text;
    }
}

// ~~

void WriteByteArray(
    string file_path,
    ubyte[] file_byte_array
    )
{
    writeln( "Writing file : ", file_path );

    try
    {
        file_path.write( file_byte_array );
    }
    catch ( Exception exception )
    {
        Abort( "Can't write file : " ~ file_path, exception );
    }
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
    float precision
    )
{
    if ( Grid is null
         && HasCloud()
         && precision > 0.0 )
    {
        Grid = new GRID( precision );
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
         && Grid !is null )
    {
        Mesh = new MESH();
        Mesh.SetFromGrid( Grid );
    }

    Cloud = null;
    Grid = null;

    return Mesh !is null;
}

// ~~

void MakeCloudOrGrid(
    float precision
    )
{
    if ( precision <= 0.0 )
    {
        if ( !HasCloud() )
        {
            Cloud = new CLOUD();
        }

        Grid = null;
        Mesh = null;
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

        if ( !HasGrid( precision ) )
        {
            Grid = new GRID( precision );
        }

        Cloud = null;
        Mesh = null;
    }
}

// ~~

void AddPoint(
    POINT point
    )
{
    if ( Cloud !is null )
    {
        Cloud.AddPoint( point.GetTransformedPoint() );
    }
    else if ( Grid !is null )
    {
        Grid.AddPoint( point.GetTransformedPoint() );
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

    MakeCloudOrGrid( precision );
    SetLineFormat( line_format );

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

// ~~

void ReadXyzCloudFile(
    string file_path,
    float precision
    )
{
    POINT
        point;

    writeln( "Reading file : ", file_path, " ", precision );

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

void ReadPcfCloudFile(
    string file_path,
    float precision
    )
{
    ulong
        b_component_index,
        g_component_index,
        i_component_index,
        r_component_index,
        x_component_index,
        y_component_index,
        z_component_index;
    pcf.cloud.CLOUD
        cloud;
    POINT
        point;

    writeln( "Reading file : ", file_path, " ", precision );

    MakeCloudOrGrid( precision );

    cloud = new pcf.cloud.CLOUD();
    cloud.ReadPcfFile( file_path );

    foreach ( scan; cloud.ScanArray )
    {
        x_component_index = scan.GetComponentIndex( "X" );
        y_component_index = scan.GetComponentIndex( "Y" );
        z_component_index = scan.GetComponentIndex( "Z" );
        r_component_index = scan.GetComponentIndex( "R" );
        g_component_index = scan.GetComponentIndex( "G" );
        b_component_index = scan.GetComponentIndex( "B" );
        i_component_index = scan.GetComponentIndex( "I" );

        foreach ( cell; scan.CellMap.byValue )
        {
            foreach ( point_index; 0 .. cell.PointCount )
            {
                point.SetNull();

                if ( x_component_index >= 0 )
                {
                    point.PositionVector.X = cell.GetComponentValue( point_index, scan.ComponentArray, x_component_index );
                }

                if ( y_component_index >= 0 )
                {
                    point.PositionVector.Y = cell.GetComponentValue( point_index, scan.ComponentArray, y_component_index );
                }

                if ( z_component_index >= 0 )
                {
                    point.PositionVector.Z = cell.GetComponentValue( point_index, scan.ComponentArray, z_component_index );
                }

                if ( r_component_index >= 0 )
                {
                    point.ColorVector.X = cell.GetComponentValue( point_index, scan.ComponentArray, r_component_index );
                }

                if ( g_component_index >= 0 )
                {
                    point.ColorVector.Y = cell.GetComponentValue( point_index, scan.ComponentArray, g_component_index );
                }

                if ( b_component_index >= 0 )
                {
                    point.ColorVector.Z = cell.GetComponentValue( point_index, scan.ComponentArray, b_component_index );
                }

                if ( i_component_index >= 0 )
                {
                    point.ColorVector.W = cell.GetComponentValue( point_index, scan.ComponentArray, i_component_index );
                }

                AddPoint( point );
            }
        }
    }

    if ( Grid !is null )
    {
        Grid.SetAveragePoint();
    }
}

// ~~

void ReadE57CloudFile(
    string file_path,
    float precision
    )
{
    bool
        points_are_read;
    E57_FILE
        e57_file;
    POINT
        point;

    writeln( "Reading file : ", file_path, " ", precision );

    MakeCloudOrGrid( precision );

    e57_file = new E57_FILE();
    e57_file.Open( file_path );
    e57_file.ReadDocument( true );

    if ( points_are_read )
    {
        while ( e57_file.ReadPoint( point ) )
        {
            AddPoint( point.GetTransformedPoint() );
        }
    }

    e57_file.Close();
}

// ~~

void ExtractE57CloudFileDocument(
    string file_path,
    string document_file_path
    )
{
    E57_FILE
        e57_file;

    writeln( "Extract document : ", file_path, " ", document_file_path );

    e57_file = new E57_FILE();
    e57_file.Open( file_path );
    e57_file.ReadDocument( false );
    e57_file.WriteDocument( document_file_path );
    e57_file.Close();
}

// ~~

void ExtractE57CloudFileImages(
    string file_path,
    string image_folder_path
    )
{
    E57_FILE
        e57_file;

    writeln( "Extract images : ", file_path, " ", image_folder_path );

    e57_file = new E57_FILE();
    e57_file.Open( file_path );
    e57_file.ReadDocument( false );
    e57_file.WriteImages( image_folder_path );
    e57_file.Close();
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

void SampleMesh(
    float precision
    )
{
    writeln( "Sampling mesh : ", precision );

    Grid = new GRID( precision );
    Grid.SetFromMesh( Mesh );
    Mesh = null;
    Cloud = null;
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

    Grid = new GRID( precision );
    Grid.SetFromCloud( Cloud );
    Cloud = null;
}

// ~~

void WriteCloudFile(
    string file_path,
    string header_format,
    string line_format,
    string footer_format
    )
{
    writeln( "Writing file : ", file_path );

    Cloud.WriteCloudFile( file_path, header_format, line_format, footer_format );
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

void WritePcfCloudFile(
    string file_path
    )
{
    writeln( "Writing file : ", file_path );

    Cloud.WritePcfCloudFile( file_path );
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
        else if ( option == "--read-pcf-cloud"
                  && argument_array.length >= 3
                  && IsReal( argument_array[ 1 ] ) )
        {
            ReadPcfCloudFile(
                argument_array[ 0 ],
                argument_array[ 1 ].to!float()
                );

            argument_array = argument_array[ 2 .. $ ];
        }
        else if ( option == "--read-e57-cloud"
                  && argument_array.length >= 2
                  && IsReal( argument_array[ 1 ] ) )
        {
            ReadE57CloudFile(
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
        else if ( option == "--extract-e57-cloud-document"
                  && argument_array.length >= 2
                  && argument_array[ 1 ].endsWith( ".xml" ) )
        {
            ExtractE57CloudFileDocument(
                argument_array[ 0 ],
                argument_array[ 1 ]
                );

            argument_array = argument_array[ 2 .. $ ];
        }
        else if ( option == "--extract-e57-cloud-images"
                  && argument_array.length >= 1
                  && argument_array[ 1 ].endsWith( '/' ) )
        {
            ExtractE57CloudFileImages(
                argument_array[ 0 ],
                argument_array[ 1 ]
                );

            argument_array = argument_array[ 2 .. $ ];
        }
        else if ( option == "--sample"
                  && argument_array.length >= 1
                  && IsReal( argument_array[ 0 ] )
                  && HasMesh() )
        {
            SampleMesh(
                argument_array[ 0 ].to!float(),
                );

            argument_array = argument_array[ 1 .. $ ];
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
        else if ( option == "--write-cloud"
                  && argument_array.length >= 4
                  && HasCloud() )
        {
            WriteCloudFile(
                argument_array[ 0 ],
                argument_array[ 1 ],
                argument_array[ 2 ],
                argument_array[ 3 ]
                );

            argument_array = argument_array[ 4 .. $ ];
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
        else if ( option == "--write-pcf-cloud"
                  && argument_array.length >= 1
                  && HasCloud() )
        {
            WritePcfCloudFile( argument_array[ 0 ] );

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
        writeln( "    nebula [options]" );
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
        writeln( "    --read-e57-cloud <file path> <precision>" );
        writeln( "    --read-pcf-cloud <file path> <precision>" );
        writeln( "    --read-obj-cloud <file path> <precision>" );
        writeln( "    --read-obj-mesh <file path>" );
        writeln( "    --extract-e57-cloud-document <file path> <xml file path>" );
        writeln( "    --extract-e57-cloud-images <file path> <jpeg folder path>/" );
        writeln( "    --sample <precision>" );
        writeln( "    --translate <x> <y> <z>" );
        writeln( "    --scale <x> <y> <z>" );
        writeln( "    --rotate-x <degree angle>" );
        writeln( "    --rotate-y <degree angle>" );
        writeln( "    --rotate-z <degree angle>" );
        writeln( "    --decimate <precision>" );
        writeln( "    --write-cloud <header format> <line format> <footer format>" );
        writeln( "    --write-xyz-cloud <file path>" );
        writeln( "    --write-pts-cloud <file path>" );
        writeln( "    --write-obj-mesh <file path>" );
        writeln( "Examples :" );
        writeln( "    nebula --read-cloud cloud.xyz 0 0 3 3 \"\" xZY --write-xyz-cloud flipped_cloud.xyz" );
        writeln( "    nebula --read-cloud cloud.pts 0 1 7 7 \"\" xZYIRGB --write-pts-cloud flipped_cloud.pts" );
        writeln( "    nebula --read-pts-cloud cloud.pts 0 --write-xyz-cloud converted_cloud.xyz" );
        writeln( "    nebula --read-pts-cloud cloud.pts 0 --scale 2 2 2 --rotate-z 45 --write-pts-cloud transformed_cloud.pts" );
        writeln( "    nebula --read-xyz-cloud cloud.xyz 0 --position-scaling 2 2 2 --read-xyz-cloud cloud.xyz --write-xyz-cloud merged_clouds.xyz" );
        writeln( "    nebula --read-pts-cloud cloud.pts 0.01 --write-pts-cloud decimated_cloud.pts" );
        writeln( "    nebula --read-pts-cloud cloud.pts 0.01 --write-obj-mesh triangulated_cloud.obj" );
        writeln( "    nebula --read-obj-mesh mesh.obj --sample 0.1 --write-xyz-cloud sampled_cloud.xyz" );
        Abort( "Invalid arguments : " ~ argument_array.to!string() );
    }
}
