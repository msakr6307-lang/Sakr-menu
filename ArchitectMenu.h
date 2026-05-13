#import <UIKit/UIKit.h>

@interface ArchitectMenu : UIView

// أزرار التحكم والسلايدرات
@property (nonatomic, strong) UISlider *fovSlider;
@property (nonatomic, strong) UISlider *distSlider;
@property (nonatomic, strong) UISegmentedControl *targetPart;

// عناصر الواجهة المرئية
@property (nonatomic, strong) UIView *crosshair; // الدائرة الزرقاء في منتصف الشاشة
@property (nonatomic, strong) UIButton *floatingButton; // أيقونة SAKR العائمة

// وظائف القائمة
+ (instancetype)sharedInstance;
- (void)togglePanel;

@end
