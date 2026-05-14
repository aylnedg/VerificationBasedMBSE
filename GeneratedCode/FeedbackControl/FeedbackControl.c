/*
 * Prerelease License - for engineering feedback and testing purposes
 * only. Not for sale.
 *
 * File: FeedbackControl.c
 *
 * Code generated for Simulink model 'FeedbackControl'.
 *
 * Model version                  : 8.4
 * Simulink Coder version         : 26.1 (R2026a) 20-Nov-2025
 * C/C++ source code generated on : Thu May 14 14:08:47 2026
 *
 * Target selection: ert.tlc
 * Embedded hardware selection: Intel->x86-64 (Windows64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "FeedbackControl.h"
#include "rtwtypes.h"
#include <math.h>
#include "rt_nonfinite.h"
#include <emmintrin.h>

/* Named constants for Chart: '<S1>/Chart' */
#define FeedbackControl_IN_NearWP      ((uint8_T)1U)
#define FeedbackControl_IN_NotNearWP   ((uint8_T)2U)
#define FeedbackControl_IN_WPachieved  ((uint8_T)3U)

/* Block states (default storage) */
DW_FeedbackControl_T FeedbackControl_DW;

/* External inputs (root inport signals with default storage) */
ExtU_FeedbackControl_T FeedbackControl_U;

/* External outputs (root outports fed by signals with default storage) */
ExtY_FeedbackControl_T FeedbackControl_Y;

/* Real-time model */
static RT_MODEL_FeedbackControl_T FeedbackControl_M_;
RT_MODEL_FeedbackControl_T *const FeedbackControl_M = &FeedbackControl_M_;

/* Model step function */
void FeedbackControl_step(void)
{
  __m128d tmp_0;
  real_T rtb_RelPos[3];
  real_T tmp[2];
  real_T absxk;
  real_T rtb_RelPos_0;
  real_T rtb_y;
  real_T scale;
  real_T t;
  int32_T b_k;
  int32_T exitg1;
  boolean_T rtb_WPachieved;

  /* MATLAB Function: '<S1>/MATLAB Function' */
  scale = 3.312168642111238E-170;

  /* Sum: '<S1>/Sum' incorporates:
   *  Constant: '<Root>/ReferenceWaypoints'
   *  Inport generated from: '<Root>/BusElementIn'
   *  Selector: '<S1>/Selector'
   *  UnitDelay: '<S1>/Unit Delay'
   */
  rtb_RelPos_0 =
    FeedbackControl_ConstP.ReferenceWaypoints_Value[FeedbackControl_DW.UnitDelay_DSTATE
    - 1] - FeedbackControl_U.UAVPos_WorldPosition[0];
  rtb_RelPos[0] = rtb_RelPos_0;

  /* MATLAB Function: '<S1>/MATLAB Function' incorporates:
   *  Sum: '<S1>/Sum'
   */
  absxk = fabs(rtb_RelPos_0);
  if (absxk > 3.312168642111238E-170) {
    rtb_y = 1.0;
    scale = absxk;
  } else {
    t = absxk / 3.312168642111238E-170;
    rtb_y = t * t;
  }

  /* Sum: '<S1>/Sum' incorporates:
   *  Constant: '<Root>/ReferenceWaypoints'
   *  Inport generated from: '<Root>/BusElementIn'
   *  Selector: '<S1>/Selector'
   *  UnitDelay: '<S1>/Unit Delay'
   */
  rtb_RelPos_0 =
    FeedbackControl_ConstP.ReferenceWaypoints_Value[FeedbackControl_DW.UnitDelay_DSTATE
    + 4] - FeedbackControl_U.UAVPos_WorldPosition[1];
  rtb_RelPos[1] = rtb_RelPos_0;

  /* MATLAB Function: '<S1>/MATLAB Function' incorporates:
   *  Sum: '<S1>/Sum'
   */
  absxk = fabs(rtb_RelPos_0);
  if (absxk > scale) {
    t = scale / absxk;
    rtb_y = rtb_y * t * t + 1.0;
    scale = absxk;
  } else {
    t = absxk / scale;
    rtb_y += t * t;
  }

  /* Sum: '<S1>/Sum' incorporates:
   *  Constant: '<Root>/ReferenceWaypoints'
   *  Inport generated from: '<Root>/BusElementIn'
   *  Selector: '<S1>/Selector'
   *  UnitDelay: '<S1>/Unit Delay'
   */
  rtb_RelPos_0 =
    FeedbackControl_ConstP.ReferenceWaypoints_Value[FeedbackControl_DW.UnitDelay_DSTATE
    + 9] - FeedbackControl_U.UAVPos_WorldPosition[2];
  rtb_RelPos[2] = rtb_RelPos_0;

  /* MATLAB Function: '<S1>/MATLAB Function' incorporates:
   *  Sum: '<S1>/Sum'
   */
  absxk = fabs(rtb_RelPos_0);
  if (absxk > scale) {
    t = scale / absxk;
    rtb_y = rtb_y * t * t + 1.0;
    scale = absxk;
  } else {
    t = absxk / scale;
    rtb_y += t * t;
  }

  rtb_y = scale * sqrt(rtb_y);
  if (rtIsNaN(rtb_y)) {
    b_k = 0;
    do {
      exitg1 = 0;
      if (b_k < 3) {
        if (rtIsNaN(rtb_RelPos[b_k])) {
          exitg1 = 1;
        } else {
          b_k++;
        }
      } else {
        rtb_y = (rtInf);
        exitg1 = 1;
      }
    } while (exitg1 == 0);
  }

  /* Chart: '<S1>/Chart' */
  if (FeedbackControl_DW.is_active_c3_FeedbackControl == 0) {
    FeedbackControl_DW.is_active_c3_FeedbackControl = 1U;
    FeedbackControl_DW.is_c3_FeedbackControl = FeedbackControl_IN_NotNearWP;
    rtb_WPachieved = false;
  } else {
    switch (FeedbackControl_DW.is_c3_FeedbackControl) {
     case FeedbackControl_IN_NearWP:
      rtb_WPachieved = false;
      if (rtb_y > 0.1) {
        FeedbackControl_DW.is_c3_FeedbackControl = FeedbackControl_IN_NotNearWP;
      } else if (FeedbackControl_DW.count >= 0.75) {
        FeedbackControl_DW.is_c3_FeedbackControl = FeedbackControl_IN_WPachieved;
        rtb_WPachieved = true;
      } else {
        FeedbackControl_DW.count += 0.01;
      }
      break;

     case FeedbackControl_IN_NotNearWP:
      rtb_WPachieved = false;
      if (rtb_y <= 0.1) {
        FeedbackControl_DW.is_c3_FeedbackControl = FeedbackControl_IN_NearWP;
        FeedbackControl_DW.count = 0.0;
      }
      break;

     default:
      /* case IN_WPachieved: */
      FeedbackControl_DW.is_c3_FeedbackControl = FeedbackControl_IN_NotNearWP;
      rtb_WPachieved = false;
      break;
    }
  }

  /* End of Chart: '<S1>/Chart' */

  /* Sum: '<S1>/Sum1' incorporates:
   *  DataTypeConversion: '<S1>/Data Type Conversion'
   *  UnitDelay: '<S1>/Unit Delay'
   */
  FeedbackControl_DW.UnitDelay_DSTATE = (uint8_T)((uint32_T)rtb_WPachieved +
    FeedbackControl_DW.UnitDelay_DSTATE);

  /* Outputs for Atomic SubSystem: '<Root>/PID_Loops' */
  /* Gain: '<S88>/Derivative Gain' incorporates:
   *  SampleTimeMath: '<S92>/Tsamp'
   *
   * About '<S92>/Tsamp':
   *  y = u * K where K = 1 / ( w * Ts )
   *   */
  tmp_0 = _mm_set_pd(rtb_RelPos[0], rtb_RelPos[1]);
  _mm_storeu_pd(&tmp[0], _mm_mul_pd(_mm_mul_pd(_mm_set1_pd(-0.205809687615586),
    tmp_0), _mm_set1_pd(100.0)));

  /* SampleTimeMath: '<S92>/Tsamp'
   *
   * About '<S92>/Tsamp':
   *  y = u * K where K = 1 / ( w * Ts )
   *   */
  scale = tmp[0];
  absxk = tmp[1];

  /* Gain: '<S102>/Proportional Gain' incorporates:
   *  Delay: '<S90>/UD'
   */
  tmp_0 = _mm_add_pd(_mm_mul_pd(_mm_set1_pd(-0.00720350415583028), tmp_0),
                     _mm_sub_pd(_mm_set_pd(tmp[1], tmp[0]), _mm_loadu_pd
    (&FeedbackControl_DW.UD_DSTATE[0])));

  /* End of Outputs for SubSystem: '<Root>/PID_Loops' */
  _mm_storeu_pd(&tmp[0], tmp_0);

  /* Outputs for Atomic SubSystem: '<Root>/PID_Loops' */
  /* SampleTimeMath: '<S38>/Tsamp' incorporates:
   *  Gain: '<S34>/Derivative Gain'
   *  Sum: '<S1>/Sum'
   *
   * About '<S38>/Tsamp':
   *  y = u * K where K = 1 / ( w * Ts )
   *   */
  t = -0.253700825364154 * rtb_RelPos_0 * 100.0;

  /* Sum: '<S52>/Sum' incorporates:
   *  Delay: '<S36>/UD'
   *  DiscreteIntegrator: '<S43>/Integrator'
   *  Gain: '<S48>/Proportional Gain'
   *  Sum: '<S1>/Sum'
   *  Sum: '<S36>/Diff'
   */
  rtb_y = (-0.213527398440291 * rtb_RelPos_0 +
           FeedbackControl_DW.Integrator_DSTATE) + (t -
    FeedbackControl_DW.UD_DSTATE_j);

  /* Update for Delay: '<S90>/UD' incorporates:
   *  SampleTimeMath: '<S92>/Tsamp'
   *
   * About '<S92>/Tsamp':
   *  y = u * K where K = 1 / ( w * Ts )
   *   */
  FeedbackControl_DW.UD_DSTATE[0] = scale;
  FeedbackControl_DW.UD_DSTATE[1] = absxk;

  /* Update for Delay: '<S36>/UD' */
  FeedbackControl_DW.UD_DSTATE_j = t;

  /* Update for DiscreteIntegrator: '<S43>/Integrator' incorporates:
   *  Gain: '<S40>/Integral Gain'
   *  Sum: '<S1>/Sum'
   */
  FeedbackControl_DW.Integrator_DSTATE += -0.0449288545084318 * rtb_RelPos_0 *
    0.01;

  /* End of Outputs for SubSystem: '<Root>/PID_Loops' */

  /* MultiPortSwitch: '<Root>/Multiport Switch' incorporates:
   *  Inport generated from: '<Root>/Mode'
   */
  switch (FeedbackControl_U.Mode) {
   case 0:
    /* Outport generated from: '<Root>/Control' incorporates:
     *  BusCreator: '<Root>/Bus Creator1'
     *  Constant: '<Root>/Pitch'
     *  Constant: '<Root>/Roll'
     *  Constant: '<Root>/Thrust'
     *  Constant: '<Root>/YawRate'
     */
    FeedbackControl_Y.Control.Roll = 0.0;
    FeedbackControl_Y.Control.Pitch = 0.0;
    FeedbackControl_Y.Control.YawRate = 0.0;
    FeedbackControl_Y.Control.Thrust = 0.0;
    break;

   case 1:
    /* Outputs for Atomic SubSystem: '<Root>/PID_Loops' */
    /* Outport generated from: '<Root>/Control' incorporates:
     *  BusCreator: '<S2>/Bus Creator'
     *  Constant: '<S2>/YawRate'
     *  Gain: '<S2>/Gain'
     */
    FeedbackControl_Y.Control.Roll = -tmp[0];

    /* End of Outputs for SubSystem: '<Root>/PID_Loops' */
    FeedbackControl_Y.Control.Pitch = tmp[1];

    /* Outputs for Atomic SubSystem: '<Root>/PID_Loops' */
    FeedbackControl_Y.Control.YawRate = 0.0;
    FeedbackControl_Y.Control.Thrust = rtb_y;

    /* End of Outputs for SubSystem: '<Root>/PID_Loops' */
    break;

   case 2:
    /* Outport generated from: '<Root>/Control' incorporates:
     *  BusAssignment: '<Root>/Bus Assignment'
     *  BusCreator: '<Root>/Bus Creator1'
     *  Constant: '<Root>/LandThrust'
     *  Constant: '<Root>/Pitch'
     *  Constant: '<Root>/Roll'
     *  Constant: '<Root>/YawRate'
     */
    FeedbackControl_Y.Control.Roll = 0.0;
    FeedbackControl_Y.Control.Pitch = 0.0;
    FeedbackControl_Y.Control.YawRate = 0.0;
    FeedbackControl_Y.Control.Thrust = 0.48069000000000006;
    break;

   default:
    /* Outport generated from: '<Root>/Control' incorporates:
     *  BusCreator: '<Root>/Bus Creator1'
     *  Constant: '<Root>/Pitch'
     *  Constant: '<Root>/Roll'
     *  Constant: '<Root>/Thrust'
     *  Constant: '<Root>/YawRate'
     */
    FeedbackControl_Y.Control.Roll = 0.0;
    FeedbackControl_Y.Control.Pitch = 0.0;
    FeedbackControl_Y.Control.YawRate = 0.0;
    FeedbackControl_Y.Control.Thrust = 0.0;
    break;
  }

  /* End of MultiPortSwitch: '<Root>/Multiport Switch' */
}

/* Model initialize function */
void FeedbackControl_initialize(void)
{
  /* InitializeConditions for UnitDelay: '<S1>/Unit Delay' */
  FeedbackControl_DW.UnitDelay_DSTATE = 1U;

  /* SystemInitialize for Atomic SubSystem: '<Root>/PID_Loops' */
  /* InitializeConditions for DiscreteIntegrator: '<S43>/Integrator' */
  FeedbackControl_DW.Integrator_DSTATE = 0.49050000000000005;

  /* End of SystemInitialize for SubSystem: '<Root>/PID_Loops' */
}

/* Model terminate function */
void FeedbackControl_terminate(void)
{
  /* (no terminate code required) */
}

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
