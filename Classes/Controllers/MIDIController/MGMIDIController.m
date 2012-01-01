//
//  MGMIDIController.m
//  MetroGnomeiPad
//
//  Created by Zander on 10/8/11.
//  Copyright 2011 MetroGnome, LLC. All rights reserved.
//

#import "MGMIDIController.h"

#import "bass.h"
#import "bassmidi.h"
#import "MGInstrument.h"
#import "MGSoundFont.h"
#import "MGNote.h"
#import "MGChord.h"
#import "MIDIValues.h"
#import "MGMidiFile.h"

#import "MidiFile.h"

@interface MGMIDIController (Private)
-(HSTREAM)initStream;
-(void)testScale;
-(void)testBachChorale;
-(void)testMIDIFile;
-(void)testVaidyanathan;
@end



@implementation MGMIDIController

-(void)dealloc {
    [super dealloc];   
}

-(id)init {
    if (self=[super init]) {
        //Load BASSMIDI plugin
        extern void BASSMIDIplugin;
        BASS_PluginLoad(&BASSMIDIplugin, 0);
        BASS_Init(-1, 44100, 0, 0, nil);//self.window); 
    }
    return self;   
}

-(void)test {
    //[self testScale];
    //[self testMIDIFile];
    //[self writeMIDI:nil];
    //[self loadMIDI:nil];
    [self testVaidyanathan];
    return;
    
    HSTREAM stream = [self initStream];
    MGInstrument *testInstrument = [[MGInstrument alloc]initWithSoundFont:nil instrumentType:nil];
    
    BASS_MIDI_FONT streamFont[1];
    streamFont[0] = [testInstrument.soundFont getBASSMIDIFONT];
    [testInstrument release];
    
    BASS_MIDI_StreamSetFonts(stream, streamFont, 1); // apply it to the stream
    
    MGNote *testNote = [[MGNote alloc]initWithPitchClass:PITCH_CLASS_C
                                                  octave:4
                                                duration:2];

    MGNote *testNote2 = [[MGNote alloc]initWithPitchClass:PITCH_CLASS_D
                                                   octave:4
                                                 duration:2];
    
    MGChord *testChord = [[MGChord alloc]initMajorTriadWithTonic:testNote];
    MGChord *testChord2 = [[MGChord alloc]initMajorTriadWithTonic:testNote2];
    
    [testNote release];
    [testNote2 release];
    
    
    MGPart *testPart = [[MGPart alloc]initWithCapacity:2];
    [testPart add:testChord];
    [testChord release];
    [testPart add:testChord2];
    [testChord2 release];
    
    
    [testPart play:stream];
    [testPart release];
}

-(void)testScale {
    HSTREAM stream = [self initStream];
    MGInstrument *testInstrument = [[MGInstrument alloc]initWithSoundFont:nil instrumentType:nil];
    
    BASS_MIDI_FONT streamFont[1];
    streamFont[0] = [testInstrument.soundFont getBASSMIDIFONT];
    [testInstrument release];
    
    BASS_MIDI_StreamSetFonts(stream, streamFont, 1); // apply it to the stream
    
    
    int scaleLength = 13;
    MGPart *testPart = [[MGPart alloc]initWithCapacity:scaleLength];
    for (int i = 0; i < scaleLength; i++) {
        MGNote *testNote = [[MGNote alloc] initWithPitchClass:i
                              octave:4
                            duration:1];

        [testPart add:testNote];
        [testNote release];
    }
        
    [testPart play:stream];
    [testPart release];
}


-(void)testMIDIFile {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Chopin Ocean Etude" ofType:@"mid"];  
    HSTREAM stream=BASS_MIDI_StreamCreateFile(FALSE, [filePath UTF8String], 0, 0, 0, 44100);
    if (BASS_ErrorGetCode()) {
        NSLog(@"Bass error: %i", BASS_ErrorGetCode());
    }

    MGInstrument *testInstrument = [[MGInstrument alloc]initWithSoundFont:nil instrumentType:nil];
    
    BASS_MIDI_FONT streamFont[1];
    streamFont[0] = [testInstrument.soundFont getBASSMIDIFONT];
    [testInstrument release];
    
    BASS_MIDI_StreamSetFonts(stream, streamFont, 1); // apply it to the stream
    BASS_ChannelPlay(stream, FALSE);
    
    NSLog(@"testMidiFile complete");
}

//incomplete, needs instrument/soundfonts //still true?
-(void)play:(MGPart *)part {
    HSTREAM stream = [self initStream];
    
    [part play:stream];
}

//Currently not using args
-(void)writeMIDI:(MGPart *)part {
    NSArray *myPathList =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *myPath    =  [myPathList  objectAtIndex:0];
    NSError **err;
    
    NSString *fileName = [NSString stringWithFormat:@"test.mid"];
    myPath = [myPath stringByAppendingPathComponent:fileName];
        
    if(![[NSFileManager defaultManager] fileExistsAtPath:myPath])
    {
        [[NSFileManager defaultManager] createFileAtPath:myPath contents:nil attributes:nil];
        [[NSString stringWithFormat:@"SUCCESS"] writeToFile:myPath atomically:NO encoding:NSUTF8StringEncoding error:err];
    }
    else
    {
        NSLog(@"writeMIDI: Cannot overwrite existing file %@", fileName);
    }
}

-(void)loadMIDI:(MGPart *)part {
    NSArray *myPathList =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *myPath =  [myPathList  objectAtIndex:0];
    NSError **err;
    
    NSString *fileName = [NSString stringWithFormat:@"test.mid"];
    myPath = [myPath stringByAppendingPathComponent:fileName];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:myPath])
    {
        NSLog(@"%@",[NSString stringWithContentsOfFile:myPath encoding:NSUTF8StringEncoding error:err]);
    }
    
    else NSLog(@"loadMIDI: Error loading contents of %@", fileName);
}

//Note that files MetroGnome creates itself will not be in mainBundle
-(void)testVaidyanathan {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Chopin Ocean Etude" ofType:@"mid"]; 
    MidiFile *midiFile = [[MidiFile alloc] initWithFile:filePath];    

    //NSLog(@"%@", [midiFile description]);
    
    
    //try writing midi file
//    NSArray *myPathList =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *myPath    =  [myPathList  objectAtIndex:0];
//    
//    NSString *fileName = [NSString stringWithFormat:@"test51.mid"];
//    myPath = [myPath stringByAppendingPathComponent:fileName];
//    
//    if(![[NSFileManager defaultManager] fileExistsAtPath:myPath])
//    {
//        //[[NSFileManager defaultManager] createFileAtPath:myPath contents:nil attributes:nil];
//        [MidiFile writeMidiFile:myPath withEvents:[midiFile events] andMode:1 andQuarter:192]; //guessed the mode
//        
//        //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Chopin Ocean Etude" ofType:@"mid"];  
//        HSTREAM stream=BASS_MIDI_StreamCreateFile(FALSE, [myPath UTF8String], 0, 0, 0, 44100);
//        if (BASS_ErrorGetCode()) {
//            NSLog(@"Bass error: %i", BASS_ErrorGetCode());
//        }
//        
//        MGInstrument *testInstrument = [[MGInstrument alloc]initWithSoundFont:nil instrumentType:nil];
//        
//        BASS_MIDI_FONT streamFont[1];
//        streamFont[0] = [testInstrument.soundFont getBASSMIDIFONT];
//        [testInstrument release];
//        
//        BASS_MIDI_StreamSetFonts(stream, streamFont, 1); // apply it to the stream
//        BASS_ChannelPlay(stream, FALSE);
//        
//    }
//    else
//    {
//        NSLog(@"writeMIDI: Cannot overwrite existing file %@", fileName);
//    }
    
    [midiFile transposeByAmount:INTERVAL_A4];
    NSLog(@"%@", [midiFile description]);
    
    NSString *tempFileName = [midiFile writeTemporaryMIDI];
    HSTREAM stream=BASS_MIDI_StreamCreateFile(FALSE, [tempFileName UTF8String], 0, 0, 0, 44100);
    if (BASS_ErrorGetCode()) {
    NSLog(@"Bass error: %i", BASS_ErrorGetCode());
    }
    MGInstrument *testInstrument = [[MGInstrument alloc]initWithSoundFont:nil instrumentType:nil];
    BASS_MIDI_FONT streamFont[1];
    streamFont[0] = [testInstrument.soundFont getBASSMIDIFONT];
    [testInstrument release];
    
    BASS_MIDI_StreamSetFonts(stream, streamFont, 1); // apply it to the stream
    BASS_ChannelPlay(stream, FALSE);

    
    [midiFile release];
    
    
    //MidiFile *mgMidiFile = [[MGMidiFile alloc] initWithFile:filePath];
    //NSLog(@"%@", [mgMidiFile.timeSignature description]);
    
    
    NSLog(@"testVaidyanathan complete");  
}



#pragma mark 
#pragma mark Private

-(HSTREAM)initStream {
    HSTREAM stream = BASS_MIDI_StreamCreate(16, BASS_SAMPLE_FLOAT, 0);
    BASS_ChannelPlay(stream, FALSE);
    return stream;
}

-(void)initFonts {
    
}



@end
