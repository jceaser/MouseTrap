//
//  MT_Focus.m
//  MouseTrap
//
//  Created by Thomas Cherry on 10/25/14.
//  Copyright (c) 2014 Thomas Cherry. All rights reserved.
//

#import "MT_Focus.h"

/******************************************************************************/

@implementation MT_Focus
@synthesize delegate;
- (void)run
{
    if ([self delegate]!=nil)
    {
        for (NSRunningApplication* currApp in [[NSWorkspace sharedWorkspace]
                runningApplications])
        {
            if ([currApp isActive])
            {
                [[self delegate] currentAppName:[currApp localizedName]];
            }
        }
    }
}
@end
