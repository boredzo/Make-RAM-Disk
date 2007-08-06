/*NSString+unsignedInt.h
 *
 *Created by Peter Hosey on 2005-03-28.
 *Copyright 2005-2006 Peter Hosey. All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface NSString(unsignedInt)

+ stringWithUnsignedInt:(unsigned)i;

- (unsigned)unsignedIntValue;

@end
