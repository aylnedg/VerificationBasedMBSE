/*
 * Prerelease License - for engineering feedback and testing purposes
 * only. Not for sale.
 *
 * File: FeedbackControl.h
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

#ifndef FeedbackControl_h_
#define FeedbackControl_h_
#ifndef FeedbackControl_COMMON_INCLUDES_
#define FeedbackControl_COMMON_INCLUDES_
#include "rtwtypes.h"
#include "rt_nonfinite.h"
#include "math.h"
#endif                                 /* FeedbackControl_COMMON_INCLUDES_ */

#include "FeedbackControl_types.h"
#include "rtGetInf.h"

/* Macros for accessing real-time model data structure */
#ifndef rtmGetErrorStatus
#define rtmGetErrorStatus(rtm)         ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
#define rtmSetErrorStatus(rtm, val)    ((rtm)->errorStatus = (val))
#endif

/* Block states (default storage) for system '<Root>' */
typedef struct {
  real_T UD_DSTATE[2];                 /* '<S90>/UD' */
  real_T UD_DSTATE_j;                  /* '<S36>/UD' */
  real_T Integrator_DSTATE;            /* '<S43>/Integrator' */
  real_T count;                        /* '<S1>/Chart' */
  uint8_T UnitDelay_DSTATE;            /* '<S1>/Unit Delay' */
  uint8_T is_active_c3_FeedbackControl;/* '<S1>/Chart' */
  uint8_T is_c3_FeedbackControl;       /* '<S1>/Chart' */
} DW_FeedbackControl_T;

/* Constant parameters (default storage) */
typedef struct {
  /* Expression: waypoints
   * Referenced by: '<Root>/ReferenceWaypoints'
   */
  real_T ReferenceWaypoints_Value[15];
} ConstP_FeedbackControl_T;

/* External inputs (root inport signals with default storage) */
typedef struct {
  uint8_T Mode;                        /* '<Root>/Mode' */
  real_T UAVPos_WorldPosition[3];      /* '<Root>/UAVPos_WorldPosition' */
  real_T UAVPos_WorldVelocity[3];      /* '<Root>/UAVPos_WorldVelocity' */
  real_T UAVPos_EulerZYX[3];           /* '<Root>/UAVPos_EulerZYX' */
  real_T UAVPos_BodyAngularRateRPY[3]; /* '<Root>/UAVPos_BodyAngularRateRPY' */
  real_T UAVPos_Thrust;                /* '<Root>/UAVPos_Thrust' */
} ExtU_FeedbackControl_T;

/* External outputs (root outports fed by signals with default storage) */
typedef struct {
  MultirotorGuidanceControlBus Control;/* '<Root>/Control' */
} ExtY_FeedbackControl_T;

/* Real-time Model Data Structure */
struct tag_RTM_FeedbackControl_T {
  const char_T * volatile errorStatus;
};

/* Block states (default storage) */
extern DW_FeedbackControl_T FeedbackControl_DW;

/* External inputs (root inport signals with default storage) */
extern ExtU_FeedbackControl_T FeedbackControl_U;

/* External outputs (root outports fed by signals with default storage) */
extern ExtY_FeedbackControl_T FeedbackControl_Y;

/* Constant parameters (default storage) */
extern const ConstP_FeedbackControl_T FeedbackControl_ConstP;

/* Model entry point functions */
extern void FeedbackControl_initialize(void);
extern void FeedbackControl_step(void);
extern void FeedbackControl_terminate(void);

/* Real-time Model object */
extern RT_MODEL_FeedbackControl_T *const FeedbackControl_M;

/*-
 * These blocks were eliminated from the model due to optimizations:
 *
 * Block '<S36>/DTDup' : Unused code path elimination
 * Block '<S90>/DTDup' : Unused code path elimination
 * Block '<S2>/Thrust_SCOPE1' : Unused code path elimination
 */

/*-
 * The generated code includes comments that allow you to trace directly
 * back to the appropriate location in the model.  The basic format
 * is <system>/block_name, where system is the system number (uniquely
 * assigned by Simulink) and block_name is the name of the block.
 *
 * Use the MATLAB hilite_system command to trace the generated code back
 * to the model.  For example,
 *
 * hilite_system('<S3>')    - opens system 3
 * hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
 *
 * Here is the system hierarchy for this model
 *
 * '<Root>' : 'FeedbackControl'
 * '<S1>'   : 'FeedbackControl/GuidanceCompute'
 * '<S2>'   : 'FeedbackControl/PID_Loops'
 * '<S3>'   : 'FeedbackControl/GuidanceCompute/Chart'
 * '<S4>'   : 'FeedbackControl/GuidanceCompute/MATLAB Function'
 * '<S5>'   : 'FeedbackControl/PID_Loops/Alt_Control'
 * '<S6>'   : 'FeedbackControl/PID_Loops/RollPitch_Control'
 * '<S7>'   : 'FeedbackControl/PID_Loops/Alt_Control/Anti-windup'
 * '<S8>'   : 'FeedbackControl/PID_Loops/Alt_Control/D Gain'
 * '<S9>'   : 'FeedbackControl/PID_Loops/Alt_Control/External Derivative'
 * '<S10>'  : 'FeedbackControl/PID_Loops/Alt_Control/Filter'
 * '<S11>'  : 'FeedbackControl/PID_Loops/Alt_Control/Filter ICs'
 * '<S12>'  : 'FeedbackControl/PID_Loops/Alt_Control/I Gain'
 * '<S13>'  : 'FeedbackControl/PID_Loops/Alt_Control/Ideal P Gain'
 * '<S14>'  : 'FeedbackControl/PID_Loops/Alt_Control/Ideal P Gain Fdbk'
 * '<S15>'  : 'FeedbackControl/PID_Loops/Alt_Control/Integrator'
 * '<S16>'  : 'FeedbackControl/PID_Loops/Alt_Control/Integrator ICs'
 * '<S17>'  : 'FeedbackControl/PID_Loops/Alt_Control/N Copy'
 * '<S18>'  : 'FeedbackControl/PID_Loops/Alt_Control/N Gain'
 * '<S19>'  : 'FeedbackControl/PID_Loops/Alt_Control/P Copy'
 * '<S20>'  : 'FeedbackControl/PID_Loops/Alt_Control/Parallel P Gain'
 * '<S21>'  : 'FeedbackControl/PID_Loops/Alt_Control/Reset Signal'
 * '<S22>'  : 'FeedbackControl/PID_Loops/Alt_Control/Saturation'
 * '<S23>'  : 'FeedbackControl/PID_Loops/Alt_Control/Saturation Fdbk'
 * '<S24>'  : 'FeedbackControl/PID_Loops/Alt_Control/Sum'
 * '<S25>'  : 'FeedbackControl/PID_Loops/Alt_Control/Sum Fdbk'
 * '<S26>'  : 'FeedbackControl/PID_Loops/Alt_Control/Tracking Mode'
 * '<S27>'  : 'FeedbackControl/PID_Loops/Alt_Control/Tracking Mode Sum'
 * '<S28>'  : 'FeedbackControl/PID_Loops/Alt_Control/Tsamp - Integral'
 * '<S29>'  : 'FeedbackControl/PID_Loops/Alt_Control/Tsamp - Ngain'
 * '<S30>'  : 'FeedbackControl/PID_Loops/Alt_Control/postSat Signal'
 * '<S31>'  : 'FeedbackControl/PID_Loops/Alt_Control/preInt Signal'
 * '<S32>'  : 'FeedbackControl/PID_Loops/Alt_Control/preSat Signal'
 * '<S33>'  : 'FeedbackControl/PID_Loops/Alt_Control/Anti-windup/Passthrough'
 * '<S34>'  : 'FeedbackControl/PID_Loops/Alt_Control/D Gain/Internal Parameters'
 * '<S35>'  : 'FeedbackControl/PID_Loops/Alt_Control/External Derivative/Error'
 * '<S36>'  : 'FeedbackControl/PID_Loops/Alt_Control/Filter/Differentiator'
 * '<S37>'  : 'FeedbackControl/PID_Loops/Alt_Control/Filter/Differentiator/Tsamp'
 * '<S38>'  : 'FeedbackControl/PID_Loops/Alt_Control/Filter/Differentiator/Tsamp/Internal Ts'
 * '<S39>'  : 'FeedbackControl/PID_Loops/Alt_Control/Filter ICs/Internal IC - Differentiator'
 * '<S40>'  : 'FeedbackControl/PID_Loops/Alt_Control/I Gain/Internal Parameters'
 * '<S41>'  : 'FeedbackControl/PID_Loops/Alt_Control/Ideal P Gain/Passthrough'
 * '<S42>'  : 'FeedbackControl/PID_Loops/Alt_Control/Ideal P Gain Fdbk/Disabled'
 * '<S43>'  : 'FeedbackControl/PID_Loops/Alt_Control/Integrator/Discrete'
 * '<S44>'  : 'FeedbackControl/PID_Loops/Alt_Control/Integrator ICs/Internal IC'
 * '<S45>'  : 'FeedbackControl/PID_Loops/Alt_Control/N Copy/Disabled wSignal Specification'
 * '<S46>'  : 'FeedbackControl/PID_Loops/Alt_Control/N Gain/Passthrough'
 * '<S47>'  : 'FeedbackControl/PID_Loops/Alt_Control/P Copy/Disabled'
 * '<S48>'  : 'FeedbackControl/PID_Loops/Alt_Control/Parallel P Gain/Internal Parameters'
 * '<S49>'  : 'FeedbackControl/PID_Loops/Alt_Control/Reset Signal/Disabled'
 * '<S50>'  : 'FeedbackControl/PID_Loops/Alt_Control/Saturation/Passthrough'
 * '<S51>'  : 'FeedbackControl/PID_Loops/Alt_Control/Saturation Fdbk/Disabled'
 * '<S52>'  : 'FeedbackControl/PID_Loops/Alt_Control/Sum/Sum_PID'
 * '<S53>'  : 'FeedbackControl/PID_Loops/Alt_Control/Sum Fdbk/Disabled'
 * '<S54>'  : 'FeedbackControl/PID_Loops/Alt_Control/Tracking Mode/Disabled'
 * '<S55>'  : 'FeedbackControl/PID_Loops/Alt_Control/Tracking Mode Sum/Passthrough'
 * '<S56>'  : 'FeedbackControl/PID_Loops/Alt_Control/Tsamp - Integral/TsSignalSpecification'
 * '<S57>'  : 'FeedbackControl/PID_Loops/Alt_Control/Tsamp - Ngain/Passthrough'
 * '<S58>'  : 'FeedbackControl/PID_Loops/Alt_Control/postSat Signal/Forward_Path'
 * '<S59>'  : 'FeedbackControl/PID_Loops/Alt_Control/preInt Signal/Internal PreInt'
 * '<S60>'  : 'FeedbackControl/PID_Loops/Alt_Control/preSat Signal/Forward_Path'
 * '<S61>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/Anti-windup'
 * '<S62>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/D Gain'
 * '<S63>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/External Derivative'
 * '<S64>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/Filter'
 * '<S65>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/Filter ICs'
 * '<S66>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/I Gain'
 * '<S67>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/Ideal P Gain'
 * '<S68>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/Ideal P Gain Fdbk'
 * '<S69>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/Integrator'
 * '<S70>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/Integrator ICs'
 * '<S71>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/N Copy'
 * '<S72>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/N Gain'
 * '<S73>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/P Copy'
 * '<S74>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/Parallel P Gain'
 * '<S75>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/Reset Signal'
 * '<S76>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/Saturation'
 * '<S77>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/Saturation Fdbk'
 * '<S78>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/Sum'
 * '<S79>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/Sum Fdbk'
 * '<S80>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/Tracking Mode'
 * '<S81>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/Tracking Mode Sum'
 * '<S82>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/Tsamp - Integral'
 * '<S83>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/Tsamp - Ngain'
 * '<S84>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/postSat Signal'
 * '<S85>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/preInt Signal'
 * '<S86>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/preSat Signal'
 * '<S87>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/Anti-windup/Disabled'
 * '<S88>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/D Gain/Internal Parameters'
 * '<S89>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/External Derivative/Error'
 * '<S90>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/Filter/Differentiator'
 * '<S91>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/Filter/Differentiator/Tsamp'
 * '<S92>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/Filter/Differentiator/Tsamp/Internal Ts'
 * '<S93>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/Filter ICs/Internal IC - Differentiator'
 * '<S94>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/I Gain/Disabled'
 * '<S95>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/Ideal P Gain/Passthrough'
 * '<S96>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/Ideal P Gain Fdbk/Disabled'
 * '<S97>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/Integrator/Disabled'
 * '<S98>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/Integrator ICs/Disabled'
 * '<S99>'  : 'FeedbackControl/PID_Loops/RollPitch_Control/N Copy/Disabled wSignal Specification'
 * '<S100>' : 'FeedbackControl/PID_Loops/RollPitch_Control/N Gain/Passthrough'
 * '<S101>' : 'FeedbackControl/PID_Loops/RollPitch_Control/P Copy/Disabled'
 * '<S102>' : 'FeedbackControl/PID_Loops/RollPitch_Control/Parallel P Gain/Internal Parameters'
 * '<S103>' : 'FeedbackControl/PID_Loops/RollPitch_Control/Reset Signal/Disabled'
 * '<S104>' : 'FeedbackControl/PID_Loops/RollPitch_Control/Saturation/Passthrough'
 * '<S105>' : 'FeedbackControl/PID_Loops/RollPitch_Control/Saturation Fdbk/Disabled'
 * '<S106>' : 'FeedbackControl/PID_Loops/RollPitch_Control/Sum/Sum_PD'
 * '<S107>' : 'FeedbackControl/PID_Loops/RollPitch_Control/Sum Fdbk/Disabled'
 * '<S108>' : 'FeedbackControl/PID_Loops/RollPitch_Control/Tracking Mode/Disabled'
 * '<S109>' : 'FeedbackControl/PID_Loops/RollPitch_Control/Tracking Mode Sum/Passthrough'
 * '<S110>' : 'FeedbackControl/PID_Loops/RollPitch_Control/Tsamp - Integral/TsSignalSpecification'
 * '<S111>' : 'FeedbackControl/PID_Loops/RollPitch_Control/Tsamp - Ngain/Passthrough'
 * '<S112>' : 'FeedbackControl/PID_Loops/RollPitch_Control/postSat Signal/Forward_Path'
 * '<S113>' : 'FeedbackControl/PID_Loops/RollPitch_Control/preInt Signal/Internal PreInt'
 * '<S114>' : 'FeedbackControl/PID_Loops/RollPitch_Control/preSat Signal/Forward_Path'
 */
#endif                                 /* FeedbackControl_h_ */

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
