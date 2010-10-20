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
//  ConfigViewController.m

#import "ContainerCell.h"

@implementation ContainerCell

+ (ContainerCell *)containerCell:(NSString *)title tableView:(UITableView*)tableView
{
    NSString *identifier = @"ContainerCell";
    
    ContainerCell *cell = (ContainerCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[ContainerCell alloc] initWithFrame:CGRectZero reuseIdentifier:identifier] autorelease];
    }
    
#if 0
    UILabel *tlabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 6, 90, 32)] autorelease];
    tlabel.text = title;
    tlabel.font = [UIFont systemFontOfSize: 14.0];
    //tlabel.backgroundColor = [UIColor grayColor];
    tlabel.textColor = [UIColor blueColor];
    tlabel.textAlignment = UITextAlignmentLeft;
    tlabel.autoresizingMask = 0;//UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [cell.contentView addSubview:tlabel];
#endif
    cell.textLabel.text = title;
    return cell;
}

- (void)dealloc
{
    self.attachedView = nil;
    [super dealloc];
}

- (UIView *)attachedView
{
    return attachedView;
}

- (void)setAttachedView:(UIView *)view
{
    if (attachedView) {
        [attachedView removeFromSuperview];
        [attachedView release];
    }

    attachedView = view;
    if (attachedView) {
        [attachedView retain];
        [self addSubview:attachedView];
    }
}

@end
