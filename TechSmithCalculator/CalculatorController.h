//
//  CalculatorController.h
//  TechSmithCalculator
//
//  Created by Michael Dautermann on 7/12/13.
//  Copyright (c) 2013 Michael Dautermann. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CalculatorController : NSWindowController <NSTextFieldDelegate>

// if "NO", then we clear out the currently visible number
@property (readwrite) BOOL newValueBeingTyped;

@end
