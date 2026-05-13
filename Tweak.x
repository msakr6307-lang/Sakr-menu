#import "ArchitectMenu.h"

// --- إعدادات الواجهة والألوان ---
#define MENU_TITLE @"SAKR"
#define SKY_BLUE [UIColor colorWithRed:0.00 green:0.75 blue:1.00 alpha:1.0]

// --- متغيرات التحكم (Global Variables) ---
bool esp_box = false, esp_skeleton = false, esp_line = false;
float esp_dist = 100.0f;
bool magic_bullet = false, aimbot_smart = false;
int combat_target = 0; // 0 = Head, 1 = Body
float fov_size = 150.0f;
float player_speed = 1.0f, car_speed = 1.0f;

// --- بناء المنيو ---
- (void)setupMenu {
    // إعدادات الأيقونة والاسم
    [Menu setIcon:@"SAKR" color:SKY_BLUE]; 
    [Menu setTitle:MENU_TITLE color:SKY_BLUE];
    [Menu setBackgroundColor:[UIColor blackColor]];

    // 1️⃣ خانة الكشف (ESP)
    [Menu addTabBar:@"ESP" icons:nil];
    [Menu addSwitch:@"ESP Box" description:@"تفعيل المربع" ✅:^void(bool val) { esp_box = val; }];
    [Menu addSwitch:@"ESP Skeleton" description:@"تفعيل الهيكل" ✅:^void(bool val) { esp_skeleton = val; }];
    [Menu addSwitch:@"ESP Line" description:@"خطوط اللاعبين" ✅:^void(bool val) { esp_line = val; }];
    [Menu addSlider:@"Distance" min:50 max:500 default:100 description:@"مسافة الكشف" ✅:^void(float val) { esp_dist = val; }];

    // 2️⃣ خانة السرعة (Speed)
    [Menu addTabBar:@"Speed" icons:nil];
    [Menu addSlider:@"Player Speed" min:1 max:10 default:1 description:@"سرعة اللاعب فقط" ✅:^void(float val) { player_speed = val; }];
    [Menu addSlider:@"Car Speed" min:1 max:20 default:1 description:@"سرعة السيارة فقط" ✅:^void(float val) { car_speed = val; }];

    // 3️⃣ خانة القتال (Combat)
    [Menu addTabBar:@"Combat" icons:nil];
    [Menu addSwitch:@"Magic Bullet" description:@"طلقة سحرية (جدران)" ✅:^void(bool val) { magic_bullet = val; }];
    [Menu addSwitch:@"Smart Aimbot" description:@"إيمبوت ذكي (للمكشوفين)" ✅:^void(bool val) { aimbot_smart = val; }];
    [Menu addSegment:@"Target" options:@[@"Head", @"Body"] ✅:^void(int sel) { combat_target = sel; }];
    [Menu addSlider:@"FOV Size" min:100 max:300 default:150 description:@"دائرة التحكم" ✅:^void(float val) { fov_size = val; }];

    // 4️⃣ خانة المهام (Auto Farm)
    [Menu addTabBar:@"Missions" icons:nil];
    [Menu addButton:@"Auto Rob Military" ✅:^void { /* كود سرقة الميناء */ }];
    [Menu addButton:@"Auto Work" ✅:^void { /* كود العمل الآلي */ }];

    // 5️⃣ خانة التنقل (Teleport)
    [Menu addTabBar:@"Teleport" icons:nil];
    [Menu addButton:@"Police Station" ✅:^void { /* Teleport logic */ }];
    [Menu addButton:@"Hospital" ✅:^void { /* Teleport logic */ }];
    [Menu addButton:@"Car Dealer" ✅:^void { /* Teleport logic */ }];
}
