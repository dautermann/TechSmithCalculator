//
//  CalculatorController.m
//  TechSmithCalculator
//
//  Created by Michael Dautermann on 7/12/13.
//  Copyright (c) 2013 Michael Dautermann. All rights reserved.
//

#import "CalculatorController.h"

@interface CalculatorController ()
{
    IBOutlet NSTextField * textField;

    // doing this here saves on memory / cpu because we don't need
    // to recreate it every time a key is pressed
    NSCharacterSet * invertedDecimalCharacterSet;
    NSCharacterSet * arithmeticOperationCharacterSet;
    
    // whatever the operation is that we're doing, wait until the user
    // chooses another operation to actually do the action
    unichar lastOperation;
    
    // I may want to merge this with the above "lastOperation", but just in case there's
    // an operation I don't want to announce... I'll leave it separate for now
    IBOutlet NSTextField * lastOperationString;
    
    CGFloat savedValue;
}

- (IBAction) calculatorButtonPressed: (id) sender;

// I do this as a property to retain a copy of the previous string
@property (strong) NSString * previousTextFieldString;
@property (strong) NSString * reallyPreviousTextFieldString;

@end

@implementation CalculatorController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    NSCharacterSet * decimalCharacterSetPlusDecimal = [NSCharacterSet characterSetWithCharactersInString:@"1234567890."];
    
    invertedDecimalCharacterSet = [decimalCharacterSetPlusDecimal invertedSet];
    arithmeticOperationCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"+-Xx÷=±Cc"];
}

- (void)finishHighlightButton:(NSTimer*)theTimer
{
    NSButton * buttonToUnhighlight = [theTimer userInfo];
    
    [buttonToUnhighlight highlight: NO];
}

- (void) momentaryHighlightButtonForCharacter: (NSString *) characterPressed
{
    for( NSView * aView in [self.window.contentView subviews])
    {
        if([aView isKindOfClass: [NSButton class]])
        {
            NSButton * aButton = (NSButton *) aView;
            
            // "case insensitive" doesn't matter for numbers or most operations *except* X & x, multiplication
            if([characterPressed compare: [aButton title] options: NSCaseInsensitiveSearch ] == NSOrderedSame)
            {
                [aButton highlight: YES];
                
                [NSTimer scheduledTimerWithTimeInterval:0.1
                                                 target:self
                                               selector:@selector(finishHighlightButton:)
                                               userInfo:aButton repeats:NO];
                return;
            }
        }
    }
}

- (void)keyUp:(NSEvent *)theEvent
{
    [self momentaryHighlightButtonForCharacter: [theEvent characters]];

    unichar characterPressed = [[theEvent characters] characterAtIndex: 0];
    if([arithmeticOperationCharacterSet characterIsMember: characterPressed] == YES)
    {
        [self operationButtonTouched: characterPressed];
    }
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    NSString * stringFromControl = textField.stringValue;
    NSLog( @"new control text = %@ %@ %ld", textField.stringValue, stringFromControl, [stringFromControl length]);

    NSRange rangeOfBogusCharacter = [stringFromControl rangeOfCharacterFromSet: arithmeticOperationCharacterSet];
    if(rangeOfBogusCharacter.location != NSNotFound)
    {
        // the only arithmetic character we'll allow to be displayed is a "-" sign in the left-most position
        if(rangeOfBogusCharacter.location == 0)
        {
            unichar possiblyBogusCharacter = [textField.stringValue characterAtIndex: 0];
            if(possiblyBogusCharacter == '-')
                return;
        }
        
        textField.stringValue = self.previousTextFieldString;
        return;
    }
    
    if((self.newValueBeingTyped == NO ) && (self.reallyPreviousTextFieldString != nil))
    {
        NSMutableString * stringToPrune = [stringFromControl mutableCopy];
        
        [stringToPrune replaceOccurrencesOfString: self.reallyPreviousTextFieldString withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [stringToPrune length])];
        
        textField.stringValue = stringToPrune;
        self.previousTextFieldString = stringToPrune;
        self.newValueBeingTyped = YES;
    }

    // look for multiple decimal / period characters (and disallow if there is more than one)
    NSArray * componentsSplitByDecimals = [stringFromControl componentsSeparatedByString: @"."];
    if([componentsSplitByDecimals count] > 2)
    {
        textField.stringValue = self.previousTextFieldString;
        NSBeep();
        return;
    }

    rangeOfBogusCharacter = [textField.stringValue rangeOfCharacterFromSet: invertedDecimalCharacterSet];
    if(rangeOfBogusCharacter.location != NSNotFound)
    {
        // beeping tells the user they typed something bogus
        NSBeep();
        if([self.previousTextFieldString length] > 0)
            textField.stringValue = self.previousTextFieldString;
        else
            textField.stringValue = @"";
    } else {
        self.previousTextFieldString = textField.stringValue;
        self.newValueBeingTyped = YES;
    }
}

- (void) clearCurrentOperation
{
    lastOperation = 0;
    lastOperationString.stringValue = @"";
    textField.stringValue = @"";
}

// flips the sign of the current value from positive to negative
- (void) toggleSign
{
    CGFloat currentlyVisibleValue = [textField floatValue];
    
    currentlyVisibleValue = (currentlyVisibleValue * -1 );
    
    textField.stringValue = [NSString stringWithFormat: @"%g", currentlyVisibleValue];
}

- (void) doSomethingArithmetically
{
    CGFloat resultingValue;
    CGFloat currentVisibleValue = [textField floatValue];

    switch(lastOperation)
    {
        // if you're looking closely at this code, you may be wondering what the "L" is doing there?
        //
        // http://stackoverflow.com/questions/2151783/objective-c-doesnt-like-my-unichars
        // found this neat C keyword trick via: http://stackoverflow.com/a/7008133/981049
        case L'÷' :
            resultingValue = (savedValue / currentVisibleValue);
            break;
        case '+' :
            resultingValue = (savedValue + currentVisibleValue);
            break;
        case '-' :
            resultingValue = (savedValue - currentVisibleValue);
            break;
        case 'x' :
        case 'X' :
            resultingValue = (savedValue * currentVisibleValue);
            break;
        case '=' :
        case 0 :
            resultingValue = currentVisibleValue;
            break;
        default :
            resultingValue = 0; // or "E"? or current value?  or?
            NSLog( @"hmm, a last operation I wasn't expecting");
            break;
    }
    
    savedValue = resultingValue;
    textField.stringValue = [NSString stringWithFormat: @"%g", resultingValue];
}

- (void) operationButtonTouched: (unichar) currentOperation
{
    switch(currentOperation)
    {
        // I'm not certain that this is an arithmetic operation
        // but here we're toggling the sign of the number currently visible
        case L'±' :
            [self toggleSign];
            break;
        case 'c' :
        case 'C' :
            [self clearCurrentOperation];
            break;
        case L'÷' :
        case '+' :
        case '-' :
        case 'x' :
        case 'X' :
            [self doSomethingArithmetically];
            lastOperation = currentOperation;
            lastOperationString.stringValue = [NSString stringWithFormat: @"%c", currentOperation];
            self.reallyPreviousTextFieldString = textField.stringValue;
            self.newValueBeingTyped = NO;
            break;
        case '=' :
            [self doSomethingArithmetically];
            lastOperation = currentOperation;
            lastOperationString.stringValue = @""; // clear out last operation since we just did an "="
            self.reallyPreviousTextFieldString = textField.stringValue;
            self.newValueBeingTyped = NO;
            break;
        default :
            NSLog( @"hmmm, an operation I wasn't expecting");
            break;
    }
}

- (IBAction) calculatorButtonPressed: (id) sender
{
    NSButton * buttonPressed = (NSButton *) sender;
    NSString * stringFromButton = [buttonPressed title];
    unichar characterPressed = [stringFromButton characterAtIndex: 0];
    
    if([[NSCharacterSet decimalDigitCharacterSet] characterIsMember: characterPressed] == YES)
    {
        if(self.newValueBeingTyped == NO)
        {
            textField.stringValue = @"";
            self.newValueBeingTyped = YES;
        }
        
        NSText * fieldEditor = [self.window fieldEditor: YES forObject:textField];
        NSRange insertionRange = fieldEditor.selectedRange;
        NSMutableString * ourNewCalculatorString = [textField.stringValue mutableCopy];
        
        if(insertionRange.length > 0)
        {
            // replace!
            [ourNewCalculatorString replaceCharactersInRange: insertionRange withString: stringFromButton];
        } else {
            // insert
            [ourNewCalculatorString insertString: stringFromButton atIndex: insertionRange.location];
        }

        textField.stringValue = ourNewCalculatorString;
        insertionRange.location = insertionRange.location+1;
        insertionRange.length = 0;
        fieldEditor.selectedRange = insertionRange;
    }
    
    if([arithmeticOperationCharacterSet characterIsMember: characterPressed] == YES)
    {
        [self operationButtonTouched: characterPressed];
    }
}

@end
