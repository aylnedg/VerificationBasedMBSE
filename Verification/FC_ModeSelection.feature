# --- front-matter:toml ---
model = "FeedbackControl.slx"
[inputs]
Mode    = "Mode"
RelPosX = "BusElementIn(1)"
RelPosY = "BusElementIn(2)"
RelPosZ = "BusElementIn(3)"
[outputs]
Thrust = "Control.Thrust"
Roll   = "Control.Roll"
Pitch  = "Control.Pitch"
# --- end front-matter ---

Feature: FeedbackControl mode-based output selection
  Verifies that the FCS routes to the correct control output depending on the
  active flight mode. Land mode (Mode=2) must produce a positive landing thrust;
  emergency-off mode (Mode=3, CrashCmd) must zero all outputs.

Scenario: Land mode activates reduced hover thrust
  Mode 2 triggers the landing path. Thrust = UAVmass*g*0.98 = 0.05*9.81*0.98 ≈ 0.480 N.
  Given inputs
    * Mode    = const(2)
    * RelPosX = const(0)
    * RelPosY = const(0)
    * RelPosZ = const(0)
  When simulate for 1s in Normal mode
  Then outputs
    * LandThrustLow:  Thrust > 0.47
    * LandThrustHigh: Thrust < 0.50
    * RollZero:       Roll  == 0
    * PitchZero:      Pitch == 0

Scenario: Emergency off mode zeroes all control outputs
  Mode 3 (CrashCmd) cuts motors — Thrust and attitude commands must be zero.
  Given inputs
    * Mode    = const(3)
    * RelPosX = const(0)
    * RelPosY = const(0)
    * RelPosZ = const(0)
  When simulate for 1s in Normal mode
  Then outputs
    * ThrustOff: Thrust == 0
    * RollOff:   Roll   == 0
    * PitchOff:  Pitch  == 0
