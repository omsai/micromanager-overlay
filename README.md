## Installation

1.  Add this overlay using `app-portage/layman`
```
layman -o https://raw.github.com/omsai/micromanager-overlay/master/overlay.xml -f -a micro-manager
```

2.  Update overlay
```
layman -S
```

## Main packages

### µManager
```
emerge sci-biology/micro-manager
```

### Andor camera drivers

#### CCD / EMCCD
```
emerge sci-libs/andor-camera-driver:2
```

#### Scientific CMOS
```
emerge sci-libs/andor-camera-driver:3
```

