//
//  ZKeyChain.m
//
//  Created by Kaz Yoshikawa on 10/31/11.
//  Copyright (c) 2011 Electricwoods LLC. All rights reserved.
//

#import "ZKeyChain.h"
#import "NSData+Z.h"

//
//	NSStringFromStatus
//
static NSString *NSStringFromStatus(OSStatus aStatus)
{
	switch (aStatus) {
	case errSecSuccess: return @"errSecSuccess";
	case errSecUnimplemented: return @"errSecUnimplemented";
	case errSecParam: return @"errSecParam";
	case errSecAllocate: return @"errSecAllocate";
	case errSecNotAvailable: return @"errSecNotAvailable";
	case errSecAuthFailed: return @"errSecAuthFailed";
	case errSecDuplicateItem: return @"errSecDuplicateItem";
	case errSecItemNotFound: return @"errSecItemNotFound";
	case errSecInteractionNotAllowed: return @"errSecInteractionNotAllowed";
	case errSecDecode: return @"errSecDecode";
	default: return [NSString stringWithFormat:@"(%d)", aStatus];
	}
}


//
//	ZKeyChain
//
@implementation ZKeyChain

@synthesize service;

+ (id)keyChainWithService:(NSString *)aService
{
	return [[[ZKeyChain alloc] initWithService:aService] autorelease];
}

- (id)initWithService:(NSString *)aService;
{
	if ((self = [super init])) {
		self.service = aService;
	}
	return self;
}

- (void)dealloc
{
	self.service = nil;
    [super dealloc];
}


- (void)setPasswordData:(NSData *)aPasswordData forAccount:(NSString *)aAccount;
{
	NSData *data = nil;
	NSMutableDictionary* query = [NSMutableDictionary dictionary];
	[query setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	[query setObject:(id)service forKey:(id)kSecAttrService];
	[query setObject:(id)aAccount forKey:(id)kSecAttrAccount];
	[query setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
	OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)&data);
	if (status == noErr) {
		if (aPasswordData) {
			NSMutableDictionary* attributes = [NSMutableDictionary dictionary];
			[attributes setObject:aPasswordData forKey:(id)kSecValueData];
			[attributes setObject:[NSDate date] forKey:(id)kSecAttrModificationDate];
			status = SecItemUpdate((CFDictionaryRef)query, (CFDictionaryRef)attributes);
			if (status != noErr) NSLog(@"SecItemUpdate: %@", NSStringFromStatus(status));
		}
		else {
			status = SecItemDelete((CFDictionaryRef)query);
			if (status != noErr) NSLog(@"SecItemDelete: %@", NSStringFromStatus(status));
		}
	}
	else if (status == errSecItemNotFound) {
		NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
		[attributes setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
		[attributes setObject:(id)service forKey:(id)kSecAttrService];
		[attributes setObject:(id)aAccount forKey:(id)kSecAttrAccount];
		if (aPasswordData) {
			[attributes setObject:aPasswordData forKey:(id)kSecValueData];
		}
		[attributes setObject:[NSDate date] forKey:(id)kSecAttrCreationDate];
		[attributes setObject:[NSDate date] forKey:(id)kSecAttrModificationDate];
		status = SecItemAdd((CFDictionaryRef)attributes, NULL);
		if (status != noErr) NSLog(@"SecItemAdd: %@", NSStringFromStatus(status));
	}
}

- (NSData *)passwordDataForAccount:(NSString *)aAccount;
{
	NSData *data = nil;
	NSMutableDictionary* query = [NSMutableDictionary dictionary];
	[query setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	[query setObject:(id)service forKey:(id)kSecAttrService];
	[query setObject:(id)aAccount forKey:(id)kSecAttrAccount];
	[query setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
	OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)&data);
	if (status == noErr) {
		return data;
	}
	else if (status == errSecItemNotFound) {
	}
	else {
		NSLog(@"SecItemCopyMatching: %@", NSStringFromStatus(status));
	}
	return nil;
}

- (void)setData:(id)aData forKey:(NSString *)aKey
{
	NSParameterAssert(aData == nil || [aData isKindOfClass:[NSData class]]);
	[self setPasswordData:aData forAccount:aKey];
}

- (id)dataForKey:(NSString *)aKey
{
	return [self passwordDataForAccount:aKey];
}

- (void)setString:(NSString *)aString forKey:(NSString *)aKey
{
	NSParameterAssert(aString == nil || [aString isKindOfClass:[NSString class]]);
	NSData *data = aString ? [aString dataUsingEncoding:NSUTF8StringEncoding] : nil;
	[self setPasswordData:data forAccount:aKey];
}

- (NSString *)stringForKey:(NSString *)aKey
{
	NSData *data = [self passwordDataForAccount:aKey];
	return data ? [[[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding] autorelease] : nil;
}

- (void)setDictionary:(NSDictionary *)aDictionary forKey:(NSString *)aKey
{
	NSParameterAssert(aDictionary == nil || [aDictionary isKindOfClass:[NSDictionary class]]);
	NSData *data = [NSData dataWithPropertyList:aDictionary];
	[self setPasswordData:data forAccount:aKey];
}

- (NSDictionary *)dictionaryForKey:(NSString *)aKey
{
	NSData *data = [self passwordDataForAccount:aKey];
	return data ? [data propertyList] : nil;
}

@end




