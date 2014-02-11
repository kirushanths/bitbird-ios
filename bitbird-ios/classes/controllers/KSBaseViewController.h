
#import <UIKit/UIKit.h>
#import "KSMacros.h"

@interface KSBaseViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

#pragma mark -
#pragma mark Navigation

- (void)pushNewController:(UIViewController *)viewController;
- (void)pushNewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)popViewController;

#pragma mark -
#pragma mark Keyboard Events

- (void)registerKeyboardEvents;
- (void)removeKeyboardEvents;
- (void)keyboardWillShow:(NSNotification *)aNotification;
- (void)keyboardWillHide:(NSNotification *)aNotification;
- (void)keyboardWillToggle:(BOOL)willShow withNotification:(NSNotification *)aNotification animate:(BOOL)animate;


@end
