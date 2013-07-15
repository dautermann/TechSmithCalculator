//
//  CalculatorTextField.m
//  TechSmithCalculator
//
//  Created by Michael Dautermann on 7/12/13.
//  Copyright (c) 2013 Michael Dautermann. All rights reserved.
//

#import "CalculatorTextField.h"
#import "CalculatorController.h"

@implementation CalculatorTextField

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

// normally Apple discourages getting key down events for text fields and would rather
// developers use NSTextDelegate (actually NSControlDelegate) methods like
// controlTextDidChange: 
//
// http://stackoverflow.com/questions/8868489/get-keydown-event-for-an-nstextfield
//
- (void)keyUp:(NSEvent *)theEvent
{
    CalculatorController * cController = (CalculatorController *)[[self window] windowController];
    if(cController)
    {
        [cController keyUp: theEvent];
    }
}

@end
