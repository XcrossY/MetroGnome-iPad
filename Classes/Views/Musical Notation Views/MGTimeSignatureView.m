//
//  MGTimeSignatureView.m
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 1/28/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "MGTimeSignatureView.h"

@implementation MGTimeSignatureView

-(id)initWithTimeSignature:(MGTimeSignature *)timeSignature {
    if (timeSignature.numerator == 4 && timeSignature.denominator == 4) {
        [self initWithImage:[UIImage imageNamed:@"TimeSignature44.png"]];
    }
    else if (timeSignature.numerator == 3 && timeSignature.denominator == 4) {
        [self initWithImage:[UIImage imageNamed:@"TimeSignature34.png"]];
    }
    else {
        NSLog(@"MGTimeSignatureView: currently unsupported meter");
    }
    return self; 
}


@end
