// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
  EX Yoyaku Browser for iPhone/iPod touch

  Copyright (c) 2009, Takuya Murakami, All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer. 

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution. 

  3. Neither the name of the project nor the names of its contributors
  may be used to endorse or promote products derived from this software
  without specific prior written permission. 

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "Pin.h"
#import "AppDelegate.h"

@implementation PinController
@synthesize pin, newPin;

#define FIRST_PIN_CHECK 0
#define ENTER_CURRENT_PIN 1
#define ENTER_NEW_PIN1 2
#define ENTER_NEW_PIN2 3

- (id)init
{
    self = [super init];
    if (self) {
        state = -1;
        self.newPin = nil;
        navigationController = nil;

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.pin = [defaults stringForKey:@"PinCode"];

        if (pin && pin.length == 0) {
            self.pin = nil;
        }
    }
    return self;
}

- (void)dealloc
{
    [pin release];
    [newPin release];
    [navigationController release];
    [super dealloc];
}
    
- (void)_allDone
{
    [navigationController dismissModalViewControllerAnimated:YES];
    [self autorelease];
}

- (void)firstPinCheck:(UIViewController *)currentVc
{
    //ASSERT(state == -1);

    if (pin == nil) return; // do nothing

    [self retain];

    PinViewController *vc = [self _getPinViewController];

    vc.title = @"パスコード確認";
    vc.enableCancel = NO;

    state = FIRST_PIN_CHECK;

    navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    [currentVc presentModalViewController:navigationController animated:NO];
}

- (void)modifyPin:(UIViewController *)currentVc
{
    //ASSERT(state == -1);

    [self retain];

    PinViewController *vc = [self _getPinViewController];
    
    if (pin != nil) {
        // check current pin
        state = ENTER_CURRENT_PIN;
        vc.title = @"パスコード確認";
    } else {
        // enter 1st pin
        state = ENTER_NEW_PIN1;
        vc.title = @"新規パスコード入力";
    }
        
    navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    [currentVc presentModalViewController:navigationController animated:YES];
}

- (void)pinViewFinished:(PinViewController *)vc isCancel:(BOOL)isCancel
{
    if (isCancel) {
        [self _allDone];
        return;
    }

    BOOL retry = NO;
    BOOL isBadPin = NO;
    PinViewController *newvc = nil;

    switch (state) {
    case FIRST_PIN_CHECK:
    case ENTER_CURRENT_PIN:
        //ASSERT(pin != nil);
        if (![vc.value isEqualToString:pin]) {
            isBadPin = YES;
            retry = YES;
        }
        else if (state == ENTER_CURRENT_PIN) {
            state = ENTER_NEW_PIN1;
            newvc = [self _getPinViewController];        
            newvc.title = @"新規パスコード入力";
        }
        break;

    case ENTER_NEW_PIN1:
        self.newPin = [NSString stringWithString:vc.value]; // TBD
        state = ENTER_NEW_PIN2;
        newvc = [self _getPinViewController];        
        newvc.title = @"パスコード確認";
        break;

    case ENTER_NEW_PIN2:
        NSLog(@"%@", newPin);
        if ([vc.value isEqualToString:newPin]) {
            // set new pin
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:newPin forKey:@"PinCode"];
            [defaults synchronize];
        } else {
            isBadPin = YES;
        }
        break;
    }

    // invalid pin
    if (isBadPin) {
        UIAlertView *v = [[UIAlertView alloc]
                             initWithTitle:@"パスコード不正"
                             message:@"パスコードが違います."
                             delegate:nil
                             cancelButtonTitle:@"Close"
                             otherButtonTitles:nil];
        [v show];
        [v release];
    }
    if (retry) {
        return;
    }

    // Show new vc if needed, otherwise all done.
    if (newvc) {
        [navigationController pushViewController:newvc animated:YES];
    } else {
        [self _allDone];
    }
}

- (PinViewController *)_getPinViewController
{
    PinViewController *vc = [[[PinViewController alloc] init] autorelease];
    vc.enableCancel = YES;
    vc.delegate = self;
    return vc;
}

@end
