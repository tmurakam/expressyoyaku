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
//  MainViewController.m

#import "MainViewController.h"
#import "ConfigViewController.h"
#import "Config.h"
#import "Pin.h"

#define LOGIN_URL       @"http://expy.jp/member/login/index.html"

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    //[activityIndicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [self loadUrl:LOGIN_URL];
}

- (void)loadUrl:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *req = [[[NSURLRequest alloc] initWithURL:url] autorelease];
    [webView loadRequest:req];
}

- (void)viewWillAppear:(BOOL)animated
{
    //NSLog(@"2:%@", self.modalViewController);
    [super viewWillAppear:animated];
    [self fixPage:nil];
    //NSLog(@"3:%@", self.modalViewController);
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    //return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    return YES;
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

- (void)dealloc {
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////
// UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //[activityIndicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)wv
{
    //[activityIndicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

#if 0
    barButtonBack.enabled = [webView canGoBack];
    barButtonForward.enabled = [webView canGoForward];
#endif

    [self fixPage:nil];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError*)err
{
    NSLog(@"%d %@ %@", [err code], [err domain], [err localizedDescription]);
    //[activityIndicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    if ([[err domain] isEqualToString:@"NSURLErrorDomain"] &&
        [err code] != NSURLErrorCancelled) {
        UIAlertView *av = [[UIAlertView alloc]
                           initWithTitle:@"エラー"
                           message:[err localizedDescription]
                           delegate:nil 
                           cancelButtonTitle:@"閉じる"
                           otherButtonTitles:nil];
        [av show];
        [av release];
    }
}

- (void)fixPage:(id)sender;
{
    NSURL *url = webView.request.URL;
    NSString *urlString = [url absoluteString];
    NSLog(@"url: %@", urlString);

    Config *config = [Config instance];
    NSString *userid = config.userId;
    NSString *pass = config.password;
    int type = config.userType;

    // viewport 追加
#if 0
    NSString *vpscript =
        @"var head = document.getElementById('body');"
        @"alert(head);"
        @"var vp = document.createElement('meta');"
        @"vp.setAttribute('name', 'viewport');"
        @"vp.setAttribute('content', 'width=320;');"
        @"document.getElementById('head').appendChild(vp);";
    
    NSLog(vpscript);
    [self runScript:vpscript];
#endif
    
#if 0
    [self runScript:
        @"var vp = document.createElement(\"meta\");"
        @"vp.setAttribute(\"name\", \"viewport\");"
        @"vp.setAttribute(\"content\", \"width=320;\");"
        @"var head = window.document.getElementById(\"head\");"
                                          @"alert(head);"
        @"if (head == null) {"
        @"  head = document.createElement(\"head\");"
        @"  document.appendChild(head);"
        @"  alert(head);"
        @"}"
        @"alert('fuga');"
        @"head.appendChild(vp);"
     ];
#endif
    
#if 0
    [self runScript:
        @"var f1 = window.frames[0];"
        @"if (f1) { var f2 = f1.frames[0];"
        @"if (f2) {"
        @"var vp = document.createElement(\"meta\");"
        @"vp.setAttribute(\"name\", \"viewport\");"
        @"vp.setAttribute(\"content\", \"width=320;\");"
     @"alert(vp);"
        @"var hh = f2.document.getElementById(\"head\");"
        @"alert(hh);"
        @"f2.document.getElementById(\"head\").appendChild(vp);"
        @"}}"
     ];
#endif
    
    // オートログイン
    NSRange range = [urlString rangeOfString:@"/expy.jp/member/login/"];
    if (range.location != NSNotFound) {
        if (userid != nil) {
            [self runScript:
                    [NSString stringWithFormat:@"document.getElementById(\"user_id%d\").value=\"%@\"",
                                type, userid]];
        }
        if (pass != nil) {
            [self runScript:
                    [NSString stringWithFormat:@"document.getElementById(\"password%d\").value=\"%@\"",
                                type, pass]];
        }
    }
    
    // ページ修正
    range = [urlString rangeOfString:@"https://shinkansen1.jr-central.co.jp/RSV_P"];
    if (range.location == 0) {
        NSMutableString *ms = [[[NSMutableString alloc] init] autorelease];
        [ms setString:
            @"var f1 = window.frames[0];"
            @"if (f1) { f1.onresize = undefined; var f2 = f1.frames[0];"
            @"  if (f2) { f2.onresize = undefined;"
         ];
        NSString *fmt = @"e = f2.document.getElementById(\"%@\"); if (e) e.setAttribute(\"style\", \"%@\");";
        [ms appendFormat:fmt, @"top",    @"position:absolute; width:auto; float:left;"];
        [ms appendFormat:fmt, @"bottom", @"position:absolute; top:50; bottom:auto; width:auto; float:left;"];
        [ms appendFormat:fmt, @"side",   @"position:absolute; top:85; left:0; height:auto; float:left;"];
        [ms appendFormat:fmt, @"guide",  @"top:85; width:auto; float:right;"];
        [ms appendFormat:fmt, @"content",@"width:auto; height:auto; float:right;"];
        [ms appendString:@"}}"];
        
        [self runScript:ms];
    }
}

- (void)runScript:(NSString *)script
{
    NSString *result = [webView stringByEvaluatingJavaScriptFromString:script];
    NSLog(@"%@ -> %@", script, result);
}

- (IBAction)doConfig:(id)sender
{
    ConfigViewController *cv = [[ConfigViewController alloc] initWithNibName:@"ConfigView" bundle:nil];
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:cv];
    [cv release];
    
    [self presentModalViewController:nv animated:YES];
    [nv release];
}

- (IBAction)doActionSheet:(id)sender
{
    UIActionSheet *v;
    v = [[UIActionSheet alloc]
            initWithTitle:@""
            delegate:self
            cancelButtonTitle:@"キャンセル"
            destructiveButtonTitle:nil
            otherButtonTitles:@"再ログイン", nil];
    v.actionSheetStyle = UIActionSheetStyleDefault;
    [v showInView:self.view];
    [v release];
}

#pragma mark ActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)as clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
    case 0:
        [self loadUrl:LOGIN_URL];
        break;
    }
}


#if 0
- (IBAction)goForward:(id)sender
{
    [webView goForward];
}

- (IBAction)goBackward:(id)sender
{
    [webView goBack];
}

- (IBAction)reloadPage:(id)sender
{
    [webView reload];
}
#endif

@end
