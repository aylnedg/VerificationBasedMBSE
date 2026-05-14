/*
 * Prerelease License - for engineering feedback and testing purposes
 * only. Not for sale.
 *
 * File: FeedbackControl_types.h
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

#ifndef FeedbackControl_types_h_
#define FeedbackControl_types_h_
#include "rtwtypes.h"
#ifndef DEFINED_TYPEDEF_FOR_MultirotorGuidanceControlBus_
#define DEFINED_TYPEDEF_FOR_MultirotorGuidanceControlBus_

typedef struct {
  real_T Roll;
  real_T Pitch;
  real_T YawRate;
  real_T Thrust;
} MultirotorGuidanceControlBus;

#endif

/* Forward declaration for rtModel */
typedef struct tag_RTM_FeedbackControl_T RT_MODEL_FeedbackControl_T;

#endif                                 /* FeedbackControl_types_h_ */

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
