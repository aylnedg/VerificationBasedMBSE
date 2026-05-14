# --- front-matter:toml ---
model = "Guidance.slx"
[inputs]
PosX = "BusElementIn.WorldPosition(1,1)"
PosY = "BusElementIn.WorldPosition(2,1)"
PosZ = "BusElementIn.WorldPosition(3,1)"
[outputs]
RelPosX = "RelPos.RelPosX"
RelPosY = "RelPos.RelPosY"
RelPosZ = "RelPos.RelPosZ"
# --- end front-matter ---

Feature: Guidance nominal waypoint tracking
  Verifies that the Guidance block produces a bounded relative-position command
  during nominal operation and that the altitude saturation clamps downward
  commands to 0.0001 (upper limit prevents climbing above waypoint).

Scenario: Zero position error yields near-zero relative position command
  All three RelPos elements are bounded; Z saturation prevents upward commands.
  Given inputs
    * PosX = const(0)
    * PosY = const(0)
    * PosZ = const(0)
  When simulate for 5s in Normal mode
  Then outputs
    * BoundedX:  RelPosX == [-1 .. 1]
    * BoundedY:  RelPosY == [-1 .. 1]
    * BoundedZ:  RelPosZ == [-1 .. 1]
    * NotClimb:  RelPosZ <= 0.0001

Scenario: Altitude saturation caps upward relative-position command
  Saturation holds RelPosZ at or below 0.0001 regardless of altitude error.
  Given inputs
    * PosX = const(0)
    * PosY = const(0)
    * PosZ = const(1)
  When simulate for 5s in Normal mode
  Then outputs
    * SaturationActive: RelPosZ <= 0.0001
