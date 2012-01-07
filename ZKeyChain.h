//
//  ZKeyChain.h
//
//  Created by Kaz Yoshikawa on 10/31/11.
//  Copyright (c) 2011 Electricwoods LLC. All rights reserved.
//
//	License:	MIT License



#import <Foundation/Foundation.h>
#import <Security/Security.h>

//
//	ZKeyChain
//
@interface ZKeyChain : NSObject
{
	NSString *service;
}
@property (copy) NSString *service;

+ (id)keyChainWithService:(NSString *)aService;
- (id)initWithService:(NSString *)aService;

- (void)setPasswordData:(NSData *)aPasswordData forAccount:(NSString *)aAccount;
- (NSData *)passwordDataForAccount:(NSString *)aAccount;
- (void)setData:(id)aData forKey:(NSString *)aKey;
- (id)dataForKey:(NSString *)aKey;
- (void)setString:(NSString *)aString forKey:(NSString *)aKey;
- (NSString *)stringForKey:(NSString *)aKey;
- (void)setDictionary:(NSDictionary *)aDictionary forKey:(NSString *)aKey;
- (NSDictionary *)dictionaryForKey:(NSString *)aKey;

@end
