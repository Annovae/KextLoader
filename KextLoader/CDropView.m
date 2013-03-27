//
//  CDropView.m
//  KextLoader
//
//  Created by 안 승례 on 13. 3. 26..
//  Copyright (c) 2013년 안 승례. All rights reserved.
//

#import "CDropView.h"
#import <IOKit/kext/KextManager.h>

@implementation CDropView

- (id) initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self)
    {
        [self registerForDraggedTypes:[NSArray arrayWithObjects: NSURLPboardType, nil]];
    }
    return self;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    NSURL* pFileURL;
    NSPasteboard* pPboard = [NSPasteboard pasteboardWithName: NSDragPboard];
    [pFileURL writeToPasteboard: pPboard];
    
    return NSDragOperationGeneric;
}

- (BOOL) performDragOperation:(id<NSDraggingInfo>)sender
{
    BOOL bReturn = YES;
    NSPasteboard* pPboard = [sender draggingPasteboard];
    
    if ([[pPboard types] containsObject: NSURLPboardType])
    {
        NSURL* pFileURL = [NSURL URLFromPasteboard: pPboard];
        NSLog(@"file Path %@\n", [pFileURL path]);
        
        //Load Kexts
        CFURLRef kextUrl = (__bridge CFURLRef)pFileURL;
        OSReturn result = KextManagerLoadKextWithURL(kextUrl, NULL);
        CFRelease(kextUrl);
        if (result != kOSReturnSuccess)
        {
            NSLog(@"Cannot load kext from %@\n", [pFileURL path]);
            bReturn = NO;
            goto EXIT;
        }
    }
    
EXIT:
    return bReturn;
}
@end
