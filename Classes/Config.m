// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
  ExpressYoyaku for iPhone/iPod touch

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
// Config.m

#import "Config.h"

@implementation Config

@synthesize userType, userId, password;

+ (Config *)instance
{
    static Config *config = nil;

    if (config == nil) {
        config = [[Config alloc] init];
    }
    return config;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        userType = [defaults integerForKey:@"UserType"];
        if (userType == 0) {
            userType = 1;
        }

        self.userId = [defaults objectForKey:@"UserId"];
        self.password = [defaults objectForKey:@"Password"];
    }
    return self;
}

- (void)save
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    [defaults setInteger:userType forKey:@"UserType"];
    [defaults setObject:userId forKey:@"UserId"];
    [defaults setObject:password forKey:@"Password"];
}

- (void)dealloc
{
    [userId release];
    [password release];
    [super dealloc];
}

@end

