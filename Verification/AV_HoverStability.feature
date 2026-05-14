# --- front-matter:toml ---
model = "AirVehicle.slx"
[inputs]
Thrust  = "Control.Thrust"
Roll    = "Control.Roll"
Pitch   = "Control.Pitch"
YawRate = "Control.YawRate"
[outputs]
PosZ = "PosZ"
VelZ = "VelZ"
# --- end front-matter ---

Feature: AirVehicle hover stability
  Verifies that when the flight controller commands exactly gravity-compensating
  thrust with zero attitude commands, the vehicle altitude remains bounded and
  vertical velocity stays near zero (no divergence in the plant dynamics).

Scenario: Gravity-compensating thrust holds altitude
  Hover thrust = UAVmass * g = 0.05 * 9.81 = 0.4905 N.
  Zero roll, pitch, and yaw-rate commands produce no lateral acceleration.
  Given inputs
    * Thrust  = const(0.4905)
    * Roll    = const(0)
    * Pitch   = const(0)
    * YawRate = const(0)
  When simulate for 5s in Normal mode
  Then outputs
    * AltBoundedLow:  PosZ > -2
    * AltBoundedHigh: PosZ < 2
    * VelBounded:     VelZ == (-1 .. 1)
