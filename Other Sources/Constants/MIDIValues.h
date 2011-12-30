/*
 *  MIDIValues.h
 *  MetroGnomeiPad
 *
 *  Created by Zander on 9/29/11.
 *  Copyright 2011 Princeton University. All rights reserved.
 *
 */

#define PITCH_CLASS_C       0
#define PITCH_CLASS_Csharp  1
#define PITCH_CLASS_Dflat   1
#define PITCH_CLASS_D       2
#define PITCH_CLASS_Dsharp  3
#define PITCH_CLASS_Eflat   3
#define PITCH_CLASS_E       4
#define PITCH_CLASS_F       5
#define PITCH_CLASS_Fsharp  6
#define PITCH_CLASS_Gflat   6
#define PITCH_CLASS_G       7
#define PITCH_CLASS_Gsharp  8
#define PITCH_CLASS_Aflat   8
#define PITCH_CLASS_A       9
#define PITCH_CLASS_Asharp  10
#define PITCH_CLASS_Bflat   10
#define PITCH_CLASS_B       11

#define PITCH_CLASS_NIL     12
#define PITCH_CLASS_TOTAL    12

#define INTERVAL_m2         1
#define INTERVAL_M2         2
#define INTERVAL_m3         3
#define INTERVAL_M3         4
#define INTERVAL_P4         5
#define INTERVAL_A4         6
#define INTERVAL_D5         6
#define INTERVAL_P5         7
#define INTERVAL_m6         8
#define INTERVAL_M6         9
#define INTERVAL_m7         10
#define INTERVAL_M7         11
#define INTERVAL_P8         12

#define BEATS_PER_MIN       60

#define KEY_SIG_MAJ         0
#define KEY_SIG_MIN         1

/* The list of Midi Events */
#define EventNoteOff         0x80
#define EventNoteOn          0x90
#define EventKeyPressure     0xA0
#define EventControlChange   0xB0
#define EventProgramChange   0xC0
#define EventChannelPressure 0xD0
#define EventPitchBend       0xE0
#define SysexEvent1          0xF0
#define SysexEvent2          0xF7
#define MetaEvent            0xFF

/* The list of Meta Events */
#define MetaEventSequence      0x0
#define MetaEventText          0x1
#define MetaEventCopyright     0x2
#define MetaEventSequenceName  0x3
#define MetaEventInstrument    0x4
#define MetaEventLyric         0x5
#define MetaEventMarker        0x6
#define MetaEventEndOfTrack    0x2F
#define MetaEventTempo         0x51
#define MetaEventSMPTEOffset   0x54
#define MetaEventTimeSignature 0x58
#define MetaEventKeySignature  0x59