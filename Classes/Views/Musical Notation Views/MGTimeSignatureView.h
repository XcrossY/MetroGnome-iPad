//
//  MGTimeSignatureView.h
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 1/28/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGTimeSignature.h"

@interface MGTimeSignatureView : UIImageView

-(id)initWithTimeSignature:(MGTimeSignature *)timeSignature;
@end
