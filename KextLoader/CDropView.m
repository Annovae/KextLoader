//
//  CDropView.m
//  KextLoader
//
//  Created by 안 승례 on 13. 3. 26..
//  Copyright (c) 2013년 안 승례. All rights reserved.
//

#import "CDropView.h"
#import <IOKit/kext/KextManager.h>
#import <Security/Authorization.h>

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

- (BOOL)installKLogKext: (NSString*) sourcePath
        DestinationPath: (NSString*) destPath
{
    NSString *              permRepairPath = [[NSBundle mainBundle] pathForResource:@"SetKextPermissions" ofType:@"sh"];
    
    AuthorizationRights     myRights;
    AuthorizationItem       myItems[1];
    AuthorizationRef        authorizationRef;
    OSStatus                err;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:sourcePath] == NO) {
        NSString* msgFormat = [[NSString alloc] initWithFormat: @"\"%@\" could not be installed because it is missing from the application bundle.", [destPath lastPathComponent]];
        NSRunAlertPanel (@"Missing Source File", msgFormat, @"Okay", nil, nil);
        return NO;
    }
    
    myItems[0].name = kAuthorizationRightExecute;
    myItems[0].valueLength = 0;
    myItems[0].value = NULL;
    myItems[0].flags = 0;
    
    myRights.count = sizeof(myItems) / sizeof(myItems[0]);
    myRights.items = myItems;
    
    //권한 획득
    err = AuthorizationCreate (&myRights, kAuthorizationEmptyEnvironment, kAuthorizationFlagInteractionAllowed | kAuthorizationFlagExtendRights, &authorizationRef);
    
    if (err == errAuthorizationSuccess) {
        char *  cpArgs[4];
        char *  shArgs[3];
        char *  kextloadArgs[2];
        int     status;
        
        cpArgs[0] = "-r";
        cpArgs[1] = (char *)[sourcePath cStringUsingEncoding:NSUTF8StringEncoding];
        cpArgs[2] = (char *)[destPath cStringUsingEncoding:NSUTF8StringEncoding];
        cpArgs[3] = NULL;
        
        err = AuthorizationExecuteWithPrivileges(authorizationRef, "/bin/cp", 0, cpArgs, NULL);
        if (err) return NO;
        
        shArgs[0] = (char *)[permRepairPath cStringUsingEncoding:NSUTF8StringEncoding];
        shArgs[1] = (char *)[destPath cStringUsingEncoding:NSUTF8StringEncoding];
        shArgs[2] = NULL;
        
        err = AuthorizationExecuteWithPrivileges(authorizationRef, "/bin/sh", 0, shArgs, NULL);
        if (err) return NO;
        
        kextloadArgs[0] = (char *)[destPath cStringUsingEncoding:NSUTF8StringEncoding];
        kextloadArgs[1] = NULL;
        
        err = AuthorizationExecuteWithPrivileges(authorizationRef, "/sbin/kextload", 0, kextloadArgs, NULL);
        if (err) return NO;
        
        while (wait(&status) != -1) {
            // wait for forked process to terminate
        }
        
        //권한 획득 종료
        AuthorizationFree(authorizationRef, kAuthorizationFlagDestroyRights);
        return YES;
    } else {
        return NO;
    }
}

- (BOOL) performDragOperation:(id<NSDraggingInfo>)sender
{
    BOOL bResult = YES;
    NSPasteboard* pPboard = [sender draggingPasteboard];
    
    if ([[pPboard types] containsObject: NSURLPboardType])
    {
        NSURL* pFileURL = [NSURL URLFromPasteboard: pPboard];
        NSLog(@"file Path : %@\n", [pFileURL path]);
        NSLog(@"file Name : %@\n", [[pFileURL absoluteString] lastPathComponent]);
        
        //Load Kexts
        NSString* destPath = [[NSString alloc] initWithFormat: @"/tmp/%@", [[pFileURL absoluteString] lastPathComponent]];
        bResult = [self installKLogKext: [pFileURL path]
                        DestinationPath: destPath];
    }
    
EXIT:
    return bResult;
}
@end
