//
//  BehavioSession.h
//  MinimalTextfieldExample
//
//  Created by BehavioSec on 21.06.15.
//  Copyright (c) 2015 BehavioSec. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define DEBUG

@interface BehavioSession : NSObject

@property (readonly, nonatomic) NSString* userName;
@property (readonly, nonatomic) NSString* sessionId;
@property (readonly, nonatomic) NSString* userAgent;
@property (readonly, nonatomic) NSString* getReportUrl;
@property (readonly, nonatomic) NSString* tenantId;


- (instancetype)initWithUser:(NSString*)userName;
+ (id)behavioSessionForUser:(NSString*)userName;
-(NSDictionary *)getScoreForTimings:(NSString*) timings andNotes:(NSString*) notes andReportFlag: (NSString*) reportFlag andOperatorFlag: (NSString*) operatorFlag;
-(NSString*) getScoreAsHTML:(NSDictionary*)result;

@end
