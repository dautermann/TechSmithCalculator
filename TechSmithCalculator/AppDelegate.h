//
//  AppDelegate.h
//  TechSmithCalculator
//
//  Created by Michael Dautermann on 7/12/13.
//  Copyright (c) 2013 Michael Dautermann. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    NSMutableArray * arrayOfCalculators;
}

- (IBAction) newCalculator: (id) sender;

@end
