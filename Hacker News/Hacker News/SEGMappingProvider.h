//
//  SEGMappingProvider.h
//  Hacker News
//
//  Created by Samuel E. Giddins on 2/9/13.
//  Copyright (c) 2013 Samuel E. Giddins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface SEGMappingProvider : NSObject

+ (RKMapping *)newsItemMapping;

@end
