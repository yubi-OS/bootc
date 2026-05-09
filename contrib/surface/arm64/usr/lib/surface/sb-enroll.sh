#!/bin/bash
# Surface Laptop 7 Secure Boot enrollment helper
# Generates sbctl keys, signs UKIs, exports PK cert for UEFI enrollment.
#
# WHY NOT MokManager: Surface NX Mode causes MokManager to hang at UEFI logo.
# bootc uses UKI + systemd-boot (no shim), so this script does direct UEFI db enrollment.
# Source: https://github.com/linux-surface/linux-surface/issues/1590
# Source: https://github.com/Foxboron/sbctl

set -euo pipefail

INSTRUCTIONS_DIR=/var/lib/surface-sb-enroll
mkdir -p "$INSTRUCTIONS_DIR"

echo "[surface-sb-enroll] Generating sbctl Secure Boot keys..."
sbctl create-keys

for uki in /efi/EFI/Linux/*.efi /boot/EFI/Linux/*.efi; do
  [ -f "$uki" ] || continue
  echo "[surface-sb-enroll] Signing: $uki"
  sbctl sign "$uki"
done

if [ -f /var/lib/sbctl/keys/PK/PK.pem ]; then
  openssl x509 -in /var/lib/sbctl/keys/PK/PK.pem -outform DER -out "$INSTRUCTIONS_DIR/bootc-PK.cer"
  echo "[surface-sb-enroll] Platform Key exported: $INSTRUCTIONS_DIR/bootc-PK.cer"
fi

cat > "$INSTRUCTIONS_DIR/ENROLL_SECURE_BOOT.md" << HEREDOC
# bootc Secure Boot Enrollment - Surface Laptop 7

Keys generated. UKIs signed. To enable Secure Boot:

1. cp /var/lib/surface-sb-enroll/bootc-PK.cer /efi/bootc-PK.cer

2. Enter Surface UEFI: hold Volume Up + Power while powering on.
   Navigate: Security -> Secure Boot -> Disable -> Reset to Setup Mode.

3. Enroll Platform Key from file (select bootc-PK.cer).
   OR from Linux with SB disabled: sbctl enroll-keys --microsoft

4. Re-enable Secure Boot. Verify: bootctl status | grep -i secure

MokManager NOT used. Surface NX Mode firmware freezes when MokManager loads.
bootc UKI + systemd-boot bypasses shim entirely.
Ref: https://github.com/linux-surface/linux-surface/issues/1590
HEREDOC

echo "[surface-sb-enroll] Done. Read: $INSTRUCTIONS_DIR/ENROLL_SECURE_BOOT.md"
