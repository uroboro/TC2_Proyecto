#import "UFSBasicEditor.h"

#import "utils.h"

@interface UFSBasicEditor () {
	BOOL _saveChanges;
}

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UITextView *numView;

@end

@implementation UFSBasicEditor

#pragma mark - UITextView Protocol

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self setEditing:YES animated:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if (textView.tag == 0) {
            [_numView becomeFirstResponder];
            [self saveWord];
        } else {
            [textView resignFirstResponder];
            [self saveNumber];
        }
        return NO;
    }

    return YES;
}

#pragma mark - UIViewController methods

- (void)viewDidLoad {
	[super viewDidLoad];

	self.title = NSLocalizedString(@"UFSBasicEditor", nil);

	CGRect r = UtilsAvailableScreenRect();

	[self.view addSubview:_textView = ({
		CGRect frame = CGRectMake(r.size.width * 1 / 8, 10, r.size.width * 3 / 4, 40);
        UITextView *textView = [[UITextView alloc] initWithFrame:frame];
        textView.text = self.word;
        textView.font = [UIFont systemFontOfSize:21];
        textView.tag = 0;
        textView.delegate = self;
        textView;
	})];

	[self.view addSubview:_numView = ({
		CGRect frame = CGRectMake(r.size.width * 1 / 8, 60, r.size.width * 3 / 4, 40);
		UITextView *textView = [[UITextView alloc] initWithFrame:frame];
        textView.text = @(self.frequency).description;
        textView.font = [UIFont systemFontOfSize:21];
        textView.tag = 1;
        textView.delegate = self;
        textView;
	})];

}

- (void)saveAction:(UIButton *)button {
    _saveChanges = YES;
    [self setEditing:NO animated:YES];
    _saveChanges = NO;
}

- (void)saveWord {
    if (![_textView.text isEqualToString:_word]) {
        [_word release];
        _word = [_textView.text copy];
    }
}

- (void)saveNumber {
    if (_numView.text) {
        _frequency = _numView.text.integerValue;
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];

    if (editing) {
    	UIBarButtonItem *b = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveAction:)];
    	self.navigationItem.rightBarButtonItem = b;
    	[b release];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
        [_textView resignFirstResponder];
        [_numView resignFirstResponder];
        if (_saveChanges) {
            [self saveWord];
            [self saveNumber];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

    if (_callback) _callback(_word, _frequency);
}

@end
