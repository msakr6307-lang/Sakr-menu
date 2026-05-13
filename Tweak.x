#import <UIKit/UIKit.h>

// تعريف الواجهة عشان السيرفر ميتلخبطش
@interface ArchitectMenu : NSObject
+ (void)setTitle:(NSString *)title color:(UIColor *)color;
+ (void)addTabBar:(NSString *)title;
+ (void)addSlider:(NSString *)title min:(float)min max:(float)max default:(float)def handler:(void(^)(float val))handler;
+ (void)addSwitch:(NSString *)title description:(NSString *)desc handler:(void(^)(bool val))handler;
@end

// --- متغيرات التحكم ---
static float pSpeed = 1.0f;
static float cSpeed = 1.0f;
static bool auto_miner = false, auto_delivery = false;
static bool magic_bullet = false, infinite_ammo = false;
static bool esp_box = false, esp_lines = false;
static float esp_max_dist = 500.0f;

// --- هوكات اللعبة ---
%hook PlayerController
- (float)movementSpeed { return %orig * pSpeed; }
%end

%hook JobManager
- (void)onActionTriggered { if (auto_miner || auto_delivery) { %orig; } else { %orig; } }
- (float)deliveryCheckDistance { return auto_delivery ? 500.0f : %orig; }
%end

%hook WeaponSystem
- (float)calculateBulletSpread { return magic_bullet ? 0.0f : %orig; }
- (bool)hasInfiniteAmmo { return infinite_ammo ? YES : %orig; }
%end

// --- تشغيل المنيو تلقائياً ---
%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [ArchitectMenu setTitle:@"SAKR MENU VIP" color:[UIColor cyanColor]];
        
        [ArchitectMenu addTabBar:@"Visuals"];
        [ArchitectMenu addSwitch:@"ESP Boxes" description:@"مربعات" handler:^(bool val) { esp_box = val; }];
        [ArchitectMenu addSlider:@"Dist" min:50 max:500 default:500 handler:^(float val) { esp_max_dist = val; }];

        [ArchitectMenu addTabBar:@"Combat"];
        [ArchitectMenu addSwitch:@"Magic Bullet" description:@"طلقة مستقيمة" handler:^(bool val) { magic_bullet = val; }];
        [ArchitectMenu addSwitch:@"Infinite Ammo" description:@"ذخيرة" handler:^(bool val) { infinite_ammo = val; }];

        [ArchitectMenu addTabBar:@"Misc"];
        [ArchitectMenu addSlider:@"Speed" min:1 max:10 default:1 handler:^(float val) { pSpeed = val; }];
        [ArchitectMenu addSwitch:@"Auto Miner" description:@"منجم" handler:^(bool val) { auto_miner = val; }];
    });
}
