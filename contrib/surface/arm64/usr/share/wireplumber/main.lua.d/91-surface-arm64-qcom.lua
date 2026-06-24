# WirePlumber policy for Qualcomm Q6DSP audio on Snapdragon X Elite
# Place at /usr/share/wireplumber/main.lua.d/91-surface-arm64-qcom.lua
# or /etc/wireplumber/main.lua.d/91-surface-arm64-qcom.lua
--
-- Surface Laptop 7 / Snapdragon X Elite: prefer Q6DSP path for internal audio.
-- Fallback to UCM routing if Q6DSP firmware not yet available.

rule = {
  matches = {
    {
      { "node.name", "matches", "alsa_output.platform*sc8280xp*" },
    },
  },
  apply_properties = {
    ["audio.rate"] = 48000,
    ["audio.format"] = "S16LE",
    -- Q6DSP prefers 48kHz; resampling to other rates goes through LPASS mixer
    ["resample.quality"] = 4,
    ["priority.session"] = 1100,
  },
}
