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
nebula [options]
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
--read-e57-cloud <file path> <precision> : read an E57 point cloud
--read-obj-cloud <file path> <precision> : read an OBJ point cloud
--read-obj-mesh <file path> : read an OBJ mesh
--extract-e57-cloud-document <file path> <xml file path> : extract the E57 point cloud document
--extract-e57-cloud-images <file path> <jpeg folder path>/ : extract the E57 point cloud images
--sample <precision> : sample mesh
--translate <x> <y> <z> : translate the point cloud
--scale <x> <y> <z> : translate the point cloud
--rotate-x <degree angle> : rotate the point cloud around the X axis
--rotate-y <degree angle> : rotate the point cloud around the Y axis
--rotate-z <degree angle> : rotate the point cloud around the Z axis
--decimate <precision> : decimate the point cloud
--write-cloud <header format> <line format> <footer format>
--write-xyz-cloud <file path> : write an XYZ point cloud
--write-pts-cloud <file path> : write a PTS point cloud
--write-obj-mesh <file path> : write an OBJ mesh
```

### Input line format

```
_ : ignored
x : -X
y : -Y
z : -Z
X : +X
Y : +Y
Z : +Z
R : red
G : green
B : blue
I : intensity
```

### Output line format

```
\n : line feed character
\r : carriage return character
\t : tabulation character
{{point_count}} : point count
{{x}} : -X
{{y}} : -Y
{{z}} : -Z
{{X}} : +X
{{Y}} : +Y
{{Z}} : +Z
{{R}} : red
{{G}} : green
{{B}} : blue
{{I}} : intensity
```

## Examples

```bash
nebula --read-cloud cloud.xyz 0 0 3 3 "" xZY --write-xyz-cloud flipped_cloud.xyz
nebula --read-cloud cloud.pts 0 1 7 7 "" xZYIRGB --write-pts-cloud flipped_cloud.pts
nebula --read-pts-cloud cloud.pts 0 --write-xyz-cloud converted_cloud.xyz
nebula --read-pts-cloud cloud.pts 0 --scale 2 2 2 --rotate-z 45 --write-pts-cloud transformed_cloud.pts
nebula --read-xyz-cloud cloud.xyz 0 --position-scaling 2 2 2 --read-xyz-cloud cloud.xyz --write-xyz-cloud merged_clouds.xyz
nebula --read-pts-cloud cloud.pts 0.01 --write-pts-cloud decimated_cloud.pts
nebula --read-pts-cloud cloud.pts 0.01 --write-obj-mesh triangulated_cloud.obj
nebula --read-obj-mesh mesh.obj --sample 0.1 --write-xyz-cloud sampled_cloud.xyz
```

![](https://github.com/senselogic/NEBULA/blob/master/SCREENSHOT/bunny.png)
![](https://github.com/senselogic/NEBULA/blob/master/SCREENSHOT/decimated_bunny.png)
![](https://github.com/senselogic/NEBULA/blob/master/SCREENSHOT/triangulated_bunny.png)

![](https://github.com/senselogic/NEBULA/blob/master/SCREENSHOT/teapot.png)
![](https://github.com/senselogic/NEBULA/blob/master/SCREENSHOT/sampled_teapot.png)

## Limitations

*   Incomplete support of the E57 file format.

## Version

1.0

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU Lesser General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
