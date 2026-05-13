#import <UIKit/UIKit.h>

// --- تعريف المنيو داخلياً لكسر نحس الإيرور ---
@interface SakrMenu : NSObject
+ (void)show;
@end

// --- متغيرات التحكم (Off بالبداية عشان التحكم اليدوي) ---
static float pSpeed = 1.0f;
static bool magic_bullet = false;
static bool infinite_ammo = false;

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

// --- تشغيل النظام ---
%ctor {
    NSLog(@"--- SAKR MENU LOADED ---");
    // المنيو هيشتغل هنا بالأزرار بتاعته أول ما تفتح اللعبة
}
