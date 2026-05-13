#import <UIKit/UIKit.h>

// تعريف الواجهة يدوياً لضمان عدم حدوث Linker Error
@interface ArchitectMenu : NSObject
+ (void)setTitle:(NSString *)title color:(UIColor *)color;
+ (void)addTabBar:(NSString *)title;
+ (void)addSwitch:(NSString *)title description:(NSString *)desc handler:(void(^)(bool val))handler;
+ (void)addSlider:(NSString *)title min:(float)min max:(float)max default:(float)def handler:(void(^)(float val))handler;
@end

// --- متغيرات التحكم (افتراضياً OFF) ---
static float pSpeed = 1.0f;
static bool magic_bullet = false;
static bool infinite_ammo = false;
static bool auto_delivery = false;

// --- هوكات اللعبة ---
%hook PlayerController
- (float)movementSpeed { 
    return (pSpeed > 1.0f) ? (%orig * pSpeed) : %orig; 
}
%end

%hook WeaponSystem
- (float)calculateBulletSpread { 
    return magic_bullet ? 0.0f : %orig; 
}
- (bool)hasInfiniteAmmo { 
    return infinite_ammo ? YES : %orig; 
}
%end

%hook JobManager
- (float)deliveryCheckDistance { 
    return auto_delivery ? 500.0f : %orig; 
}
%end

// --- بناء المنيو (الربط اليدوي) ---
%ctor {
    // تأخير بسيط لضمان ظهور المنيو بعد دخول اللعبة
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [ArchitectMenu setTitle:@"SAKR MENU" color:[UIColor orangeColor]];
        
        [ArchitectMenu addTabBar:@"Speed"];
        [ArchitectMenu addSlider:@"Player Speed" min:1 max:10 default:1 handler:^(float val) {
            pSpeed = val;
        }];
        
        [ArchitectMenu addTabBar:@"Combat"];
        [ArchitectMenu addSwitch:@"Magic Bullet" description:@"طلقة مستقيمة" handler:^(bool val) {
            magic_bullet = val;
        }];
        [ArchitectMenu addSwitch:@"Infinite Ammo" description:@"ذخيرة لا نهائية" handler:^(bool val) {
            infinite_ammo = val;
        }];
        
        [ArchitectMenu addTabBar:@"Jobs"];
        [ArchitectMenu addSwitch:@"Auto Delivery" description:@"توصيل من بعيد" handler:^(bool val) {
            auto_delivery = val;
        }];
    });
}
