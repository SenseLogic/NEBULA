dmd -O -m64 -ofnebula.exe nebula.d PCF/base.d PCF/buffer.d PCF/cell.d PCF/cell_position_vector.d PCF/cloud.d PCF/component.d PCF/compression.d PCF/image.d PCF/property.d PCF/scalar.d PCF/scan.d PCF/stream.d PCF/vector_3.d PCF/vector_4.d
del /q *.obj
del /q *.pdb
pause
