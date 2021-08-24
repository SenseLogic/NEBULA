# Binary Cloud Format

## Goals

*   Simple
*   Compact
*   Extensible

## Sections

```
CLOUD
    Tag : UINT8[ 3 ]    // BCF
    Version : UINT16
    DocumentByteCount : UINT32
    DocumentByteArray : UINT8[ DocumentByteCount ]
    ScanCount : UINT16
    ScanArray : SCAN[]

SCAN
    DocumentByteCount : UINT32
    DocumentByteArray : UINT8[ DocumentByteCount ]
    CameraPositionVector : FLOAT64[ 3 ]
    CameraXAxisVector : FLOAT64[ 3 ]
    CameraYAxisVector : FLOAT64[ 3 ]
    CameraZAxisVector : FLOAT64[ 3 ]
    ComponentCount : UINT16
    ComponentArray : COMPONENT[ ComponentCount ]
    PointCount : UINT64
    PointArray : POINT[ PointCount ]

COMPONENT
    Type : UINT8    // X Y Z R G B I
    BitCount : UINT8    // multiple of 8
    Scaling : FLOAT64    // 0.001 by default

X24_Y24_Z24_R8_G8_B8_I8_POINT
    PositionXComponentLowByte : UINT8
    PositionYComponentLowByte : UINT8
    PositionZComponentLowByte : UINT8
    ColorRedComponentLowByte : UINT8
    ColorGreenComponentLowByte : UINT8
    ColorBlueComponentLowByte : UINT8
    IntensityComponentLowByte : UINT8
    PositionXComponentMediumByte : UINT8
    PositionYComponentMediumByte : UINT8
    PositionZComponentMediumByte : UINT8
    PositionXComponentHighByte : UINT8
    PositionYComponentHighByte : UINT8
    PositionZComponentHighByte : UINT8
```
