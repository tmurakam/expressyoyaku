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

#import "ConfigViewController.h"
#import "ContainerCell.h"
#import "Config.h";
#import "Pin.h"

@implementation ConfigViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
        Config *config = [Config instance];
        
        userIdField = [[self _textInputField:config.userId placeHolder:@"ID" secure:NO] retain];
        passwordField = [[self _textInputField:config.password placeHolder:@"パスワード" secure:YES] retain];
        
        userTypeField = [[UILabel alloc] initWithFrame:CGRectMake(115, 11, 160, 24)];
        [self _updateUserType];
    }
    return self;
}

- (UITextField *)_textInputField:(NSString *)value placeHolder:(NSString *)placeHolder secure:(BOOL)secure
{
    UITextField *f;
    f = [[[UITextField alloc] initWithFrame:CGRectMake(115, 12, 160, 24)] autorelease];
    f.text = value;
    f.placeholder = placeHolder;
    f.secureTextEntry = secure;
    f.keyboardType = UIKeyboardTypeNumbersAndPunctuation;// UIKeyboardTypeASCIICapable;
    f.returnKeyType = UIReturnKeyDone;
    f.autocorrectionType = UITextAutocorrectionTypeNo;
    f.autocapitalizationType = UITextAutocapitalizationTypeNone;
    f.delegate = self;
    return f;
}

- (BOOL)textFieldShouldReturn:(UITextField *)f
{
    [f resignFirstResponder];
    return YES;
}

- (void)_updateUserType
{
    switch ([Config instance].userType) {
        case 1:
            userTypeField.text = @"エクスプレスカード";
            break;
        case 2:
            userTypeField.text = @"J-WESTカード";
            break;
    }
}

- (void)dealloc {
    [userTypeField release];
    [userIdField release];
    [passwordField release];
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"設定";
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                  target:self
                                               action:@selector(doneAction:)] autorelease];


}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)doneAction:(id)sender
{
    Config *config = [Config instance];
    config.userId = userIdField.text;
    config.password = passwordField.text;
    [config save];
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
    case 0:
        return @"設定";
    case 1:
        return @"情報";
    }
    return nil;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
    case 0:
        return 4;

    case 1:
        return 2;
    }
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContainerCell *cc;
    NSString *version;
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cc = [ContainerCell containerCell:@"カード種別" tableView:tableView];
                    cc.attachedView = userTypeField;
                    break;
                case 1:
                    cc = [ContainerCell containerCell:@"ユーザID" tableView:tableView];
                    cc.attachedView = userIdField;
                    break;
                case 2:
                    cc = [ContainerCell containerCell:@"パスワード" tableView:tableView];
                    cc.attachedView = passwordField;
                    break;
                case 3:
                    cc = [ContainerCell containerCell:@"PIN" tableView:tableView];
                    cc.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
            }
            break;

        case 1:
            switch (indexPath.row) {
                case 0:
                    version = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
                    cc = [ContainerCell containerCell:[NSString stringWithFormat:@"EX予約ブラウザ Version %@", version] tableView:tableView];
                    break;
                case 1:
                    cc = [ContainerCell containerCell:@"ヘルプ" tableView:tableView];
                    cc.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
            }
    }

    return cc;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        // 会員種別
        UIActionSheet *v;
        v = [[UIActionSheet alloc]
             initWithTitle:@"カード種別"
             delegate:self
             cancelButtonTitle:nil
             destructiveButtonTitle:nil
             otherButtonTitles:@"エクスプレス/VIEWカード", @"J-WESTカード", nil];
        v.actionSheetStyle = UIActionSheetStyleDefault;
        [v showInView:self.view];
        [v release];
    }
    else if (indexPath.section == 0 && indexPath.row == 3) {
        // PIN
        PinController *pinController = [[[PinController alloc] init] autorelease];
        [pinController modifyPin:self];
    }
    else if (indexPath.section == 1 && indexPath.row == 1) {
        // ヘルプ
        NSURL *url = [NSURL URLWithString:@"http://iphone.tmurakam.org/expressYoyaku/index-j.html"];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)actionSheet:(UIActionSheet *)as clickedButtonAtIndex:(NSInteger)index
{
    Config *config = [Config instance];
    config.userType = index + 1;
    [self _updateUserType];    
}

@end

