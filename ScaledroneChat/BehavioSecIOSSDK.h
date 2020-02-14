


// BehavioSecIOSSDK
// Version: 2.0.2
// Copyright (c) 2015 BehavioSec. All rights reserved.



#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static const int INPUT_BUTTON = 1;
static const int DELETE_BUTTON = 2;
static const int CLEAR_BUTTON = 3;

static const int NORMAL_TARGET = 1;
static const int ANONYMOUS_TARGET = 2;
static const int MASKED_TARGET = 3;



@interface BehavioSecIOSSDK : NSObject

/*!
 * @brief callback for webviews
 */
@property void (^onLastDown)(NSTimeInterval);

+(instancetype)sharedIOSSDK;

/*!
 * @discussion Register a button to be watched/sampled.
 */
-(void) registerButton:(UIButton*)inUIButton withButtonType:(int) inType andKey:(int)inKey;

/*!
 * @discussion Register a Target for button input.
 * @param inName The name of the target.
 * @param inAnonymous Specifies if the target should be anonymous. For anonymous targets no key codes are written to the collected data.
 */
-(void) registerBtnTargetWithID:(NSObject*) inID andName:(NSString*)inName isAnonymous:(BOOL)inAnonymous;

/*!
 * @discussion Register a Target for button input.
 * @param inName The name of the target.
 * @param inTargetType Specifies the type of the target: normal, anonymous or masked. For masked and anonymous targets no key codes are written to the collected data.
 */
-(void) registerBtnTargetWithID:(NSObject*) inID andName:(NSString*)inName andTargetType:(int)inTargetType;

/*!
 * @discussion Register an UITextField as target for keyboard input.
 * @param inName The name of the target.
 * @param inAnonymous Specifies if the target should be anonymous. For anonymous targets no key codes are written to the collected data.
 */
-(void) registerKbdTargetWithID:(UITextField*) inID andName:(NSString*)inName isAnonymous:(BOOL)inAnonymous;

/*!
 * @discussion Register an UITextField as target for keyboard input.
 * @param inName The name of the target.
 * @param inTargetType Specifies the type of the target: normal, anonymous or masked. For masked and anonymous targets no key codes are written to the collected data.
 */
-(void) registerKbdTargetWithID:(UITextField*) inID andName:(NSString*)inName andTargetType:(int)inTargetType;

/*!
 * @discussion Register an UITextField as target for keyboard input.
 * @param inName The name of the target.
 * @param inAnonymous Specifies if the target should be anonymous. For anonymous targets no key codes are written to the collected data.
 * @param inClearWholeTarget Specifies if the whole target and its so far collected timing data will be cleared instead of deleting one single character by pressing the delete button.
 */
-(void) registerKbdTargetWithID:(UITextField *) inID andName:(NSString*)inName isAnonymous:(BOOL)inAnonymous andClearWholeTarget:(BOOL)inClearWholeTarget;

/*!
 * @discussion Register an UITextField as target for keyboard input.
 * @param inName The name of the target.
 * @param inTargetType Specifies the type of the target: normal, anonymous or masked. For masked and anonymous targets no key codes are written to the collected data.
 * @param inClearWholeTarget Specifies if the whole target and its so far collected timing data will be cleared instead of deleting one single character by pressing the delete button.
 */
-(void) registerKbdTargetWithID:(UITextField *) inID andName:(NSString*)inName andTargetType:(int)inTargetType andClearWholeTarget:(BOOL)inClearWholeTarget;

/*!
 * @discussion set current target
 */
-(void) setCurrentTargetID:(NSObject*) inTargetID;

/*!
 * @discussion Get the version of the SDK.
 * @return The version string of the SDK.
 */
-(NSString*) getVersion;

/*!
 * @discussion Clear all timingdata only.
 */
-(void) clearTimingData;

/*!
 * @discussion Clear all timingdata, information, registrations and stop motion detection.
 */
-(void) clearRegistrations;

/*!
 * @discussion Start motion detection for gyro and acceleration.
 */
-(void) startMotionDetect;

/*!
 * @discussion Stop motion detection, is called on getSummary.
 */
-(void) stopMotionDetect;

-(void) addInformation:(NSString *)inInfoString withName:(NSString *)inInfoName;

/*!
 * @discussion Get the collected Data and stop motion detection without clearing timing data since 1.4.905. Call clearTimingData manually to clear the timing data.
 * @return The collected timing data as string.
 */
-(NSString*) getSummary;

/*!
 * @discussion Get the collected Data and stop motion detection without clearing timing data. Call clearTimingData manually to clear the timing data. If inCompressed is true, timing data will be compressed to be used together with the FLAG_COMPRESSED_DATA operator flag.
 * @return The collected timing data as string.
 */
-(NSString*) getSummary:(BOOL)inCompressed;

/*!
 * @discussion Experimental, for test purpose only. Must be called immediately after first call of sharedIOSSDK.
 */
-(void) setShouldSendRawData:(BOOL) inShouldSendRawData;

//TouchSDK
-(void)enableTouchSDKWithViewController:(nonnull UIViewController*)inViewController;

// experimental! methods to handle input from non UITextfields (NTF)
// added 19.03.2016 by JB
-(void)registerKeybdTargetNTF:(NSObject *)target withName:(NSString *)name isAnonymous:(BOOL)anonymous;
-(void)registerKeybdTargetNTF:(NSObject *)target withName:(NSString *)name andTargetType:(int)inTargetType;
-(void)keybdTargetTextChangedNTF:(NSObject *)target to:(NSString*)newText;
-(void)setCurrentKeybdTargetNTF:(NSObject *)target with:(NSString *)text;
-(void)setCurrentKeybdTargetNTF:(NSObject *)target with:(NSString *)text inputAccessoryView:(UIView *)inputAccessoryView;

//depreciated methods in 1.5
///clear all timingdata and all registrations, information, stop motion detection
-(void) clear __attribute__((deprecated("this method is deprecated in BehavioSecIOSSDK version 1.5., use clearTimings and clearRegistrations instead")));
///clear all data, all registrations and text in registered Texfields, information, stop motion detection
-(void) clearAlsoTargets __attribute__((deprecated("this method is deprecated in BehavioSecIOSSDK version 1.5., clearing the taregts should be handled in your app")));
///register a Target for button input
-(void) registerBtnTargetWithID:(NSObject*) inID andName:(NSString*)inName andMaxTextLength:(int) inMaxTextLength isAnonymous:(BOOL)inAnonymous __attribute__((deprecated("the parameter MaxTextLength is deprecated in BehavioSecIOSSDK version 1.5., the maximal text lengths should be handled in your app")));
@end
