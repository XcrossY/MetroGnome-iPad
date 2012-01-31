/*
 * Copyright (c) 2007-2009 Madhav Vaidyanathan
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License version 2.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 */

#import <Foundation/NSArray.h>

@interface Array : NSObject {
    NSMutableArray *array;
}
+(id)new:(int)capacity;
-(id)initWithCapacity:(int)amount;
-(void)dealloc;
-(int)count;
-(void)add:(id)object;
-(id)get:(int)index;
-(void)set:(id)object index:(int)x;
-(void)remove:(id)obj;
-(void)clear;
-(void)sort:(int(*)(void*, void*)) compare;
-(Array*)range:(int)start end:(int)n;
-(Array*)filter:(BOOL(*)(id)) compare;

@end

@interface IntArray : NSObject {
    int *values;  /* The array of integers */
    int size;     /* The size of the array */
    int capacity; /* The capacity of the array */
}
+(id)new:(int)capacity;
-(id)initWithCapacity:(int)capacity;
-(void)dealloc;
-(void)add:(int)x;
-(int)get:(int)index;
-(void)set:(int)x index:(int) x;
-(int)indexOf:(int)x;
-(BOOL)contains:(int)x;
-(int)count;
-(void)sort;
-(int)maximum;
-(int)indexOfMaximum;
-(int)totalValue;

@end


