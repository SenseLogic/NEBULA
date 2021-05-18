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
--position-offset <x> <y> <z> : set the loading position offset
--position-scaling <x> <y> <z> : set the loading position scaling
--position-rotation <x> <y> <z> : set the loading position rotation
--position-translation <x> <y> <z> : set the loading position translation
--color-offset <r> <g> <b> <i> : set the loading color offset
--color-scaling <r> <g> <b> <i> : set the loading color scaling
--color-translation <r> <g> <b> <i> : set the loading color translation
--read <file path> <precision> <skipped line count> <minimum field count> <maximum field count> <line prefix> <line format> : read a point cloud
--read-xyz <file path> <precision> : read an XYZ point cloud
--read-pts <file path> <precision> : read a PTS point cloud
--read-obj <file path> <precision> : read an OBJ point cloud
--translate <x> <y> <z> : translate the point cloud
--scale <x> <y> <z> : translate the point cloud
--rotate-x <degree angle> : rotate the point cloud around the X axis
--rotate-y <degree angle> : rotate the point cloud around the Y axis
--rotate-z <degree angle> : rotate the point cloud around the Z axis
--decimate <precision> : decimate the point cloud
--write-xyz <file path> : write an XYZ point cloud
--write-pts <file path> : write a PTS point cloud
--write-obj <file path> : write an OBJ mesh
```

## Examples

```bash
nebula --read-pts cloud.pts 0.0 --write-xyz cloud.xyz
nebula --read-pts cloud.pts 0.0 --scale 2 2 2 --rotate-z 45 --write-pts scaled_cloud.pts
nebula --read-xyz cloud.xyz 0.0 --position-scaling 2 2 2 --read-xyz cloud.xyz --write-xyz merged_clouds.xyz
nebula --read-pts cloud.pts 0.01 --write-pts decimated_cloud.pts
nebula --read-pts cloud.pts 0.01 --write-obj triangulated_cloud.obj
```

![](https://github.com/senselogic/NEBULA/blob/master/SCREENSHOT/cloud.png)
![](https://github.com/senselogic/NEBULA/blob/master/SCREENSHOT/decimated_cloud.png)
![](https://github.com/senselogic/NEBULA/blob/master/SCREENSHOT/triangulated_cloud.png)

## Version

1.0

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
