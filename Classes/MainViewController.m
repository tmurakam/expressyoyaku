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
//  MainViewController.m

#import "MainViewController.h"
#import "ConfigViewController.h"
#import "Config.h"

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

#if 0
    barButtonBack.enabled = NO;
    barButtonForward.enabled = NO;
#endif
    
    //[activityIndicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    NSURL *url = [NSURL URLWithString:@"http://expy.jp/member/login/index.html"];
    NSURLRequest *req = [[[NSURLRequest alloc] initWithURL:url] autorelease];
    [webView loadRequest:req];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fixPage:nil];
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
                           cancelButtonTitle:NSLocalizedString(@"閉じる", @"") 
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

#if 0
    // viewport 追加
    [self runScript:
        @"e = document.getElementById(\"head\");"
        @"vp = document.createElement(\"meta\");"
        @"vp.setAttribute(\"name\", \"viewport\");"
        @"vp.setAttribute(\"content\", \"initial-scale=2.0\");"
        @"e.appendChild(e);"
     ];
#endif
    
    // オートログイン
    NSRange range = [urlString rangeOfString:@"/expy.jp/member/login/"];
    if (range.location != NSNotFound) {
        [self runScript:
                  [NSString stringWithFormat:@"document.getElementById(\"user_id%d\").value=\"%@\"",
                            type, userid]];
        [self runScript:
                  [NSString stringWithFormat:@"document.getElementById(\"password%d\").value=\"%@\"",
                            type, pass]];
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
    //NSLog(@"%@ -> %@", script, result);
}

- (IBAction)doConfig:(id)sender
{
    ConfigViewController *cv = [[ConfigViewController alloc] initWithNibName:@"ConfigView" bundle:nil];
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:cv];
    [cv release];
    
    [self presentModalViewController:nv animated:YES];
    [nv release];
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
