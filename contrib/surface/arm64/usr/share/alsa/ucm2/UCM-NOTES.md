# ALSA UCM profile hint for x1e80100 (Snapdragon X Elite)
# alsa-ucm-conf from Fedora may not yet include x1e80100 profiles.
# This file documents the expected UCM layout for Surface Laptop 7.
#
# UCM card name: x1e80100 (matches /proc/asound/cards)
# Profile set: HiFi (primary), VoiceCall (call routing)
#
# Until upstream alsa-ucm-conf ships x1e80100 profiles:
#   1. Check alsa-ucm-conf-git from COPR @alsa/alsa-utils
#   2. Or copy UCM from linux-surface firmware repo:
#      https://github.com/linux-surface/surface-ath11k-firmware
#      (contains some UCM profiles for Qualcomm Surface devices)
#
# Tracker: https://github.com/alsa-project/alsa-ucm-conf/issues
# Once upstream ships, remove this file and rely on alsa-ucm-conf package.
