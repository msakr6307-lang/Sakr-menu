#import <UIKit/UIKit.h>

// تعريف واجهة المنيو عشان الإيرور يختفي
@interface SakrMenu : NSObject
+ (void)setTitle:(NSString *)title color:(UIColor *)color;
+ (void)addTabBar:(NSString *)title;
+ (void)addSlider:(NSString *)title min:(float)min max:(float)max default:(float)def handler:(void(^)(float val))handler;
+ (void)addSwitch:(NSString *)title description:(NSString *)desc handler:(void(^)(bool val))handler;
@end

// --- متغيرات التحكم ---
static float pSpeed = 1.0f;
static float cSpeed = 1.0f;
static bool auto_miner = false;
static bool auto_delivery = false;

// --- هوكات السرعة ---
%hook PlayerController
- (float)movementSpeed { return %orig * pSpeed; }
%end

%hook VehicleController
- (float)maxVehicleSpeed { return %orig * cSpeed; }
%end

// --- هوكات الوظائف ---
%hook JobManager
- (void)onActionTriggered {
    if (auto_miner || auto_delivery) {
        %orig;
    } else {
        %orig;
    }
}
- (float)deliveryCheckDistance {
    return auto_delivery ? 500.0f : %orig;
}
%end

// --- بناء المنيو ---
%ctor {
    [SakrMenu setTitle:@"SAKR" color:[UIColor cyanColor]];
    
    [SakrMenu addTabBar:@"Speed"];
    [SakrMenu addSlider:@"Player Speed" min:1 max:10 default:1 handler:^(float val) {
        pSpeed = val;
    }];
    [SakrMenu addSlider:@"Car Speed" min:1 max:20 default:1 handler:^(float val) {
        cSpeed = val;
    }];
    
    [SakrMenu addTabBar:@"Jobs"];
    [SakrMenu addSwitch:@"Auto Miner" description:@"عامل منجم تلقائي" handler:^(bool val) {
        auto_miner = val;
    }];
    [SakrMenu addSwitch:@"Auto Delivery" description:@"مندوب توصيل سريع" handler:^(bool val) {
        auto_delivery = val;
    }];
}
