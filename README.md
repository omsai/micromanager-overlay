Installation
------------
1.  Add this overlay using `app-portage/layman`

    # layman -o https://raw.github.com/omsai/micromanager-overlay/master/overlay.xml -f -a micro-manager

2.  µManager

    # emerge sci-biology/micro-manager

3.  Camera drivers

    # emerge sci-libs/andor-camera-driver:2
    # emerge sci-libs/andor-camera-driver:3

4.  Updating overlay:

    # layman -S
