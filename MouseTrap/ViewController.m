//
//  ViewController.m
//  MouseTrap
//
//  Created by Thomas Cherry on 10/25/14.
//  Copyright (c) 2014 Thomas Cherry. All rights reserved.
//

#import "ViewController.h"
#include <math.h>

MT_Focus* focus = nil;
NSTimer* timer = nil;
NSString* current = nil;
double leftAngle = 0;
double rightAngle = 0;

/******************************************************************************/

@implementation ViewController

- (void)viewWillAppear
{
    //NSImageView* iview = [NSImageView new];
    //[self setAppImg:iview];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    [[self button1] setTitle:@""];
    [[self button2] setTitle:@""];
    [[self button3] setTitle:@""];
    [[self keys] setTitle:@""];
    
    //NSImage* eye = [NSImage imageNamed:@"eye"];
    //[[self leftEye] setImage:eye];
    //[[self rightEye] setImage:eye];
    
    NSEvent* (^eventBlockevent)(NSEvent*) = ^(NSEvent* e)
    {
        [self doMouseEvent:e];
        return e;
    };
    
    void (^eventBlock)(NSEvent* e) = ^(NSEvent* e)
    {
        [self doMouseEvent:e];
    };
    
    [NSEvent addGlobalMonitorForEventsMatchingMask:
        NSMouseMovedMask
            | NSLeftMouseDownMask | NSLeftMouseUpMask
            | NSRightMouseDownMask | NSRightMouseUpMask
            | NSOtherMouseDownMask | NSOtherMouseUpMask
            | NSKeyDownMask | NSKeyUpMask
        handler:eventBlock];
    
    [NSEvent addLocalMonitorForEventsMatchingMask:
        NSAnyEventMask
        handler:eventBlockevent];
    
    focus = [[MT_Focus alloc] init];
    [focus setDelegate:self];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
        target:focus
        selector:@selector(run)
        userInfo:nil
        repeats:YES];
}

- (void)currentAppName:(NSString*)name
{
    [[self currentApp] setTitle:name];
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(
        NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString* appSupportDir = [paths objectAtIndex:0];
	//NSError* error = nil;
    NSFileManager* fm = [NSFileManager defaultManager];
    
    NSString* appName = [[NSBundle mainBundle]
        objectForInfoDictionaryKey:@"CFBundleName"];
    
	NSString* path = [NSString stringWithFormat:@"%@/%@/images/%@.png"
        , appSupportDir
        , appName
        , name];
    
    if (![fm fileExistsAtPath:path])
    {
        path = [NSString stringWithFormat:@"%@/%@/images/%@.pdf"
            , appSupportDir
            , appName
            , name];
    
        if (![fm fileExistsAtPath:path])
        {//nothing to do
            path = [NSString stringWithFormat:@"%@/%@/images/%@.png"
                , appSupportDir
                , appName
                , @"General"];
        }
    }
    if (![current isEqualToString:path])
    {
        NSString* ext = [path pathExtension];
        if ([ext isEqualToString:@"png"])
        {
            NSImage* picture =  [[NSImage alloc] initWithContentsOfFile: path];
            if (picture!=nil)
            {
                //NSLog(@"setting %@", path);
                [[self appImgWrapper] setImage:picture];
                [[self appPdf] setHidden:YES];
                [[self appImgWrapper] setHidden:NO];
            
                /*NSLog(@"%f,%f"
                    , [[self appImg] bounds].size.width
                    , [[self appImg] bounds].size.height);*/
                current = path;
                return;
            }
        }
        else if ([ext isEqualToString:@"pdf"])
        {
            NSURL* url = [NSURL fileURLWithPath:path];
            PDFDocument* doc = [[PDFDocument alloc] initWithURL:url];
        
            [[self appPdf] setDocument:doc];
            [[self appImgWrapper] setHidden:YES];
            [[self appPdf] setHidden:NO];
            current = path;
            return;
        }
        current = nil;
    }
    else
    {
        //NSLog(@"c=%@", current);
    }
}

- (void)doMouseEvent:(NSEvent*)e
{
    NSString* str
        = [NSString stringWithFormat:@"%ld",(long)[e buttonNumber]];
    if (NSLeftMouseDown == [e type])
    {
        [[self button1] setTitle:str];
    }
    else if (NSLeftMouseUp == [e type])
    {
        [[self button1] setTitle:@""];
    }
    else if (NSRightMouseDown == [e type])
    {
        [[self button2] setTitle:str];
    }
    else if (NSRightMouseUp == [e type])
    {
        [[self button2] setTitle:@""];
    }
    else if (NSOtherMouseDown == [e type])
    {
        [[self button3] setTitle:str];
    }
    else if (NSOtherMouseUp == [e type])
    {
        [[self button3] setTitle:@""];
    }
    else if (NSKeyUp == [e type])
    {
        [[self keys] setTitle:@""];
    }
    else if (NSKeyDown==[e type])
    {
        NSString* msg = [NSString stringWithFormat:@"'%@': %hu - %ld"
            , [[e characters] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
            , [e keyCode]
            , [e modifierFlags]];
        [[self keys] setTitle:msg];
    }
    else if (NSMouseMoved==[e type])
    {
        NSWindow* win = [[self view] window];
        NSString* text = nil;
        NSPoint loc = [e locationInWindow];
        NSPoint win_loc = win.frame.origin;
    
        loc = [NSEvent mouseLocation];
        text = [NSString stringWithFormat:@"%d, %d", (int)loc.x, (int)loc.y];
    
        [[self mLoc] setTitle:text];
    
        [self spinEye:[self leftEye] in:win_loc at:loc last:&leftAngle];
        [self spinEye:[self rightEye] in:win_loc at:loc last:&rightAngle];
    
        /*
        //left eye
        NSPoint left_eye_loc = self.leftEye.frame.origin;
        NSSize left_size = self.leftEye.frame.size;
        int left_offset_x = left_eye_loc.x + left_size.width/2;
        int left_offset_y = left_eye_loc.y + left_size.height/2;
    
        double left_dif_x = (win_loc.x+left_offset_x)-loc.x;
        double left_dif_y = (win_loc.y+left_offset_y)-loc.y;

        double left_angle = atan2(left_dif_y, -1*left_dif_x)*(180/M_PI);
        if (left_angle<0){left_angle += M_PI*2;}
    
        [[self leftEye] rotateByAngle:leftAngle-left_angle];
        [[self leftEye] setNeedsDisplay];
        leftAngle = left_angle;

        //right eye
        NSPoint right_eye_loc = self.rightEye.frame.origin;
        NSSize right_size = self.rightEye.frame.size;
        int right_offset_x = right_eye_loc.x + right_size.width/2;
        int right_offset_y = right_eye_loc.y + right_size.height/2;
    
        double right_dif_x = (win_loc.x+right_offset_x)-loc.x;
        double right_dif_y = (win_loc.y+right_offset_y)-loc.y;
    
        double right_angle = atan2(right_dif_y, -1*right_dif_x)*(180/M_PI);
        if (right_angle<0){right_angle += M_PI*2;}
    
        [[self rightEye] rotateByAngle:rightAngle-right_angle];
        [[self rightEye] setNeedsDisplay];    
        rightAngle = right_angle;
        */
    }
    else if (NSSystemDefined!=[e type])
    {
        //NSLog(@"%@", e);
    }
}

/**
Handles the rotation of a single eye by calculating the parent windows position
and the current mouse position.
@param eye view to spin
@param win_loc window location
@param loc mouse location
@param where to store the last angle used
*/
- (void)spinEye:(NSImageView*)eye in:(NSPoint)win_loc at:(NSPoint)loc
        last:(double*)lastAngle
{
    NSPoint eye_loc = eye.frame.origin;
    NSSize size = eye.frame.size;
    int offset_x = eye_loc.x + size.width/2;
    int offset_y = eye_loc.y + size.height/2;

    double dif_x = (win_loc.x+offset_x)-loc.x;
    double dif_y = (win_loc.y+offset_y)-loc.y;

    double angle = atan2(dif_y, -1*dif_x)*(180/M_PI);
    if (angle<0){angle += M_PI*2;}

    [eye rotateByAngle: (*lastAngle)-angle];
    [eye setNeedsDisplay];
    *lastAngle = angle;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end

