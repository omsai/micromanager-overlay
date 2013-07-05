### Installation

1.  Add this overlay using `app-portage/layman`
```
layman -o https://raw.github.com/omsai/lifescience-overlay/master/overlay.xml -f -a lifescience
```

2.  Update overlay
```
layman -S
```

3. Install desired main packages from list below

### Main packages

```bash
## µManager
emerge sci-biology/micro-manager

## Andor camera drivers (CCD / EMCCD)
emerge sci-libs/andor-camera-driver:2

## Andor camera drivers (Scientific CMOS)
emerge sci-libs/andor-camera-driver:3
```
