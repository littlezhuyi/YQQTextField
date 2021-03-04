//
//  YQQTextField.h
//  SQRentCar
//
//  Created by 朱逸 on 2019/4/24.
//  Copyright © 2019 sharesd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YQQInputType) {
    /**
     *  普通的TextField
     */
    YQQInputTypeNormal = 0,
    /**
     *  姓名TextField
     */
    YQQInputTypeName,
    /**
     *  手机号TextField
     */
    YQQInputTypePhone,
    /**
     *  银行卡TextField
     */
    YQQInputTypeBankcard,
    /**
     *  身份证TextField
     */
    YQQInputTypeIDCard,
    /**
     *  输入金额相关textField
     */
    YQQInputTypeMoney
};

NS_ASSUME_NONNULL_BEGIN

@interface YQQTextField : UITextField

@property (nonatomic, assign) IBInspectable YQQInputType inputType;

- (BOOL)formatTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
      replacementString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
