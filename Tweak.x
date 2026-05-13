#import <UIKit/UIKit.h>

// --- تعريف واجهة المنيو عشان الإيرور يختفي ---
@interface ArchitectMenu : NSObject
+ (void)setTitle:(NSString *)title color:(UIColor *)color;
+ (void)addTabBar:(NSString *)title;
+ (void)addSwitch:(NSString *)title description:(NSString *)desc handler:(void(^)(bool val))handler;
+ (void)addSlider:(NSString *)title min:(float)min max:(float)max default:(float)def handler:(void(^)(float val))handler;
@end

// --- متغيرات التحكم ---
static float pSpeed = 1.0f;
static bool magic_bullet = false;
static bool infinite_ammo = false;

// --- الهوكات ---
%hook PlayerController
- (float)movementSpeed { return (pSpeed > 1.0f) ? (%orig * pSpeed) : %orig; }
%end

%hook WeaponSystem
- (float)calculateBulletSpread { return magic_bullet ? 0.0f : %orig; }
- (bool)hasInfiniteAmmo { return infinite_ammo ? YES : %orig; }
%end

// --- تشغيل المنيو (الربط المباشر) ---
%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // جرب نستخدم اسم الكلاس اللي موجود في الـ Header بتاعك
        [ArchitectMenu setTitle:@"SAKR MENU" color:[UIColor greenColor]];
        
        [ArchitectMenu addTabBar:@"Speed"];
        [ArchitectMenu addSlider:@"Speed" min:1 max:10 default:1 handler:^(float val) { pSpeed = val; }];
        
        [ArchitectMenu addTabBar:@"Combat"];
        [ArchitectMenu addSwitch:@"Magic Bullet" description:@"طلقة مستقيمة" handler:^(bool val) { magic_bullet = val; }];
        [ArchitectMenu addSwitch:@"Infinite Ammo" description:@"ذخيرة" handler:^(bool val) { infinite_ammo = val; }];
    });
}
