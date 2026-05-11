# Surface ARM64 bootc Image (Snapdragon X Elite - Surface Laptop 7)

Produces a bootc-compatible OCI image for Microsoft Surface Laptop 7 (aarch64)
with Snapdragon X Elite (x1e80100). Uses upstream kernel only.

## Design decisions

| Decision | Rationale |
|---|---|
| Upstream kernel | x1e80100 DTBs merged since 6.12 (romulus13/15); linux-surface has no aarch64 packages |
| block=["direct"] | Qualcomm fTPM unavailable at initrd phase; tpm2-luks PCR binding fails |
| No MokManager | Surface NX Mode UEFI freezes MokManager; bootc UKI+systemd-boot needs no shim |
| s2idle only | Snapdragon X Elite PSCI/ACPI exposes no S3; only s2idle available |

## Hardware status (kernel 6.15+)

| Component | Status |
|---|---|
| Boot (systemd-boot + UKI) | Works |
| CPU (Oryon 12-core) | Works |
| NVMe (PCIe Gen 4) | Works |
| Display (eDP 120Hz, Freedreno) | Works |
| WiFi (WCN785x / ath12k) | Works (needs linux-firmware) |
| Suspend (s2idle) | Works |
| TPM2 (direct, no PCR binding) | Works |
| Secure Boot | Manual via surface-sb-enroll service |
| Audio | Partial (Windows firmware blobs needed) |
| Camera | Not working (IPU6/MIPI unmerged) |
| Touchscreen | Not working (HID-over-SPI unmerged) |

## Build

    # Native aarch64 build
    podman build --platform linux/arm64 -f Containerfile.fedora -t surface-arm64 .

    # Cross-build from x86-64 (requires qemu-user-static + binfmt-misc)
    sudo dnf install qemu-user-static
    podman build --platform linux/arm64 -f Containerfile.fedora -t surface-arm64 .

## Install to disk

    # Disable Secure Boot in Surface UEFI first (Volume Up + Power -> Security)
    podman run --rm --privileged --pid=host \
      -v /dev:/dev -v /var/lib/containers:/var/lib/containers \
      surface-arm64 bootc install to-disk /dev/nvme0n1

## Secure Boot enrollment (first boot)

On first boot, surface-sb-enroll.service runs automatically and generates signing keys.

    cat /var/lib/surface-sb-enroll/ENROLL_SECURE_BOOT.md

Then enroll the exported bootc-PK.cer in Surface UEFI -> Security -> Secure Boot
-> Enroll Platform Key from file.

MokManager is never used. Surface UEFI NX Mode causes MokManager to hang.
bootc UKI + systemd-boot bypasses shim entirely.
Ref: https://github.com/linux-surface/linux-surface/issues/1590

## Day-2 operations

    bootc upgrade   # pull new OCI layer, apply on next reboot
    bootc rollback  # revert to previous deployment
    bootc status    # check current and staged deployment
