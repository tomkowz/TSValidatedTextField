//
//  ViewController.m
//  TSValidatedTextField-Sample
//
//  Created by Tomasz Szulc on 17.11.2013.
//  Copyright (c) 2013 Tomasz Szulc. All rights reserved.
//

#import "ViewController.h"
#import "TSValidatedTextField.h"
#import "UIColor+CustomColors.h"

@interface ViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet TSValidatedTextField *fullNameTextField;
@property (weak, nonatomic) IBOutlet TSValidatedTextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet TSValidatedTextField *wordStartsWithA;
@property (weak, nonatomic) IBOutlet TSValidatedTextField *separatedNumbersByComma;
@property (weak, nonatomic) IBOutlet TSValidatedTextField *wordStartsWithB;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureColoredTextField]; /// fullNameTextField
    [self configureTextFieldWithValidationBlock]; /// phoneNumberTextField
    [self configureTextFieldValidatedAfterFewCharacters]; /// wordStartsWithA
    [self configureTextFieldWhichValidatesManyOccurences]; /// separatedNumbersByComma;
    [self configureWordStartsWithB]; /// wordStartsWithB
}


- (void)configureColoredTextField
{
    _fullNameTextField.regexpPattern = @"[a-zA-Z]{2,}+(\\s{1}[a-zA-Z]{2,}+)+"; /// e.g. Tomasz Szulc or Cing Yo Ciong
    _fullNameTextField.regexpValidColor = [UIColor validColor];
    _fullNameTextField.regexpInvalidColor = [UIColor invalidColor];
}

- (void)configureTextFieldWithValidationBlock
{
    _phoneNumberTextField.regexpPattern = @"\\d{3}-\\d{3}-\\d{3}"; /// e.g 555-343-333
    _phoneNumberTextField.minimalNumberOfCharactersToStartValidation = 11;
    _phoneNumberTextField.validWhenType = NO;
    _phoneNumberTextField.validatedFieldBlock = ^(ValidationResult result, BOOL isEditing) {
      
        switch (result) {
            case ValidationPassed:
                NSLog(@"Field is valid.");
                break;
                
            case ValidationFailed:
                NSLog(@"Field is invalid.");
                break;
                
            case ValueTooShortToValidate:
                NSLog(@"Value too short to validate. Type longer");
                break;
        }
    };
}

- (void)configureTextFieldValidatedAfterFewCharacters
{
    _wordStartsWithA.regexpPattern = @"^A[a-zA-Z]{3,}";
    _wordStartsWithA.regexpValidColor = [UIColor validColor];
    _wordStartsWithA.regexpInvalidColor = [UIColor invalidColor];
    
    /// Visualization of validation will be visible when value is 4 characters long.
    _wordStartsWithA.minimalNumberOfCharactersToStartValidation = 4;
    
    [_wordStartsWithA addObserver:self forKeyPath:@"isValid" options:NSKeyValueObservingOptionNew context:(__bridge void *)(self)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isValid"])
    {
        NSLog(@"_wordStartWithA.isValid = %@", change[@"new"]);
    }
}

- (void)configureTextFieldWhichValidatesManyOccurences
{
    _separatedNumbersByComma.regexpPattern = @"[-]?[0-9]+";
    _separatedNumbersByComma.regexpValidColor = [UIColor validColor];
    _separatedNumbersByComma.regexpInvalidColor = [UIColor invalidColor];
    _separatedNumbersByComma.looksForManyOccurences = YES;
    _separatedNumbersByComma.occurencesSeparators = @[@",", @", "];
}

- (void)configureWordStartsWithB
{
    _wordStartsWithB.regexpValidColor = [UIColor validColor];
    _wordStartsWithB.regexpInvalidColor = [UIColor invalidColor];
    
    NSString *pattern = @"^B[a-zA-Z]{3,}";
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    [_wordStartsWithB setRegexp:regexp];
}


#pragma mark - UITextFieldDelegate methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_fullNameTextField resignFirstResponder];
    [_phoneNumberTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

@end
