![](https://github.com/senselogic/NEBULA/blob/master/LOGO/nebula.png)

# Nebula

Point cloud processor.

## Installation

Install the [DMD 2 compiler](https://dlang.org/download.html) (using the MinGW setup option on Windows).

Build the executable with the following command line :

```bash
dmd -m64 nebula.d
```

## Command line

```bash
nebula <options>
```

### Options

```bash
--position-factor <x> <y> <z> : set the position factor
--position-offset <x> <y> <z> : set the position offset
--color-factor <r> <g> <b> <i> : set the color factor
--color-offset <r> <g> <b> <i> : set the color offset
--read <file path> <skipped line count> <field count> <line prefix> <line format> : read a point cloud
--read-xyz <file path> : read an XYZ point cloud
--read-pts <file path> : read a PTS point cloud
--read-obj <file path> : read an OBJ point cloud
--translate <x> <y> <z> : translate the point cloud
--scale <x> <y> <z> : translate the point cloud
--rotate-x <degree angle> : rotate the point cloud around the X axis
--rotate-y <degree angle> : rotate the point cloud around the Y axis
--rotate-z <degree angle> : rotate the point cloud around the Z axis
--decimate <precision> : decimate the point cloud
--triangulate <precision> : triangulate the point cloud
--write-xyz <file path> : write an XYZ point cloud
--write-pts <file path> : write a PTS point cloud
--write-obj <file path> : write an OBJ mesh
```

## Examples

```bash
nebula --read-pts cloud.pts --write-xyz cloud.xyz
nebula --read-pts cloud.pts --scale 2 2 2 --rotate-z 45 --write-pts scaled_cloud.pts
nebula --read-pts cloud.pts --decimate 0.01 --write-pts decimated_cloud.pts
nebula --read-pts cloud.pts --triangulate 0.01 --write-obj triangulated_mesh.obj
```

## Version

1.0

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
