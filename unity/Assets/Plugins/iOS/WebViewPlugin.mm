// Web view integration plug-in for Unity iOS.

#import <Foundation/Foundation.h>

extern UIViewController *UnityGetGLViewController(); // Root view controller of Unity screen.

#pragma mark Plug-in Functions

static UIWebView *webView;

extern "C" void _WebViewPluginInstall() {
    // Add the web view onto the root view (but don't show).
    UIViewController *rootViewController = UnityGetGLViewController();
    webView = [[UIWebView alloc] initWithFrame:rootViewController.view.frame];
    webView.hidden = YES;
    [rootViewController.view addSubview:webView];
}

extern "C" void _WebViewPluginLoadUrl(const char* url) {
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithUTF8String:url]]]];
}

extern "C" void _WebViewPluginSetVisibility(bool visibility) {
    webView.hidden = visibility ? NO : YES;
}

extern "C" void _WebViewPluginSetMargins(int left, int top, int right, int bottom) {
    UIViewController *rootViewController = UnityGetGLViewController();
    
    CGRect frame = rootViewController.view.frame;
    CGFloat scale = rootViewController.view.contentScaleFactor;
    
    frame.size.width -= (left + right) / scale;
    frame.size.height -= (top + bottom) / scale;
    
    frame.origin.x += left / scale;
    frame.origin.y += top / scale;
    
    webView.frame = frame;
}

extern "C" char *_WebViewPluginPollMessage() {
    // Try to retrieve a message from the message queue in JavaScript context.
    NSString *message = [webView stringByEvaluatingJavaScriptFromString:@"unityWebMediatorInstance.pollMessage()"];
    if (message && message.length > 0) {
        NSLog(@"UnityWebViewPlugin: %@", message);
        char* memory = static_cast<char*>(malloc(strlen(message.UTF8String) + 1));
        if (memory) strcpy(memory, message.UTF8String);
        return memory;
    } else {
        return NULL;
    }
}

extern "C" void _WebViewPluginEvalJS(const char* js) {
    NSString *jsStr = [NSString stringWithUTF8String:js];
    [webView stringByEvaluatingJavaScriptFromString:jsStr];
}
