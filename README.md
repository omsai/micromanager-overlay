### Installation

1.  Add this overlay using `app-portage/layman`
```
layman -o https://raw.github.com/omsai/microscopy-overlay/master/overlay.xml -f -a microscopy
```

2.  Update overlay using `layman -S`

3. Install desired main packages:

Package Name | Description
------------ | ------------
sci-biology/micro-manager | µManager microscopy software
sci-libs/andor-camera-driver:2 | Andor EM/CCD camera drivers
sci-libs/andor-camera-driver:3 | Andor CMOS camera driver
