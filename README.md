L_OP (Linux_OPtimizer) is an optimization script for Linux that tries to be as thorough as possbile so YOUR PC is as optimized as possible for what YOU want it to do specifically.

WARNING: This software is still in development, altough it is in a working state, and i try to test it on as many devices as possible, i can't know if it will work well on yours, or if it can cause issues, so proceed with caution. There will most likely be bugs.

Dependencies:

1. Bash
2. SystemD system services

(All of these should be present in most modern linux distro's by default)


How to Install/Uninstall:

1. Download the L_OP_DEV.tar.gz.
2. Extract the tar.gz file.
3. Open the folder and run L_OP_DEV.sh as sudo/root (due to the nature of the optimizations of this script, this is required).
4. Choose Install/Uninstall.
5. If installing, select your desired profile and the script will analyse your hardware to determine what's best to apply for your PC.
6. Restart your PC to apply the optimizations.


Project Philosophy:

The main objectives for this script are to improve:

1. Hardware longevity
2. Performance
3. As few dependencies as possible
4. No internet connectivty required

The goal is to make the PC not go to it's limit, while keeping/improving as much performance as possible, so it lasts longer. All with the minimal amount of depencies to make it as usable as possible in the widest amount of environments/devices.


Supported Hardware:

CPUs/IGPUs:
    - Intel
    - AMD
    (Note that hybrid CPUs with P-Cores/E-Cores will not get correcly analyzed at the moment)

Dedicaded GPUs:
    - NVIDIA
    (I don't own either a Radeon or Intel ARC GPU, so i can't test them)


Supported Software:

Mainly supported distros:
    - Linux Mint
    - Bazzite
    (Other distros should work as well)

Supported bootloader:
    - GRUB
    (If it's not present, the script will auto skip those that would be applied to it, the other optimizations will still work)

Supported desktop environments:
    - XFCE
    (Same as with before, if you have a different DE, those optimizations will be skipped, the other optimizations will still work)


How does this script work?

- The user chooses a profile, either one of the provided ones or a custom one.
- The profile provides the guidelines for what to optimize each part of the system.
- The script will analyze the user's system, and classify each device according to it's type and capabilities, the data is saved on the script's install directory (currently /var/lib/L_OP_DEV).
- SystemD services will be set up so they can apply the optimizations on boot, as 99% of the values touched by this script get reverted on reboots, so they must be reapplied each time.
- On boot, the systemd main systemd service will apply the optimizations, according to the user's profile and hardware capabilities.
- If TMPFS mounts need to be used, another systemD service will take care of it. By default this creates and binds mounts for system cache directories. If the storage device where root is mounted is slow, it can also mount additional, heavier cache directories, such as the steam shadercache.


What is used to classify hardware capability?

(NOTE: For each of the following hardware, more that this is actually analyzied, but for now it's not used)

- CPU:
    - CPU cores
    - CPU frequency

- GPU:
    - Vendor
    - Dedicated/Integrated GPU
    (Since GPUs don't have the same fine-tuned control as CPUs, currently the classification logic is rather basic)

- RAM:
    - Amount

- Storage:
    - Device type: hdd, usb, ssd (SATA), nvme
    - Partition format: BTRFS, EXT4
