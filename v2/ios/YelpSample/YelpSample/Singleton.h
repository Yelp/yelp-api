//
//  SynthesizeSingleton.h
//  CocoaWithLove
//
//  Created by Matt Gallagher on 20/10/08.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Modified later to work with ARC.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#define SYNTHESIZE_SINGLETON_FOR_HEADER(classname) \
+ (classname *)sharedInstance;

#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
 \
    static classname *sharedInstance = nil; \
    static dispatch_once_t onceToken; \
 \
+ (classname *)sharedInstance \
{ \
	@synchronized(self) \
	{ \
        dispatch_once(&onceToken, ^{ \
            sharedInstance = [[classname alloc] init]; \
        }); \
	} \
	 \
	return sharedInstance; \
} \
 \
