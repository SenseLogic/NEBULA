#!/bin/sh
set -x
../nebula --read IN/triangle.xyz 0 0 3 3 "" xZY --write-xyz OUT/flipped_xyz_triangle.xyz
../nebula --read IN/triangle.pts 0 1 3 7 "" xZYIRGB --write-pts OUT/flipped_pts_triangle.pts
../nebula --read IN/triangle.pts 0 1 3 7 "" xZYIRGB --decimate 1 --write-obj OUT/triangulated_flipped_pts_triangle.obj
../nebula --read-pts IN/triangle.pts 0 --write-xyz OUT/converted_pts_triangle.xyz
../nebula --read-pts IN/triangle.pts 1 --write-pts OUT/decimated_pts_triangle.pts
../nebula --read-pts IN/triangle.pts 1 --write-obj OUT/triangulated_pts_triangle.obj
../nebula --read-xyz IN/triangle.xyz 1 --write-xyz OUT/decimated_xyz_triangle.xyz
../nebula --read-xyz IN/triangle.xyz 1 --write-obj OUT/triangulated_xyz_triangle.obj
../nebula --read-xyz IN/cube.xyz 0 --position-scaling 2 2 2 --read-xyz IN/cube.xyz 0 --write-xyz OUT/merged_xyz_cubes.xyz
../nebula --read-xyz IN/cube.xyz 1 --position-scaling 2 2 2 --read-xyz IN/cube.xyz 1 --write-xyz OUT/decimated_merged_xyz_cubes.xyz
../nebula --read-xyz IN/cube.xyz 1 --position-scaling 2 2 2 --read-xyz IN/cube.xyz 1 --write-obj OUT/triangulated_merged_xyz_cubes.obj
../nebula --read-xyz IN/cube.xyz 0 --scale 1 2 3 --write-xyz OUT/scaled_xyz_cube.xyz
../nebula --read-xyz IN/cube.xyz 0 --scale 2 2 2 --rotate-z 45 --write-xyz OUT/rotated_scaled_xyz_cube.xyz
../nebula --read-xyz IN/cube.xyz 1 --write-xyz OUT/decimated_xyz_cube.xyz
../nebula --read-xyz IN/cube.xyz 1 --write-obj OUT/triangulated_xyz_cube.obj
../nebula --read-pts IN/bunny.pts 0.01 --write-xyz OUT/decimated_pts_bunny.xyz
../nebula --read-pts IN/bunny.pts 0.01 --write-obj OUT/triangulated_pts_bunny.obj
../nebula --read-pts IN/bunny_2.pts 0.01 --write-xyz OUT/decimated_pts_bunny_2.xyz
../nebula --read-pts IN/bunny_2.pts 0.01 --write-obj OUT/triangulated_pts_bunny_2.obj
../nebula --read-pts IN/bunny_3.pts 0.01 --write-xyz OUT/decimated_pts_bunny_3.xyz
../nebula --read-pts IN/bunny_3.pts 0.01 --write-obj OUT/triangulated_pts_bunny_3.obj
