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

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <fcntl.h>
#import "Array.h"

/* The Array class is just a convenience class, which has shorter
 * method names than NSMutableArray.
 */
@implementation Array

/* Create a new array with the given capacity */
+ (id)new:(int)capacity {
    Array *a = [[Array alloc] initWithCapacity:capacity];
    return a;
}

- (id)initWithCapacity:(int)capacity {
    if (capacity == 0) {
        capacity = 1;
    }
    array = [[NSMutableArray alloc] initWithCapacity:capacity];
    return self;
}

/* free the Array */
- (void)dealloc {
    [array release];
    [super dealloc];
}
    

/* Return the size of the array */
- (int)count {
    return [array count];
}

/* Add an object to the array */
- (void)add:(id)object {
    [array addObject:object];
}

/* Retrieve an object at the given index */
- (id)get:(int)index {
    assert(index >= 0 && index < [array count]);
    return [array objectAtIndex:index];
}

/* Set an object at the given index */
- (void)set:(id)obj index:(int)x {
    assert(x >= 0 && x < [array count]);
    [array replaceObjectAtIndex:x withObject:obj];
}

/* Remove the object from the array */
- (void)remove:(id)obj {
    [array removeObject:obj];
}

/* Remove all objects from the array */
- (void)clear {
    [array removeAllObjects];
}

/* Sort the array, using the given comparison function.
 * Use mergesort over quicksort In MidiFile.m, the MidiNote
 * arrays are already mostly sorted, so quicksort won't work
 * well here.
 */
- (void)sort:(int (*)(void *, void*)) compare {
    int count = [array count];
    void** temparray = (void**) malloc(sizeof(void*) * count);
    for (int i = 0; i < count; i++) {
        id obj = [ [array objectAtIndex:i] retain];
        temparray[i] = (void*) obj;
    }
    mergesort(temparray, count, sizeof(void*), compare);
    [self clear];
    for (int i = 0; i < count; i++) {
        id obj = (id) temparray[i];
        [array addObject:obj];
        [obj release];
    }
    free(temparray);
} 


/* Return a sub-range of the Array */
- (Array*)range:(int)start end:(int)n {
    Array *result = [Array new:[array count]/2];
    for (int i = start; i < n; i++) {
        [result add:[array objectAtIndex:i]];
    }
    return result;
}

/* Filter the array using the given function */
- (Array*)filter:(BOOL(*)(id)) func  {
    Array *result = [Array new:[array count]/2];
    for (int i = 0; i < [array count]; i++) {
        id obj = [array objectAtIndex:i];
        if (func(obj)) {
            [result add:obj];
        }
    }
    return result;
}


@end


/* The IntArray class is similar to the Array class
 * above, but it stores "int" instead of objects.
 */
@implementation IntArray

/* Allocate a new integer array, with the given capacity */
+ (id)new:(int)capacity {
    IntArray *arr = [[IntArray alloc] initWithCapacity:capacity];
    return arr;
}

- (id)initWithCapacity:(int)newcapacity {
    assert(newcapacity >= 0);
    if (newcapacity == 0)
        newcapacity = 1;
    capacity = newcapacity;
    size = 0;
    values = (int*)calloc(capacity, sizeof(int));
    return self;
}

/* Free the integer array */
- (void)dealloc {
    free(values);
    [super dealloc];
}

/* Append integer x to the end of the array.
 * If needed, increase the capacity of the array.
 */
- (void)add:(int)x {
    if (size == capacity) {
        int newcapacity = 2*capacity;
        int* newvalues = (int*)calloc(newcapacity, sizeof(int));
        for (int i = 0; i < size; i++) {
            newvalues[i] = values[i];
        }
        free(values);
        values = newvalues;
        capacity = newcapacity;
    }
    values[size] = x;
    size++;
}

/* Return the integer at the given index */
- (int)get:(int)index {
	assert(index >= 0 && index < size);
    return values[index];
}

/* Set the integer at index i to the value x */
- (void)set:(int)x index:(int)i {
	assert(i >= 0 && i < size);
    values[i] = x;
}

/* Return YES if this array contains the given integer x.
 * Else, return NO.
 */
- (BOOL)contains:(int)x {
    for (int i = 0; i < size; i++) {
        if (values[i] == x) {
            return YES;
        }
    }
    return NO;
}

/* Return the index of the given integer x in the array.
 * This method assumes that x is definitely in the array.
 */
- (int)indexOf:(int)x {
    int startindex = 0;
    int endindex = size;
    int pos = startindex + (endindex - startindex)/2;
    while (values[pos] != x) {
        if (values[pos] < x) {
            startindex = pos;
            pos = startindex + (endindex - startindex)/2;
        }
        else {
            endindex = pos;
            pos = startindex + (endindex - startindex)/2;
        }
    }
    return pos;
}

/* Return the number of items in the array */
- (int)count {
    return size;
}

/* Comparison function for sorting the integer array. */
static int intcmp(const void *v1, const void* v2) {
    int *x1 = (int*) v1;
    int *x2 = (int*) v2;
    return (*x1) - (*x2);
}

/** Sort the int array using mergesort.
 *  Don't use quicksort. In MidiFile.m, we're sorting lots of 
 *  MidiNotes that are already mostly sorted, and quicksort
 *  performs badly on those.
 */
- (void)sort {
    mergesort(values, size, sizeof(int), intcmp);
}

/** Finds maximum value in the IntArray */
-(int)maximum {
    int maximum = [self get:0];
    for (int i = 1; i < size; i++) {
        int num = [self get:i];
        if (num >= maximum) {
            maximum = num; 
        }
    }
    return maximum;
}


/** Goes through the IntArray and returns the index 
 of the maximum value. Ties go to the later indices */
-(int)indexOfMaximum {
    int index = 0;
    int maximum = [self get:0];
    for (int i = 1; i < size; i++) {
        int num = [self get:i];
        if (num >= maximum) {
            index = i; 
        }
    }
    
    return index;
}

/** Sum of all integers in IntArray */
-(int)totalValue {
    int total = 0;
    for (int i = 0; i < size; i++) {
        total = total + [self get:i];
    }
    
    return total;
}



@end

