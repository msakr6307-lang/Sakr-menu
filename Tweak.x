#import <UIKit/UIKit.h>

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
    if (auto_miner || auto_delivery) { %orig; } 
    else { %orig; }
}
- (float)deliveryCheckDistance { return auto_delivery ? 500.0f : %orig; }
%end

// --- هوكات القتال (جديد) ---
%hook WeaponSystem
- (float)calculateBulletSpread {
    return 0.0f; // طلقة مستقيمة (Magic Bullet)
}
- (bool)hasInfiniteAmmo {
    return YES; // رصاص مبيخلصش
}
%end

// --- تشغيل النظام ---
%ctor {
    NSLog(@"SAKR MENU: ALL FEATURES ARMED");
}
