//
//  MT_Focus.h
//  MouseTrap
//
//  Created by Thomas Cherry on 10/25/14.
//  Copyright (c) 2014 Thomas Cherry. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol MT_FocusDelegate <NSObject>
@optional
- (void)currentAppName:(NSString*)name;
@end

@interface MT_Focus : NSObject
@property (nonatomic,weak) id <MT_FocusDelegate> delegate;
- (void)run;
@end

