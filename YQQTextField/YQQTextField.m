//
//  YQQTextField.m
//  SQRentCar
//
//  Created by 朱逸 on 2019/4/24.
//  Copyright © 2019 sharesd. All rights reserved.
//

#import "YQQTextField.h"

@interface YQQTextField () {
    NSString *_previousTextFieldContent;
    UITextRange *_previousSelection;
}

@end

@implementation YQQTextField

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return self;
}

- (void)setInputType:(YQQInputType)inputType {
    _inputType = inputType;
    
    switch (inputType) {
        case YQQInputTypeNormal:
        case YQQInputTypeName:{
            break;
        }
        case YQQInputTypePhone:
        case YQQInputTypeBankcard:
        {
            self.keyboardType = UIKeyboardTypeNumberPad;
            [self addTarget:self action:@selector(handleFormatTextFieldEvent:) forControlEvents:UIControlEventEditingChanged];
            break;
        }
        case YQQInputTypeIDCard:
        {
            self.keyboardType = UIKeyboardTypeNamePhonePad;
            [self addTarget:self action:@selector(handleFormatTextFieldEvent:) forControlEvents:UIControlEventEditingChanged];
            break;
        }
        case YQQInputTypeMoney:
        {
            self.keyboardType = UIKeyboardTypeDecimalPad;
            [self addTarget:self action:@selector(handleFormatTextFieldEvent:) forControlEvents:UIControlEventEditingChanged];
            break;
        }
    }
}

- (void)handleFormatTextFieldEvent:(UITextField *)textField {
    // 获取光标位置
    NSUInteger targetCursorPosition = [textField offsetFromPosition:textField.beginningOfDocument
                                                         toPosition:textField.selectedTextRange.start];
    
    NSString *textWithoutSpaces = [self removeNonDigitsAndSpecialCharacters:textField.text
                                                  andPreserveCursorPosition:&targetCursorPosition];
    //fix 系统九宫格英文输入x时 会替换前一个字符之后不能再次输入的bug
    if (self.inputType == YQQInputTypeIDCard) {
        if ([textWithoutSpaces hasSuffix:@"x"] || [textWithoutSpaces hasSuffix:@"X"]) {
            if (textWithoutSpaces.length == 17) {
                if (_previousTextFieldContent.length == 19) {
                    unichar characterToAdd = [textField.text characterAtIndex:(textField.text.length - 1)];
                    NSString *lastString = [NSString stringWithCharacters:&characterToAdd length:1];
                    [textField setText:[_previousTextFieldContent stringByAppendingString:lastString]];
                    return;
                }
            }
        }
    }
    NSUInteger maxLength = 0;
    switch (self.inputType) {
        case YQQInputTypePhone: {
            maxLength = 11;
            break;
        }
        case YQQInputTypeBankcard: {
            maxLength = 19;
            break;
        }
        case YQQInputTypeIDCard: {
            maxLength = 18;
            break;
        }
        case YQQInputTypeMoney: {
            maxLength = 12;
            break;
        }
        default:maxLength = NSUIntegerMax;
            break;
    }
    if ([textWithoutSpaces length] > maxLength) {
        [textField setText:_previousTextFieldContent];
        textField.selectedTextRange = _previousSelection;
        return;
    }
    
    NSString *textWithSpaces = [self insertSpacesIntoString:textWithoutSpaces
                                  andPreserveCursorPosition:&targetCursorPosition];
    
    textField.text = textWithSpaces;
    UITextPosition *targetPosition = [textField positionFromPosition:[textField beginningOfDocument] offset:targetCursorPosition];
    
    [textField setSelectedTextRange:[textField textRangeFromPosition:targetPosition toPosition:targetPosition]];
}

- (BOOL)formatTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
      replacementString:(NSString *)string {
    
    NSCharacterSet *characterSet = nil;
    
    switch (self.inputType) {
        case YQQInputTypeNormal: {
            return YES;
            break;
        }
        case YQQInputTypeName: {
            characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789 "];
            if ([string rangeOfCharacterFromSet:characterSet].location == NSNotFound) {
                return YES;
            } else {
                return NO;
            }
            break;
        }
        case YQQInputTypePhone:
        case YQQInputTypeBankcard: {
            string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
            characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789\b"];
            break;
        }
        case YQQInputTypeIDCard: {
            string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
            characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789Xx\b"];
            break;
        }
        case YQQInputTypeMoney: {
            return [self isValidAboutInputText:textField shouldChangeCharactersInRange:range replacementString:string decimalNumber:2];
            break;
        }
    }
    
    if ([string rangeOfCharacterFromSet:[characterSet invertedSet]].location != NSNotFound) {
        return NO;
    }
    _previousTextFieldContent = textField.text;
    _previousSelection = textField.selectedTextRange;
    
    return YES;
}

- (BOOL)isValidAboutInputText:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string decimalNumber:(NSInteger)number {
    
    NSScanner *scanner = [NSScanner scannerWithString:string];
    NSCharacterSet *numbers;
    NSRange pointRange = [textField.text rangeOfString:@"."];
    if ((pointRange.length > 0) && (pointRange.location < range.location || pointRange.location > range.location + range.length) ) {
        numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    } else {
        numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    }
    if ([textField.text isEqualToString:@""] && [string isEqualToString:@"."]) {
        return NO;
    }
    short remain = number; //保留 number位小数
    NSString *tempStr = [textField.text stringByAppendingString:string];
    NSUInteger strlen = [tempStr length];
    if (remain == 0 && ([tempStr isEqualToString:@"0"]||[tempStr containsString:@"."])) { //输入m内容为整数不以开头，且不允许输入“.”
        return NO;
    }
    if(pointRange.length > 0 && pointRange.location > 0) { //判断输入框内是否含有“.”。
        if([string isEqualToString:@"."]) { //当输入框内已经含有“.”时，如果再输入“.”则被视为无效。
            return NO;
        }
        if(strlen > 0 && (strlen - pointRange.location) > remain + 1) { //当输入框内已经含有“.”，当字符串长度减去小数点前面的字符串长度大于需要要保留的小数点位数，则视当次输入无效。
            return NO;
        }
    }
    NSRange zeroRange = [textField.text rangeOfString:@"0"];
    if(zeroRange.length == 1 && zeroRange.location == 0) { //判断输入框第一个字符是否为“0”
        if(![string isEqualToString:@"0"] && ![string isEqualToString:@"."] && ![string isEqualToString:@""] && [textField.text length] == 1) { //当输入框只有一个字符并且字符为“0”时，再输入不为“0”或者“.”的字符时，则将此输入替换输入框的这唯一字符。
            textField.text = string;
            return NO;
        } else {
            if(pointRange.length == 0 && pointRange.location > 0) { //当输入框第一个字符为“0”时，并且没有“.”字符时，如果当此输入的字符为“0”，则视当此输入无效。
                if([string isEqualToString:@"0"]) {
                    return NO;
                }
            }
        }
    }
    NSString *buffer;
    if (![scanner scanCharactersFromSet:numbers intoString:&buffer] && ([string length] != 0) ) {
        return NO;
    } else {
        _previousTextFieldContent = textField.text;
        _previousSelection = textField.selectedTextRange;
        return YES;
    }
}

- (NSString *)removeNonDigitsAndSpecialCharacters:(NSString *)string andPreserveCursorPosition:(NSUInteger *)cursorPosition {
    NSUInteger originalCursorPosition = *cursorPosition;
    NSMutableString *digitsOnlyString = [NSMutableString new];
    
    for (NSUInteger i = 0; i < [string length]; i++) {
        unichar characterToAdd = [string characterAtIndex:i];
        
        // isdigit() 判断是否为10进制字符
        if (isdigit(characterToAdd) || characterToAdd == 'X' || characterToAdd == 'x' || characterToAdd == '.') {
            NSString *stringToAdd = [NSString stringWithCharacters:&characterToAdd length:1];
            
            [digitsOnlyString appendString:stringToAdd];
        } else {
            if (i < originalCursorPosition) {
                (*cursorPosition)--;
            }
        }
    }
    return digitsOnlyString;
}

- (NSString *)insertSpacesIntoString:(NSString *)string andPreserveCursorPosition:(NSUInteger *)cursorPosition {
    NSMutableString *stringWithAddedSpaces = [NSMutableString new];
    NSUInteger cursorPositionInSpacelessString = *cursorPosition;
    
    for (NSUInteger i = 0; i < [string length]; i++) {
        switch (self.inputType) {
            case YQQInputTypePhone: {
                if (i == 3 || i == 7) {
                    [stringWithAddedSpaces appendString:@" "];
                    
                    if (i < cursorPositionInSpacelessString) {
                        (*cursorPosition)++;
                    }
                }
                
                break;
            }
            case YQQInputTypeBankcard: {
                if ((i > 0) && ((i % 4) == 0)) {
                    [stringWithAddedSpaces appendString:@" "];
                    
                    if (i < cursorPositionInSpacelessString) {
                        (*cursorPosition)++;
                    }
                }
                break;
            }
            case YQQInputTypeIDCard: {
                if (i == 6 || i == 14) {
                    [stringWithAddedSpaces appendString:@" "];
                    
                    if (i < cursorPositionInSpacelessString) {
                        (*cursorPosition)++;
                    }
                }
                
                break;
            }
            default:
                break;
        }
        
        
        unichar characterToAdd = [string characterAtIndex:i];
        NSString *stringToAdd = [NSString stringWithCharacters:&characterToAdd length:1];
        
        [stringWithAddedSpaces appendString:stringToAdd];
    }
    
    return stringWithAddedSpaces;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(paste:))//禁止粘贴
        return YES;
    if (action == @selector(select:))
        return YES;
    if (action == @selector(selectAll:))
        return YES;
    return [super canPerformAction:action withSender:sender];
}
@end
