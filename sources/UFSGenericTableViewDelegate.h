#import <UIKit/UIKit.h>

@interface UFSGenericTableViewDelegate : NSObject <UITableViewDelegate>

@property (nonatomic, assign) UIViewController *viewController;
- (id)initWithViewController:(UIViewController *)viewController;

@property (nonatomic, retain) id <UITableViewDataSource> dataSource;
- (id)initWithDataSource:(id <UITableViewDataSource>)dataSource;

// Why not both?
- (id)initWithViewController:(UIViewController *)viewController andDataSource:(id <UITableViewDataSource>)dataSource;

@end
