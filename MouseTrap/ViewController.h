//
//  ViewController.h
//  MouseTrap
//
//  Created by Thomas Cherry on 10/25/14.
//  Copyright (c) 2014 Thomas Cherry. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@import Quartz;

#import "MT_Focus.h"

@interface ViewController : NSViewController <MT_FocusDelegate>

@property (weak) IBOutlet NSTextFieldCell *currentApp;

@property (weak) IBOutlet NSTextFieldCell *button1;
@property (weak) IBOutlet NSTextFieldCell *button2;
@property (weak) IBOutlet NSTextFieldCell *button3;
@property (weak) IBOutlet NSTextFieldCell *keys;
@property (weak) IBOutlet NSTextFieldCell *mLoc;

@property (weak) IBOutlet NSImageView *leftEye;
@property (weak) IBOutlet NSImageView *rightEye;

@property (weak) IBOutlet NSImageView *appImgWrapper;
@property (weak) IBOutlet NSImageCell *appImg;
@property (weak) IBOutlet PDFView *appPdf;

@end

