#!/bin/sh
set -x
../nebula --read-cloud IN/triangle.xyz 0 0 3 3 "" xZY --write-xyz-cloud OUT/flipped_xyz_triangle.xyz
../nebula --read-cloud IN/triangle.pts 0 1 3 7 "" xZYIRGB --write-pts-cloud OUT/flipped_pts_triangle.pts
../nebula --read-cloud IN/triangle.pts 0 1 3 7 "" xZYIRGB --decimate 1 --write-obj-mesh OUT/triangulated_flipped_pts_triangle.obj
../nebula --read-pts-cloud IN/triangle.pts 0 --write-xyz-cloud OUT/converted_pts_triangle.xyz
../nebula --read-pts-cloud IN/triangle.pts 1 --write-pts-cloud OUT/decimated_pts_triangle.pts
../nebula --read-pts-cloud IN/triangle.pts 1 --write-obj-mesh OUT/triangulated_pts_triangle.obj
../nebula --read-xyz-cloud IN/triangle.xyz 1 --write-xyz-cloud OUT/decimated_xyz_triangle.xyz
../nebula --read-xyz-cloud IN/triangle.xyz 1 --write-obj-mesh OUT/triangulated_xyz_triangle.obj
../nebula --read-xyz-cloud IN/cube.xyz 0 --position-scaling 2 2 2 --read-xyz-cloud IN/cube.xyz 0 --write-xyz-cloud OUT/merged_xyz_cubes.xyz
../nebula --read-xyz-cloud IN/cube.xyz 1 --position-scaling 2 2 2 --read-xyz-cloud IN/cube.xyz 1 --write-xyz-cloud OUT/decimated_merged_xyz_cubes.xyz
../nebula --read-xyz-cloud IN/cube.xyz 1 --position-scaling 2 2 2 --read-xyz-cloud IN/cube.xyz 1 --write-obj-mesh OUT/triangulated_merged_xyz_cubes.obj
../nebula --read-xyz-cloud IN/cube.xyz 0 --scale 1 2 3 --write-xyz-cloud OUT/scaled_xyz_cube.xyz
../nebula --read-xyz-cloud IN/cube.xyz 0 --scale 2 2 2 --rotate-z 45 --write-xyz-cloud OUT/rotated_scaled_xyz_cube.xyz
../nebula --read-xyz-cloud IN/cube.xyz 1 --write-xyz-cloud OUT/decimated_xyz_cube.xyz
../nebula --read-xyz-cloud IN/cube.xyz 1 --write-obj-mesh OUT/triangulated_xyz_cube.obj
../nebula --read-pts-cloud IN/bunny.pts 0.01 --write-xyz-cloud OUT/decimated_pts_bunny.xyz
../nebula --read-pts-cloud IN/bunny.pts 0.01 --write-obj-mesh OUT/triangulated_pts_bunny.obj
../nebula --read-pts-cloud IN/bunny_2.pts 0.01 --write-xyz-cloud OUT/decimated_pts_bunny_2.xyz
../nebula --read-pts-cloud IN/bunny_2.pts 0.01 --write-obj-mesh OUT/triangulated_pts_bunny_2.obj
../nebula --read-pts-cloud IN/bunny_3.pts 0.01 --write-xyz-cloud OUT/decimated_pts_bunny_3.xyz
../nebula --read-pts-cloud IN/bunny_3.pts 0.01 --write-obj-mesh OUT/triangulated_pts_bunny_3.obj
../nebula --read-obj-mesh IN/cube.obj --sample 0.1 --write-xyz-cloud OUT/sampled_obj_cube.xyz
../nebula --read-obj-mesh IN/dodecahedron.obj --sample 0.1 --write-xyz-cloud OUT/sampled_obj_dodecahedron.xyz
../nebula --read-obj-mesh IN/teapot.obj --sample 2 --write-xyz-cloud OUT/sampled_obj_teapot.xyz
../nebula --read-obj-mesh IN/bunny.obj --sample 0.01 --write-xyz-cloud OUT/sampled_obj_bunny.xyz
