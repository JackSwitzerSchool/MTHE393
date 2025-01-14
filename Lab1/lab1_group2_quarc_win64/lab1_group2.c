/*
 * lab1_group2.c
 *
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Code generation for model "lab1_group2".
 *
 * Model version              : 13.0
 * Simulink Coder version : 9.7 (R2022a) 13-Nov-2021
 * C source code generated on : Tue Jan 14 10:05:46 2025
 *
 * Target selection: quarc_win64.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64 (Windows64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "lab1_group2.h"
#include "rtwtypes.h"
#include "lab1_group2_private.h"
#include "rt_nonfinite.h"
#include "lab1_group2_dt.h"

/* Block signals (default storage) */
B_lab1_group2_T lab1_group2_B;

/* Block states (default storage) */
DW_lab1_group2_T lab1_group2_DW;

/* Real-time model */
static RT_MODEL_lab1_group2_T lab1_group2_M_;
RT_MODEL_lab1_group2_T *const lab1_group2_M = &lab1_group2_M_;

/* Model output function */
void lab1_group2_output(void)
{
  real_T rtb_HILReadAnalog;

  /* Constant: '<Root>/Constant' */
  lab1_group2_B.Constant = lab1_group2_P.Constant_Value;

  /* S-Function (hil_write_analog_block): '<Root>/HIL Write Analog' */

  /* S-Function Block: lab1_group2/HIL Write Analog (hil_write_analog_block) */
  {
    t_error result;
    result = hil_write_analog(lab1_group2_DW.HILInitialize_Card,
      &lab1_group2_P.HILWriteAnalog_channels, 1, &lab1_group2_B.Constant);
    if (result < 0) {
      msg_get_error_messageA(NULL, result, _rt_error_message, sizeof
        (_rt_error_message));
      rtmSetErrorStatus(lab1_group2_M, _rt_error_message);
    }
  }

  /* S-Function (hil_read_encoder_block): '<Root>/HIL Read Encoder' */

  /* S-Function Block: lab1_group2/HIL Read Encoder (hil_read_encoder_block) */
  {
    t_error result = hil_read_encoder(lab1_group2_DW.HILInitialize_Card,
      &lab1_group2_P.HILReadEncoder_channels, 1,
      &lab1_group2_DW.HILReadEncoder_Buffer);
    if (result < 0) {
      msg_get_error_messageA(NULL, result, _rt_error_message, sizeof
        (_rt_error_message));
      rtmSetErrorStatus(lab1_group2_M, _rt_error_message);
    } else {
      rtb_HILReadAnalog = lab1_group2_DW.HILReadEncoder_Buffer;
    }
  }

  /* Gain: '<Root>/Gain' */
  lab1_group2_B.Gain = lab1_group2_P.Gain_Gain * rtb_HILReadAnalog;

  /* S-Function (hil_read_analog_block): '<Root>/HIL Read Analog' */

  /* S-Function Block: lab1_group2/HIL Read Analog (hil_read_analog_block) */
  {
    t_error result = hil_read_analog(lab1_group2_DW.HILInitialize_Card,
      &lab1_group2_P.HILReadAnalog_channels, 1,
      &lab1_group2_DW.HILReadAnalog_Buffer);
    if (result < 0) {
      msg_get_error_messageA(NULL, result, _rt_error_message, sizeof
        (_rt_error_message));
      rtmSetErrorStatus(lab1_group2_M, _rt_error_message);
    }

    rtb_HILReadAnalog = lab1_group2_DW.HILReadAnalog_Buffer;
  }

  /* Gain: '<Root>/Gain1' */
  lab1_group2_B.Gain1 = lab1_group2_P.Gain1_Gain * rtb_HILReadAnalog;
}

/* Model update function */
void lab1_group2_update(void)
{
  /* Update absolute time for base rate */
  /* The "clockTick0" counts the number of times the code of this task has
   * been executed. The absolute time is the multiplication of "clockTick0"
   * and "Timing.stepSize0". Size of "clockTick0" ensures timer will not
   * overflow during the application lifespan selected.
   * Timer of this task consists of two 32 bit unsigned integers.
   * The two integers represent the low bits Timing.clockTick0 and the high bits
   * Timing.clockTickH0. When the low bit overflows to 0, the high bits increment.
   */
  if (!(++lab1_group2_M->Timing.clockTick0)) {
    ++lab1_group2_M->Timing.clockTickH0;
  }

  lab1_group2_M->Timing.t[0] = lab1_group2_M->Timing.clockTick0 *
    lab1_group2_M->Timing.stepSize0 + lab1_group2_M->Timing.clockTickH0 *
    lab1_group2_M->Timing.stepSize0 * 4294967296.0;
}

/* Model initialize function */
void lab1_group2_initialize(void)
{
  /* Start for S-Function (hil_initialize_block): '<Root>/HIL Initialize' */

  /* S-Function Block: lab1_group2/HIL Initialize (hil_initialize_block) */
  {
    t_int result;
    t_boolean is_switching;
    result = hil_open("q2_usb", "0", &lab1_group2_DW.HILInitialize_Card);
    if (result < 0) {
      msg_get_error_messageA(NULL, result, _rt_error_message, sizeof
        (_rt_error_message));
      rtmSetErrorStatus(lab1_group2_M, _rt_error_message);
      return;
    }

    is_switching = false;
    result = hil_set_card_specific_options(lab1_group2_DW.HILInitialize_Card,
      "d0=digital;d1=digital;led=auto;update_rate=normal;decimation=1", 63);
    if (result < 0) {
      msg_get_error_messageA(NULL, result, _rt_error_message, sizeof
        (_rt_error_message));
      rtmSetErrorStatus(lab1_group2_M, _rt_error_message);
      return;
    }

    result = hil_watchdog_clear(lab1_group2_DW.HILInitialize_Card);
    if (result < 0 && result != -QERR_HIL_WATCHDOG_CLEAR) {
      msg_get_error_messageA(NULL, result, _rt_error_message, sizeof
        (_rt_error_message));
      rtmSetErrorStatus(lab1_group2_M, _rt_error_message);
      return;
    }

    if ((lab1_group2_P.HILInitialize_AIPStart && !is_switching) ||
        (lab1_group2_P.HILInitialize_AIPEnter && is_switching)) {
      lab1_group2_DW.HILInitialize_AIMinimums[0] =
        (lab1_group2_P.HILInitialize_AILow);
      lab1_group2_DW.HILInitialize_AIMinimums[1] =
        (lab1_group2_P.HILInitialize_AILow);
      lab1_group2_DW.HILInitialize_AIMaximums[0] =
        lab1_group2_P.HILInitialize_AIHigh;
      lab1_group2_DW.HILInitialize_AIMaximums[1] =
        lab1_group2_P.HILInitialize_AIHigh;
      result = hil_set_analog_input_ranges(lab1_group2_DW.HILInitialize_Card,
        lab1_group2_P.HILInitialize_AIChannels, 2U,
        &lab1_group2_DW.HILInitialize_AIMinimums[0],
        &lab1_group2_DW.HILInitialize_AIMaximums[0]);
      if (result < 0) {
        msg_get_error_messageA(NULL, result, _rt_error_message, sizeof
          (_rt_error_message));
        rtmSetErrorStatus(lab1_group2_M, _rt_error_message);
        return;
      }
    }

    if ((lab1_group2_P.HILInitialize_AOPStart && !is_switching) ||
        (lab1_group2_P.HILInitialize_AOPEnter && is_switching)) {
      result = hil_set_analog_output_ranges(lab1_group2_DW.HILInitialize_Card,
        &lab1_group2_P.HILInitialize_AOChannels, 1U,
        &lab1_group2_P.HILInitialize_AOLow, &lab1_group2_P.HILInitialize_AOHigh);
      if (result < 0) {
        msg_get_error_messageA(NULL, result, _rt_error_message, sizeof
          (_rt_error_message));
        rtmSetErrorStatus(lab1_group2_M, _rt_error_message);
        return;
      }
    }

    if ((lab1_group2_P.HILInitialize_AOStart && !is_switching) ||
        (lab1_group2_P.HILInitialize_AOEnter && is_switching)) {
      result = hil_write_analog(lab1_group2_DW.HILInitialize_Card,
        &lab1_group2_P.HILInitialize_AOChannels, 1U,
        &lab1_group2_P.HILInitialize_AOInitial);
      if (result < 0) {
        msg_get_error_messageA(NULL, result, _rt_error_message, sizeof
          (_rt_error_message));
        rtmSetErrorStatus(lab1_group2_M, _rt_error_message);
        return;
      }
    }

    if (lab1_group2_P.HILInitialize_AOReset) {
      result = hil_watchdog_set_analog_expiration_state
        (lab1_group2_DW.HILInitialize_Card,
         &lab1_group2_P.HILInitialize_AOChannels, 1U,
         &lab1_group2_P.HILInitialize_AOWatchdog);
      if (result < 0) {
        msg_get_error_messageA(NULL, result, _rt_error_message, sizeof
          (_rt_error_message));
        rtmSetErrorStatus(lab1_group2_M, _rt_error_message);
        return;
      }
    }

    if ((lab1_group2_P.HILInitialize_EIPStart && !is_switching) ||
        (lab1_group2_P.HILInitialize_EIPEnter && is_switching)) {
      result = hil_set_encoder_quadrature_mode(lab1_group2_DW.HILInitialize_Card,
        &lab1_group2_P.HILInitialize_EIChannels, 1U, (t_encoder_quadrature_mode *)
        &lab1_group2_P.HILInitialize_EIQuadrature);
      if (result < 0) {
        msg_get_error_messageA(NULL, result, _rt_error_message, sizeof
          (_rt_error_message));
        rtmSetErrorStatus(lab1_group2_M, _rt_error_message);
        return;
      }
    }

    if ((lab1_group2_P.HILInitialize_EIStart && !is_switching) ||
        (lab1_group2_P.HILInitialize_EIEnter && is_switching)) {
      result = hil_set_encoder_counts(lab1_group2_DW.HILInitialize_Card,
        &lab1_group2_P.HILInitialize_EIChannels, 1U,
        &lab1_group2_P.HILInitialize_EIInitial);
      if (result < 0) {
        msg_get_error_messageA(NULL, result, _rt_error_message, sizeof
          (_rt_error_message));
        rtmSetErrorStatus(lab1_group2_M, _rt_error_message);
        return;
      }
    }
  }

  /* Start for Constant: '<Root>/Constant' */
  lab1_group2_B.Constant = lab1_group2_P.Constant_Value;
}

/* Model terminate function */
void lab1_group2_terminate(void)
{
  /* Terminate for S-Function (hil_initialize_block): '<Root>/HIL Initialize' */

  /* S-Function Block: lab1_group2/HIL Initialize (hil_initialize_block) */
  {
    t_boolean is_switching;
    t_int result;
    t_uint32 num_final_analog_outputs = 0;
    hil_task_stop_all(lab1_group2_DW.HILInitialize_Card);
    hil_monitor_stop_all(lab1_group2_DW.HILInitialize_Card);
    is_switching = false;
    if ((lab1_group2_P.HILInitialize_AOTerminate && !is_switching) ||
        (lab1_group2_P.HILInitialize_AOExit && is_switching)) {
      num_final_analog_outputs = 1U;
    } else {
      num_final_analog_outputs = 0;
    }

    if (num_final_analog_outputs > 0) {
      result = hil_write_analog(lab1_group2_DW.HILInitialize_Card,
        &lab1_group2_P.HILInitialize_AOChannels, num_final_analog_outputs,
        &lab1_group2_P.HILInitialize_AOFinal);
      if (result < 0) {
        msg_get_error_messageA(NULL, result, _rt_error_message, sizeof
          (_rt_error_message));
        rtmSetErrorStatus(lab1_group2_M, _rt_error_message);
      }
    }

    hil_task_delete_all(lab1_group2_DW.HILInitialize_Card);
    hil_monitor_delete_all(lab1_group2_DW.HILInitialize_Card);
    hil_close(lab1_group2_DW.HILInitialize_Card);
    lab1_group2_DW.HILInitialize_Card = NULL;
  }
}

/*========================================================================*
 * Start of Classic call interface                                        *
 *========================================================================*/
void MdlOutputs(int_T tid)
{
  lab1_group2_output();
  UNUSED_PARAMETER(tid);
}

void MdlUpdate(int_T tid)
{
  lab1_group2_update();
  UNUSED_PARAMETER(tid);
}

void MdlInitializeSizes(void)
{
}

void MdlInitializeSampleTimes(void)
{
}

void MdlInitialize(void)
{
}

void MdlStart(void)
{
  lab1_group2_initialize();
}

void MdlTerminate(void)
{
  lab1_group2_terminate();
}

/* Registration function */
RT_MODEL_lab1_group2_T *lab1_group2(void)
{
  /* Registration code */

  /* initialize non-finites */
  rt_InitInfAndNaN(sizeof(real_T));

  /* initialize real-time model */
  (void) memset((void *)lab1_group2_M, 0,
                sizeof(RT_MODEL_lab1_group2_T));

  /* Initialize timing info */
  {
    int_T *mdlTsMap = lab1_group2_M->Timing.sampleTimeTaskIDArray;
    mdlTsMap[0] = 0;

    /* polyspace +2 MISRA2012:D4.1 [Justified:Low] "lab1_group2_M points to
       static memory which is guaranteed to be non-NULL" */
    lab1_group2_M->Timing.sampleTimeTaskIDPtr = (&mdlTsMap[0]);
    lab1_group2_M->Timing.sampleTimes = (&lab1_group2_M->
      Timing.sampleTimesArray[0]);
    lab1_group2_M->Timing.offsetTimes = (&lab1_group2_M->
      Timing.offsetTimesArray[0]);

    /* task periods */
    lab1_group2_M->Timing.sampleTimes[0] = (0.002);

    /* task offsets */
    lab1_group2_M->Timing.offsetTimes[0] = (0.0);
  }

  rtmSetTPtr(lab1_group2_M, &lab1_group2_M->Timing.tArray[0]);

  {
    int_T *mdlSampleHits = lab1_group2_M->Timing.sampleHitArray;
    mdlSampleHits[0] = 1;
    lab1_group2_M->Timing.sampleHits = (&mdlSampleHits[0]);
  }

  rtmSetTFinal(lab1_group2_M, 5.0);
  lab1_group2_M->Timing.stepSize0 = 0.002;

  /* External mode info */
  lab1_group2_M->Sizes.checksums[0] = (4130491888U);
  lab1_group2_M->Sizes.checksums[1] = (1277331825U);
  lab1_group2_M->Sizes.checksums[2] = (2515830805U);
  lab1_group2_M->Sizes.checksums[3] = (889048455U);

  {
    static const sysRanDType rtAlwaysEnabled = SUBSYS_RAN_BC_ENABLE;
    static RTWExtModeInfo rt_ExtModeInfo;
    static const sysRanDType *systemRan[1];
    lab1_group2_M->extModeInfo = (&rt_ExtModeInfo);
    rteiSetSubSystemActiveVectorAddresses(&rt_ExtModeInfo, systemRan);
    systemRan[0] = &rtAlwaysEnabled;
    rteiSetModelMappingInfoPtr(lab1_group2_M->extModeInfo,
      &lab1_group2_M->SpecialInfo.mappingInfo);
    rteiSetChecksumsPtr(lab1_group2_M->extModeInfo,
                        lab1_group2_M->Sizes.checksums);
    rteiSetTPtr(lab1_group2_M->extModeInfo, rtmGetTPtr(lab1_group2_M));
  }

  lab1_group2_M->solverInfoPtr = (&lab1_group2_M->solverInfo);
  lab1_group2_M->Timing.stepSize = (0.002);
  rtsiSetFixedStepSize(&lab1_group2_M->solverInfo, 0.002);
  rtsiSetSolverMode(&lab1_group2_M->solverInfo, SOLVER_MODE_SINGLETASKING);

  /* block I/O */
  lab1_group2_M->blockIO = ((void *) &lab1_group2_B);
  (void) memset(((void *) &lab1_group2_B), 0,
                sizeof(B_lab1_group2_T));

  /* parameters */
  lab1_group2_M->defaultParam = ((real_T *)&lab1_group2_P);

  /* states (dwork) */
  lab1_group2_M->dwork = ((void *) &lab1_group2_DW);
  (void) memset((void *)&lab1_group2_DW, 0,
                sizeof(DW_lab1_group2_T));

  /* data type transition information */
  {
    static DataTypeTransInfo dtInfo;
    (void) memset((char_T *) &dtInfo, 0,
                  sizeof(dtInfo));
    lab1_group2_M->SpecialInfo.mappingInfo = (&dtInfo);
    dtInfo.numDataTypes = 19;
    dtInfo.dataTypeSizes = &rtDataTypeSizes[0];
    dtInfo.dataTypeNames = &rtDataTypeNames[0];

    /* Block I/O transition table */
    dtInfo.BTransTable = &rtBTransTable;

    /* Parameters transition table */
    dtInfo.PTransTable = &rtPTransTable;
  }

  /* Initialize Sizes */
  lab1_group2_M->Sizes.numContStates = (0);/* Number of continuous states */
  lab1_group2_M->Sizes.numY = (0);     /* Number of model outputs */
  lab1_group2_M->Sizes.numU = (0);     /* Number of model inputs */
  lab1_group2_M->Sizes.sysDirFeedThru = (0);/* The model is not direct feedthrough */
  lab1_group2_M->Sizes.numSampTimes = (1);/* Number of sample times */
  lab1_group2_M->Sizes.numBlocks = (13);/* Number of blocks */
  lab1_group2_M->Sizes.numBlockIO = (3);/* Number of block outputs */
  lab1_group2_M->Sizes.numBlockPrms = (68);/* Sum of parameter "widths" */
  return lab1_group2_M;
}

/*========================================================================*
 * End of Classic call interface                                          *
 *========================================================================*/
