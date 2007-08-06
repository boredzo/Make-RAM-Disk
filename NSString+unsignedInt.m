/*NSString+unsignedInt.m
 *
 *Created by Peter Hosey on 2005-03-28.
 *Copyright 2005-2006 Peter Hosey. All rights reserved.
 */

#import "NSString+unsignedInt.h"

#include <ctype.h>

@implementation NSString(unsignedInt)

+ stringWithUnsignedInt:(unsigned)i {
	return [[NSNumber numberWithUnsignedInt:i] stringValue];
}

- (unsigned)unsignedIntValue {
	const char *UTF8 = [self UTF8String];
	//Skip leading whitespace.
	while (isspace(*UTF8)) ++UTF8;
	//Ignore +.
	if (*UTF8 == '+') ++UTF8;
	//More optional whitespace.
	while (isspace(*UTF8)) ++UTF8;

	unsigned value = 0U;
	while (isdigit(*UTF8)) {
		value *= 10U;
		value += *UTF8 - '0';
		++UTF8;
	}

	return value;
}

@end
