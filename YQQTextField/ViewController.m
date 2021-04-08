//
//  ViewController.m
//  YQQTextField
//
//  Created by 朱逸 on 2021/3/4.
//

#import "ViewController.h"
#import "YQQTextField.h"

@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet YQQTextField *textField;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _textField.delegate = self;
}

- (IBAction)selectButton:(UIButton *)sender {
    for (UIButton *button in self.buttonArray) {
        if (button == sender) {
            button.selected = YES;
            _textField.inputType = button.tag;
        } else {
            button.selected = NO;
        }
    }
    [_textField resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return [_textField formatTextField:_textField shouldChangeCharactersInRange:range replacementString:string];
}




@end
