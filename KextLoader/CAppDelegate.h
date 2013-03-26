//
//  CAppDelegate.h
//  KextLoader
//
//  Created by 안 승례 on 13. 3. 26..
//  Copyright (c) 2013년 안 승례. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CDropView.h"

@interface CAppDelegate : NSObject <NSApplicationDelegate>
@property (weak) IBOutlet NSButton *loadDriver;
@property (weak) IBOutlet NSTextField *notifyMessage;
@property (weak) IBOutlet NSProgressIndicator *runningIndicator;
@property (weak) IBOutlet NSScrollView *messageBoard;
@property (weak) IBOutlet CDropView *DropZone;

@property (assign) IBOutlet NSWindow *window;
- (IBAction)loadDriver:(id)sender;

@end
