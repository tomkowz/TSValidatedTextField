//
//  TSValidatedTextField.m
//  TSRegexpTextField
//
//  Created by Tomasz Szulc on 16.11.2013.
//  Copyright (c) 2013 Tomasz Szulc. All rights reserved.
//

#import "TSValidatedTextField.h"

@interface TSValidatedTextField ()

@property (nonatomic, readonly) BOOL canValid;
@property (nonatomic, strong) UIColor *baseColor;
@property (nonatomic) BOOL fieldHasBeenEdited;

@property (nonatomic) ValidationResult validationResult;
@property (nonatomic, copy) NSString *previousText;
@end

@implementation TSValidatedTextField

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
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
    self.minimalNumberOfCharactersToStartValidation = 1;
    self.validWhenType = YES;
    self.fieldHasBeenEdited = NO;
    self.validationResult = ValidationResultFailed;
    self.occurencesSeparators = nil;
    [self setRegexpPattern:@""];
}


#pragma mark - Lifecycle of validation
- (void)validateFieldWithIsEditing:(BOOL)isEditing {
    if (!self.previousText || ![self.previousText isEqualToString:self.text])
    {
        self.previousText = self.text;
        if (self.text.length > 0 && !self.fieldHasBeenEdited)
            self.fieldHasBeenEdited = YES;
        
        if (self.fieldHasBeenEdited)
        {
            [self willChangeValueForKey:@"isValid"];
            self.validationResult = [self validRegexp];
            [self didChangeValueForKey:@"isValid"];
            
            if (self.text.length >= self.minimalNumberOfCharactersToStartValidation)
            {
                [self updateViewForState:self.validationResult];
                
                if (self.validatedFieldBlock)
                    self.validatedFieldBlock(self.validationResult, isEditing);
            }
            else if (self.text.length == 0 ||
                     self.text.length < self.minimalNumberOfCharactersToStartValidation)
            {
                if (_baseColor)
                    self.textColor = self.baseColor;
                
                if (self.validatedFieldBlock)
                    self.validatedFieldBlock(ValidationResultValueTooShort, isEditing);
            }
        }
    }

}

- (BOOL)isEditing
{
    BOOL isEditing = [super isEditing];
    if ((isEditing && self.validWhenType) ||
        (!isEditing && !self.validWhenType)) {
        [self validateFieldWithIsEditing:isEditing];
    }
    return isEditing;
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self validateFieldWithIsEditing:self.isEnabled];
}


#pragma mark - Accessors
- (BOOL)isValid
{
    if (self.validationResult == ValidationResultPassed)
        return YES;
    else
        return NO;
}

- (void)setMinimalNumberOfCharactersToStartValidation:(NSUInteger)minimalNumberOfCharacterToStartValidation
{
    if (minimalNumberOfCharacterToStartValidation  < 1)
        minimalNumberOfCharacterToStartValidation = 1;
    _minimalNumberOfCharactersToStartValidation = minimalNumberOfCharacterToStartValidation;
}


#pragma mark - Regexp Pattern accessors
- (void)setRegexpPattern:(NSString *)regexpPattern
{
    if (!regexpPattern)
        regexpPattern = @"";
    
    [self configureRegexpWithPattern:regexpPattern];
}

- (void)configureRegexpWithPattern:(NSString *)pattern
{
    self.regexp = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
}
    

#pragma mark - Regexp Colors accessors
- (void)setRegexpInvalidColor:(UIColor *)regexpInvalidColor
{
    if (!_baseColor)
        _baseColor = self.textColor;
    _regexpInvalidColor = regexpInvalidColor;
}

- (void)setRegexpValidColor:(UIColor *)regexpValidColor
{
    if (!_baseColor)
        _baseColor = self.textColor;
    _regexpValidColor = regexpValidColor;
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
        if (result == ValidationResultPassed && self.regexpValidColor)
            color = self.regexpValidColor;
        else if (result == ValidationResultFailed && self.regexpInvalidColor)
            color = self.regexpInvalidColor;

        self.textColor = color;
    }
}

- (BOOL)canValid
{
    return self.regexp.pattern != nil;
}

- (void)validate {
    [self validateFieldWithIsEditing:NO];
}

#pragma mark - Validation
- (ValidationResult)validRegexp
{
    NSString *text = self.text;
    ValidationResult valid = ValidationResultPassed;
    if (self.canValid)
    {
        NSRange textRange = NSMakeRange(0, text.length);
        NSArray *matches = [self.regexp matchesInString:text options:0 range:textRange];

        NSRange resultRange = NSMakeRange(NSNotFound, 0);
        if (matches.count == 1 && !self.looksForManyOccurences)
        {
            NSTextCheckingResult *result = (NSTextCheckingResult *)matches[0];
            resultRange = result.range;
        }
        else if (matches.count != 0 && self.isLooksForManyOccurences)
        {
            resultRange = [self rangeFromTextCheckingResults:matches];
        }
        
        if (NSEqualRanges(textRange, resultRange))
            valid = ValidationResultPassed;
        else
            valid = ValidationResultFailed;
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
                if (self.occurencesSeparators)
                {
                    for (NSString *separator in self.occurencesSeparators)
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
