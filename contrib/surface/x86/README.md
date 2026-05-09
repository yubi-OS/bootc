# Surface x86 bootc Image (Surface Pro / Surface Laptop)

Produces a bootc-compatible OCI image for Microsoft Surface Pro and Surface Laptop
(x86-64) devices using their standard UEFI firmware.

## What ships in the image

| Layer | Details |
|---|---|
| Kernel | linux-surface (patched for IPTS touch, Type Cover HID, pen) |
| Touch daemon | iptsd (IPTS frame processing) |
| Thermal | thermald (surface power management) |
| Firmware | sof-firmware, linux-firmware |
| kargs | PSR off, deep sleep, lid fix, native ACPI backlight |
| Bootloader | systemd-boot (via bootc install config) |
| TPM2 | tpm2-tools, sbctl (for Secure Boot key enrollment) |

## Build

    podman build --platform linux/amd64 -f Containerfile.fedora -t surface-x86 .

## Install to disk

    # Disable Secure Boot in Surface UEFI first (Volume Up + Power -> Security)
    podman run --rm --privileged --pid=host \
      -v /dev:/dev -v /var/lib/containers:/var/lib/containers \
      surface-x86 bootc install to-disk /dev/nvme0n1

    # With TPM2-LUKS disk encryption:
    podman run --rm --privileged --pid=host \
      -v /dev:/dev -v /var/lib/containers:/var/lib/containers \
      surface-x86 bootc install to-disk --block-setup=tpm2-luks /dev/nvme0n1

## Secure Boot

After first boot, run sbctl to enroll your own Platform Key:

    sbctl create-keys
    sbctl enroll-keys --microsoft   # keeps Windows dual-boot working
    sbctl sign /efi/EFI/Linux/*.efi

Re-enable Secure Boot in Surface UEFI.

## bootc day-2 upgrades

    bootc upgrade   # pulls new OCI image, applies on next reboot
    bootc rollback  # revert to previous deployment if needed
