#import <UIKit/UIKit.h>
#import "ArchitectMenu.h"

// --- متغيرات التحكم ---
static float pSpeed = 1.0f;
static float cSpeed = 1.0f;
static bool auto_miner = false, auto_delivery = false;
static bool magic_bullet = false, infinite_ammo = false;

// متغيرات ESP (كشف الأماكن)
static bool esp_box = false, esp_lines = false, esp_skeleton = false;
static bool esp_health = false, esp_distance = false;
static float esp_max_dist = 500.0f; // المسافة الافتراضية

// --- هوكات السرعة والوظائف والقتال ---
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

// --- هوك كشف الأماكن الاحترافي (ESP) ---
%hook PlayerRenderer
- (void)drawESP {
    // التحقق من المسافة قبل الرسم
    float dist = [self getDistanceToPlayer]; 
    if (dist > esp_max_dist) return; 

    if (esp_box) { /* رسم المربع */ }
    if (esp_lines) { /* رسم الخطوط */ }
    if (esp_skeleton) { /* رسم الهيكل العظمي */ }
    if (esp_health) { /* إظهار شريط الصحة */ }
    if (esp_distance) { /* كتابة المسافة بالمتر */ }
    
    %orig;
}
%end

// --- بناء واجهة SAKR MENU الاحترافية ---
void setup() {
    [Menu setTitle:@"SAKR MENU VIP" color:[UIColor cyanColor]];
    
    // قسم كشف الأماكن (Visuals)
    [Menu addTabBar:@"ESP Settings"];
    [Menu addSwitch:@"ESP Boxes" description:@"مربعات حول العدو" handler:^(bool val) { esp_box = val; }];
    [Menu addSwitch:@"ESP Lines" description:@"خطوط التوجيه" handler:^(bool val) { esp_lines = val; }];
    [Menu addSwitch:@"ESP Skeleton" description:@"هيكل اللاعب" handler:^(bool val) { esp_skeleton = val; }];
    [Menu addSwitch:@"ESP Health" description:@"صحة اللاعب" handler:^(bool val) { esp_health = val; }];
    [Menu addSwitch:@"ESP Distance" description:@"مسافة اللاعب" handler:^(bool val) { esp_distance = val; }];
    
    // سلايدر التحكم في المسافة (من 50 لـ 500 متر)
    [Menu addSlider:@"Render Distance" min:50 max:500 default:500 handler:^(float val) {
        esp_max_dist = val;
    }];

    [Menu addTabBar:@"Combat"];
    [Menu addSwitch:@"Magic Bullet" description:@"طلقة مستقيمة" handler:^(bool val) { magic_bullet = val; }];
    [Menu addSwitch:@"Infinite Ammo" description:@"ذخيرة لا نهائية" handler:^(bool val) { infinite_ammo = val; }];

    [Menu addTabBar:@"Misc"];
    [Menu addSlider:@"Player Speed" min:1 max:10 default:1 handler:^(float val) { pSpeed = val; }];
    [Menu addSwitch:@"Auto Miner" description:@"عامل منجم" handler:^(bool val) { auto_miner = val; }];
}
