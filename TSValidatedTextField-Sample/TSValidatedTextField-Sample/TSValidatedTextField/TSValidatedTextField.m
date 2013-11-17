//
//  TSValidatedTextField.m
//  TSRegexpTextField
//
//  Created by Tomasz Szulc on 16.11.2013.
//  Copyright (c) 2013 Tomasz Szulc. All rights reserved.
//

#import "TSValidatedTextField.h"

@interface TSValidatedTextField ()

@property (readonly) BOOL canValid;
@property UIColor *baseColor;
@property BOOL fieldHasBeenEdited;

@end

@implementation TSValidatedTextField
{
    ValidationResult _validationResult;
    NSString *_previousText;
}

@synthesize regexpInvalidColor = _regexpInvalidColor;
@synthesize regexpValidColor = _regexpValidColor;
@synthesize regexpPattern = _regexpPattern;
@synthesize looksForManyOccurences = _looksForManyOccurences;
@synthesize validWhenType = _validWhenType;

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    {
        [self configureForValidation];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self configureForValidation];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self configureForValidation];
    }
    return self;
}

- (void)configureForValidation
{
    _minimalNumberOfCharacterToStartValidation = 1;
    _validWhenType = YES;
    _fieldHasBeenEdited = NO;
    _validationResult = ValidationFailed;
    _occurencesSeparators = nil;
    [self setRegexpPattern:@""];
}


#pragma mark - Lifecycle of validation

- (BOOL)isEditing
{
    BOOL isEditing = [super isEditing];
    if ((isEditing && _validWhenType) ||
        (!isEditing && !_validWhenType))
    {
        if (!_previousText || ![_previousText isEqualToString:self.text])
        {
            _previousText = self.text;
            if (self.text.length > 0 && !_fieldHasBeenEdited)
                _fieldHasBeenEdited = YES;
            
            if (_fieldHasBeenEdited)
            {
                [self willChangeValueForKey:@"isValid"];
                _validationResult = [self validRegexp];
                [self didChangeValueForKey:@"isValid"];

                if (self.text.length >= _minimalNumberOfCharacterToStartValidation)
                {
                    [self updateViewForState:_validationResult];
                    
                    if (_validatedFieldBlock)
                        _validatedFieldBlock(_validationResult, isEditing);
                }
                else if (self.text.length == 0 ||
                         self.text.length < _minimalNumberOfCharacterToStartValidation)
                {
                    if (_baseColor)
                        self.textColor = _baseColor;
                    
                    if (_validatedFieldBlock)
                        _validatedFieldBlock(ValueTooShortToValidate, isEditing);
                }
            }
        }
    }
    
    return isEditing;
}


#pragma mark - Accessors
- (BOOL)isValid
{
    if (_validationResult == ValidationPassed)
        return YES;
    else
        return NO;
}

- (BOOL)isLooksForManyOccurences
{
    return _looksForManyOccurences;
}

- (void)setLooksForManyOccurences:(BOOL)looksForManyOccurences
{
    _looksForManyOccurences = looksForManyOccurences;
}

- (BOOL)isValidWhenType
{
    return _validWhenType;
}

- (void)setValidWhenType:(BOOL)validWhenType
{
    _validWhenType = validWhenType;
}


#pragma mark - Regexp Pattern accessors
- (void)setRegexpPattern:(NSString *)regexpPattern
{
    if (!regexpPattern)
        regexpPattern = @"";
    
    [self configureRegexpWithPattern:regexpPattern];
}

- (NSString *)regexpPattern
{
    return _regexp.pattern;
}

- (void)configureRegexpWithPattern:(NSString *)pattern
{
    _regexp = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
}
    

#pragma mark - Regexp Colors accessors
- (void)setRegexpInvalidColor:(UIColor *)regexpInvalidColor
{
    if (!_baseColor)
        _baseColor = self.textColor;
    _regexpInvalidColor = regexpInvalidColor;
}

- (UIColor *)regexpInvalidColor
{
    return _regexpInvalidColor;
}

- (void)setRegexpValidColor:(UIColor *)regexpValidColor
{
    if (!_baseColor)
        _baseColor = self.textColor;
    _regexpValidColor = regexpValidColor;
}

- (UIColor *)regexpValidColor
{
    return _regexpValidColor;
}


#pragma mark - Validation View Management
- (void)updateViewForState:(ValidationResult)result
{
    UIImageView *imageView = (UIImageView *)self.rightView;
    
    BOOL canShow = self.canValid;
    imageView.hidden = !canShow;
    
    if (canShow)
    {
        UIColor *color = self.textColor;
        if (result == ValidationPassed && _regexpValidColor)
            color = _regexpValidColor;
        else if (result == ValidationFailed && _regexpInvalidColor)
            color = _regexpInvalidColor;

        self.textColor = color;
    }
}

- (BOOL)canValid
{
    return _regexp.pattern != nil;
}


#pragma mark - Validation
- (ValidationResult)validRegexp
{
    NSString *text = self.text;
    ValidationResult valid = ValidationPassed;
    if (self.canValid)
    {
        NSRange textRange = NSMakeRange(0, text.length);
        NSArray *matches = [_regexp matchesInString:text options:0 range:textRange];

        NSRange resultRange = NSMakeRange(NSNotFound, 0);
        if (matches.count == 1 && !_looksForManyOccurences)
        {
            NSTextCheckingResult *result = (NSTextCheckingResult *)matches[0];
            resultRange = result.range;
        }
        else if (matches.count != 0 && self.isLooksForManyOccurences)
        {
            resultRange = [self rangeFromTextCheckingResults:matches];
        }
        
        if (NSEqualRanges(textRange, resultRange))
            valid = ValidationPassed;
        else
            valid = ValidationFailed;
    }
    
    return valid;
}

- (NSRange)rangeFromTextCheckingResults:(NSArray *)array
{
    /// Valid first match
    NSTextCheckingResult *firstResult = (NSTextCheckingResult *)array[0];
    if (!(firstResult.range.location == 0 && firstResult.range.length > 0))
        return NSMakeRange(NSNotFound, 0);
    
    
    /// Valid all matches
    NSInteger lastLocation = 0;
    
    if (array.count > 0)
    {
        for (NSTextCheckingResult *result in array)
        {
            if (lastLocation == result.range.location)
                lastLocation = result.range.location + result.range.length;
            else if (lastLocation < result.range.location)
            {
                NSString *stringInRange = [self.text substringWithRange:NSMakeRange(lastLocation, result.range.location - lastLocation)];

                BOOL separatorValid = NO;
                if (_occurencesSeparators)
                {
                    for (NSString *separator in _occurencesSeparators)
                    {
                        if ([stringInRange isEqualToString:separator])
                        {
                            lastLocation = result.range.location + result.range.length;
                            separatorValid = YES;
                            break;
                        }
                    }
                }
                
                if (separatorValid)
                    lastLocation = result.range.location + result.range.length;
                else
                    break;
            }
            else
                break;
        }
    }
    
    return NSMakeRange(0, lastLocation);
}


@end
