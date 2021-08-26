# Binary Cloud Format

## Goals

*   Simple : most used fields are easy to parse and access
*   Compact : points and images are stored in binary format
*   Extensible : extra data can be stored in a text document with indexes to a binary buffer

## Sections

```
CLOUD
    Version : UINT32
    NameByteCount : UINT32
    NameByteArray : UINT8[ NameByteCount ]
    TextByteCount : UINT32
    TextByteArray : UINT8[ TextByteCount ]
    DataByteCount : UINT32
    DataByteArray : UINT8[ DataByteCount ]
    ScanCount : UINT32
    ScanArray : SCAN[]

SCAN
    NameByteCount : UINT32
    NameByteArray : UINT8[ NameByteCount ]
    TextByteCount : UINT32
    TextByteArray : UINT8[ TextByteCount ]
    DataByteCount : UINT32
    DataByteArray : UINT8[ DataByteCount ]
    Pose : POSE
    ImageCount : UINT32
    ImageArray : IMAGE[ ImageCount ]
    ComponentCount : UINT32
    ComponentArray : COMPONENT[ ComponentCount ]
    PointCount : UINT64
    PointArray : POINT[ PointCount ]

IMAGE
    NameByteCount : UINT32
    NameByteArray : UINT8[ NameByteCount ]    // spherical left right back front bottom top
    TextByteCount : UINT32
    TextByteArray : UINT8[ TextByteCount ]
    DataByteCount : UINT32
    DataByteArray : UINT8[ DataByteCount ]
    Pose : POSE
    ByteCount : UINT32
    ByteArray : UINT8[ ByteCount ]
   
POSE
    ScalingVector : FLOAT64[ 3 ]
    RotationXAxisVector : FLOAT64[ 3 ]
    RotationYAxisVector : FLOAT64[ 3 ]
    RotationZAxisVector : FLOAT64[ 3 ]
    TranslationVector : FLOAT64[ 3 ]
    
COMPONENT
    TypeByteCount : UINT32
    TypeByteArray : UINT8[ NameByteCount ]    // X Y Z R G B I
    BitCount : UINT32
    Minimum : FLOAT64
    Maximum : FLOAT64
    Offset : FLOAT64
    Scaling : FLOAT64

X24_Y24_Z24_R8_G8_B8_I16_POINT
    PositionXComponent : UINT24
    PositionYComponent : UINT24
    PositionZComponent : UINT24
    ColorRedComponent : UINT8
    ColorGreenComponent : UINT8
    ColorBlueComponent : UINT8
    IntensityComponent : UINT8
```
