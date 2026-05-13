#import <UIKit/UIKit.h>

@interface ArchitectMenu : UIView
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UIView *mainPanel;
@property (nonatomic, strong) UILabel *titleLabel;

+ (instancetype)sharedInstance;
- (void)showMenu;
@end
