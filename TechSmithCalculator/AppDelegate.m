//
//  AppDelegate.m
//  TechSmithCalculator
//
//  Created by Michael Dautermann on 7/12/13.
//  Copyright (c) 2013 Michael Dautermann. All rights reserved.
//

#import "AppDelegate.h"
#import "CalculatorController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    arrayOfCalculators = [[NSMutableArray alloc] initWithCapacity: 1];

    [self newCalculator: self];
}

- (IBAction) newCalculator: (id) sender
{
    CalculatorController * cController = [[CalculatorController alloc] initWithWindowNibName: @"CalculatorWindow"];
    if(cController)
    {
        [cController showWindow: self];
        
        // I do this so the CalculatorController will stick around in memory;
        //
        // otherwise, it'll be released right away and the window will never appear
        [arrayOfCalculators addObject: cController];
    }
}

@end
