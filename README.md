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
--read-cloud <file path> <precision> <skipped line count> <minimum field count> <maximum field count> <line prefix> <line format> : read a point cloud
--read-xyz-cloud <file path> <precision> : read an XYZ point cloud
--read-pts-cloud <file path> <precision> : read a PTS point cloud
--read-obj-cloud <file path> <precision> <tessellation> : read an OBJ point cloud
--read-obj-mesh <file path> : read an OBJ mesh
--tessellate <distance> : tessellate mesh
--translate <x> <y> <z> : translate the point cloud
--scale <x> <y> <z> : translate the point cloud
--rotate-x <degree angle> : rotate the point cloud around the X axis
--rotate-y <degree angle> : rotate the point cloud around the Y axis
--rotate-z <degree angle> : rotate the point cloud around the Z axis
--decimate <precision> : decimate the point cloud
--write-xyz-cloud <file path> : write an XYZ point cloud
--write-pts-cloud <file path> : write a PTS point cloud
--write-obj-mesh <file path> : write an OBJ mesh
```

### Line format

```
_ : ignored
x : -X
y : -Y
z : -Z
X : +X
Y : +Y
Z : +Z
I : intensity
R : red
G : green
B : blue
```

## Examples

```bash
nebula --read-cloud cloud.xyz 0 0 3 3 "" xZY --write-xyz-cloud flipped_cloud.xyz
nebula --read-cloud cloud.pts 0 1 7 7 "" xZYIRGB --write-pts-cloud flipped_cloud.pts
nebula --read-pts-cloud cloud.pts 0 --write-xyz-cloud converted_cloud.xyz
nebula --read-pts-cloud cloud.pts 0 --scale 2 2 2 --rotate-z 45 --write-pts-cloud scaled_cloud.pts
nebula --read-xyz-cloud cloud.xyz 0 --position-scaling 2 2 2 --read-xyz-cloud cloud.xyz --write-xyz-cloud merged_clouds.xyz
nebula --read-pts-cloud cloud.pts 0.01 --write-pts-cloud decimated_cloud.pts
nebula --read-pts-cloud cloud.pts 0.01 --write-obj-mesh triangulated_cloud.obj
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
