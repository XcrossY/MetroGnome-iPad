//
//  Options.h
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 1/28/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#include "Array.h"
#include "MGTimeSignature.h"

#ifndef MetroGnomeiPad_Options_h
#define MetroGnomeiPad_Options_h

/** @struct MidiSoundOptions
 *
 * The MidiSoundOptions class contains the available options for
 * modifying the midi sound/sound during playback.
 */
struct _MidiSoundOptions {
    int  tempo;        /** The tempo, in microseconds per quarter note */
    int  transpose;    /** The amount to transpose each note by */
    int  shifttime;    /** Shift the start time by the given amount */
    int  pauseTime;    /** Start the midi music at the given pause time */
    int  numtracks;    /** The number of tracks */
    IntArray *tracks;  /** Which tracks to include (true = include) */
    BOOL useDefaultInstruments; /** If true, don't change instruments */
    IntArray *instruments;  /** The instruments to use per track */
};
typedef struct _MidiSoundOptions MidiSoundOptions;

/** @struct SheetMusicOptions
 * The SheetMusicOptions class contains the available options for
 * modifying the midi sheet music.
 */
struct _SheetMusicOptions {
    IntArray *tracks;        /** Which tracks to display (true = display) */
    BOOL scrollVert;         /** Whether to scroll vertically or horizontally */
    int numtracks;           /** Total number of tracks */
    BOOL largeNoteSize;      /** Display large or small note sizes */
    BOOL twoStaffs;          /** Combine tracks into two staffs ? */
    BOOL showNoteLetters;    /** Show the letters (A, A#, etc) next to the notes */
    int shifttime;           /** Shift note starttimes by the given amount */
    int transpose;           /** Shift note key up/down by given amount */
    id key;                  /** Use the given KeySignature */
    MGTimeSignature *time;   /** Use the given time signature */
    int combineInterval;     /** Combine notes within given time interval (msec) */
};
typedef struct _SheetMusicOptions SheetMusicOptions;


    
    
    
    
    

#endif
