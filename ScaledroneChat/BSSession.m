//
//  BehavioSession.m
//  MinimalTextfieldExample
//
//  Created by BehavioSec on 21.06.15.
//  Copyright (c) 2015 BehavioSec. All rights reserved.
//

#import "BSSession.h"
#import "BehavioSecIOSSDK.h"



@interface  BehavioSession() {

}
@end

@implementation BehavioSession

NSMutableString *sessionResults;


+ (id) behavioSessionForUser:(NSString *)userName {
    BehavioSession* behavioSession = [[self alloc] initWithUser:userName];
    return behavioSession;
}


-(id) initWithUser:(NSString* )userName {
    self = [super init];
    _userName = userName;
    _sessionId = [NSString stringWithFormat:@"%@.MinimalTextfieldExample",[[NSUUID UUID] UUIDString]];
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    _userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    sessionResults = [[NSMutableString alloc]init];
    [self setPreferences];
    return self;
}

- (void)readPrefsFromFile{
    NSString *pathStr = [[NSBundle mainBundle] bundlePath];
    NSString *settingsBundlePath = [pathStr   stringByAppendingPathComponent:@"Settings.bundle"];
    NSString *finalPath = [settingsBundlePath stringByAppendingPathComponent:@"Root.plist"];
    NSDictionary *settingsDict = [NSDictionary   dictionaryWithContentsOfFile:finalPath];
    NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
    NSDictionary *prefItem;
    NSString *keyValueStr;
    id defaultValue;
    NSMutableDictionary *appDefaults = [[NSMutableDictionary alloc]init ];
    
    for (prefItem in prefSpecifierArray){
        keyValueStr = [prefItem objectForKey:@"Key"];
        defaultValue = [prefItem objectForKey:@"DefaultValue"];
        if (nil != keyValueStr) {
            [appDefaults setObject:defaultValue forKey:keyValueStr];
        }
    }
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setPreferences{
    [self readPrefsFromFile];
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSString* baseUrl = [defs stringForKey:@"baseUrl"];
    _getReportUrl = [NSString stringWithFormat:@"%@/%@", baseUrl, [defs stringForKey:@"getReportUrl"]];
    _tenantId = [defs stringForKey:@"tenantId"];
}

-(NSDictionary*)doSynchronousPostRequest:(NSString* )url withData:(NSString* )data shouldAppendToResult:(BOOL)shouldAppend {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSData *postData = [data dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];

#ifdef DEBUG
    NSLog(@"\n\n\nURL:\n==========\n%@\n\n\n",url);//DEBUGGING-INFORMATION
#endif
    
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:_userAgent forHTTPHeaderField:@"User-Agent"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    [request setHTTPBody:postData];
    
    NSHTTPURLResponse* urlResponse = nil;
    //NSError *error = [[NSError alloc] init];
    NSError *error =  [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];
    NSData *respData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    if (shouldAppend) {
        NSString *result = [[NSString alloc] initWithData:respData encoding:NSUTF8StringEncoding];
        [sessionResults appendString:result];
    }
    error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:respData options:kNilOptions error:&error];
    return jsonDict;
}

-(NSDictionary *)getScoreForTimings:(NSString*) timings andNotes:(NSString*) notes andReportFlag: (NSString*) reportFlag andOperatorFlag: (NSString*) operatorFlag {
    NSString* post = [NSString stringWithFormat:@"userid=%@&timing=%@&userAgent=%@&ip=1.1.1.1&sessionId=%@&notes=%@&reportFlags=%@&operatorFlags=%@&tenantId=%@",_userName,timings,_userAgent,_sessionId,notes,reportFlag,operatorFlag, _tenantId];
    
    NSDictionary* jsonDict = [self doSynchronousPostRequest:_getReportUrl withData:post shouldAppendToResult:YES];
    return jsonDict;
}

-(NSString*) getScoreAsHTML:(NSDictionary*)result
{
//#ifdef DEBUG
//    NSLog(@"\n\n\nResult:\n==========\n%@\n\n\n",result);//DEBUGGING-INFORMATION
//#endif
    NSString *cssPath = [[NSString alloc] initWithString:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"style.css"]];
    
    NSMutableString *embedHTML = [NSMutableString stringWithContentsOfFile:cssPath encoding:NSUTF8StringEncoding error:nil];
    [embedHTML insertString:@"<style>" atIndex:0]; // add style tag since it is inline
    [embedHTML appendString:@"</style>"]; // close style tag
    
    float conf = [[result objectForKey:@"confidence"] floatValue];
    float score = [[result objectForKey:@"score"] floatValue];
#ifdef DEBUG
    NSLog(@"score:%f\n",score);//DEBUGGING-INFORMATION
    NSLog(@"conf:%f\n",conf);//DEBUGGING-INFORMATION
#endif

    [embedHTML appendFormat:@"<div class=\"results\"><span class=\"pad\"><h4>Transaction results</h4>"];
    [embedHTML appendFormat:@"<div id=\"sessionscore\" class=\"score policy%@\"><div class=\"ptext\">%@</div><h5>%@</h5><p>%@</p></div>",[result objectForKey:@"policyId"],[[result objectForKey:@"policy"] lowercaseString], @"Score", [NSString stringWithFormat:@"%.2f", score * 100]];
    [embedHTML appendFormat:@"<div id=\"sessionconfidence\" class=\"confidence\"><h5>%@</h5><p>%@</p></div>",@"Confidence", [NSString stringWithFormat:@"%.2f", conf * 100]];
    
    [embedHTML appendFormat:@"<div id=\"username\" class=\"uid\"><h5>%@</h5><p>%@</p></div>",@"User ID", _userName];
    [embedHTML appendFormat:@"<div id=\"sessionid\" class=\"sid\"><h5>%@</h5><p>%@</p></div>",@"Session ID", [self sessionId]];
//#ifdef DEBUG
//    NSLog(@"\nembedHTML:\n%@\n",embedHTML);//DEBUGGING-INFORMATION
//#endif
    return embedHTML;
}



@end
