TSValidatedTextField
====================

Simple and ready to use subclass of UITextField that allows you to validate TextField text value with pattern you set.

![image](https://dl.dropboxusercontent.com/u/11493275/github/TSValidatedTextField/1.png)![image](https://dl.dropboxusercontent.com/u/11493275/github/TSValidatedTextField/2.png)


Properties
====================
**regexpPattern** - String pattern which will be used to valid value from the field.

**regexp** - NSRegularExpression object that you can pass to use your RegularExpression object instead of default one.

**regexpValidColor** - Color for valid text value.

**regexpInvalidColor** - Color for invalid text value.

Colors aren't necessary, you can set block instead and do other things after field validation.

**validatedFieldBlock** - Block which return ValidationResult enum value. It's not set by default. You may set it, but it's not necessary. It should be used for more sophisticated things during validation than changing textField color (use regexpValidColor and regexpInvalidColor instead).

**validWhenType** - Default set to YES. If you set it to NO value will be validated when editing is done. E.g. after switch to next field.

**looksForManyOccurences** - If set to YES field will be validated and validator will be looking for one or more occurencies in the value. It should be used with occurencesSeparators property described below.

**occurencesSeparators** - This value should be set only if you are using looksForManyOccurences. This array store separators which user can use to separate content in the field. E.g. user typed numbers "20, 30,40, 50". If occurencesSeparators is set to @[",", ", "] the value will be validated successful. Property can simplify pattern.

**numberOfCharactersToStartValidation** - Field is validate when its value will be equal or longer than set number. If the text is shorter than this value the field looks normal (without valid and invalid colors - start state) but if block has been defined it will be called with ValueTooShortToValidate. Default set to 1 (minimum value).

**isValid** - (readonly, BOOL) return YES if value in field is valid, otherwise NO.


How to use it?
====================

There are few ways to use this class.


***1) Colored text field***
```obj-c
    _fullNameTextField.regexpPattern = @"[a-zA-Z]{2,}+(\\s{1}[a-zA-Z]{2,}+)+"; /// e.g. Tomasz Szulc or Cing Yo Ciong
    _fullNameTextField.regexpValidColor = [UIColor validColor];
    _fullNameTextField.regexpInvalidColor = [UIColor invalidColor];
```

Regexp pattern and both valid and invalid colors have been set. TextField is validating when user typing.
    
    
***2) TextField with validation block***
```obj-c
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
```

No colors set (if valid or invalid the textColor will be still the same).
validWhenType property has been set to NO so field will be validated when user end editing. Instead of change color of text block will be called with one case of ValidationResult enum.
  
    
***3) Validation after few characters***
```obj-c
    _wordStartsWithA.regexpPattern = @"^A[a-zA-Z]{3,}";
    _wordStartsWithA.regexpValidColor = [UIColor validColor];
    _wordStartsWithA.regexpInvalidColor = [UIColor invalidColor];
    
    /// Visualization of validation will be visible when value is 4 characters long.
    _wordStartsWithA.minimalNumberOfCharactersToStartValidation = 4;
```

Text field will be validated if length of text will be equal or longer than minimalNumberOfCharactersToStartValidation. If block has been configured it will be called with parameter TooShortToValidate value.


***4) TextField check for many occurences***
```obj-c
    _separatedNumbersByComma.regexpPattern = @"[-]?[0-9]+";
    _separatedNumbersByComma.regexpValidColor = [UIColor validColor];
    _separatedNumbersByComma.regexpInvalidColor = [UIColor invalidColor];
    _separatedNumbersByComma.looksForManyOccurences = YES;
    _separatedNumbersByComma.occurencesSeparators = @[@",", @", "];
```

The value looksForManyOccurences and occurencesSeparators have been set here. If field wants numbers it can be validate successful if user type "20, 20, 40, 60" or "20,20,40,60" or "20, 20,40, 60" too. It's strongly recommended to use looksForManyOccurences and occurencesSeparators together.
    
    
***5) TextField with own NSRegularExpression***
```obj-c
    _wordStartsWithB.regexpValidColor = [UIColor validColor];
    _wordStartsWithB.regexpInvalidColor = [UIColor invalidColor];
    
    NSString *pattern = @"^B[a-zA-Z]{3,}";
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    [_wordStartsWithB setRegexp:regexp];
```

If default NSRegularExpression isn't sufficient you can set custom.

