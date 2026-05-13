#import <UIKit/UIKit.h>

// --- تعريف المتغيرات ---
static bool autoMine = false;
static bool autoDelivery = false;
static bool magicBullet = false;
static bool infiniteAmmo = false;
static float fovSize = 100.0f;

UIWindow *mainWindow;
UIView *menuView;

// --- دالة إنشاء المنيو ---
void createMenu() {
    menuView = [[UIView alloc] initWithFrame:CGRectMake(50, 100, 250, 350)];
    menuView.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.95];
    menuView.layer.cornerRadius = 15;
    menuView.layer.borderWidth = 2;
    menuView.layer.borderColor = [UIColor redColor].CGColor;
    menuView.hidden = YES; // تبدأ مخفية
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 250, 30)];
    title.text = @"SAKR MENU - ONESTATE";
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    [menuView addSubview:title];

    // إضافة زرار (Switch) للمنجم التلقائي
    UISwitch *mineSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(20, 60, 0, 0)];
    [mineSwitch addTarget:mineSwitch action:@selector(toggleMine:) forControlEvents:UIControlEventValueChanged];
    [menuView addSubview:mineSwitch];
    
    UILabel *l1 = [[UILabel alloc] initWithFrame:CGRectMake(80, 60, 150, 30)];
    l1.text = @"عامل منجم تلقائي";
    l1.textColor = [UIColor whiteColor];
    [menuView addSubview:l1];

    // إضافة زرار للطلقة السحرية
    UISwitch *magicSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(20, 110, 0, 0)];
    [menuView addSubview:magicSwitch];
    
    UILabel *l2 = [[UILabel alloc] initWithFrame:CGRectMake(80, 110, 150, 30)];
    l2.text = @"طلقة سحرية (Magic)";
    l2.textColor = [UIColor whiteColor];
    [menuView addSubview:l2];

    [mainWindow addSubview:menuView];
}

// --- دالة إظهار/إخفاء المنيو ---
void toggleMenu() {
    menuView.hidden = !menuView.hidden;
}

// --- تشغيل كل حاجة عند فتح اللعبة ---
__attribute__((constructor))
static void initialize() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        mainWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        mainWindow.windowLevel = UIWindowLevelAlert + 1;
        mainWindow.hidden = NO;
        [mainWindow makeKeyAndVisible];
        mainWindow.backgroundColor = [UIColor clearColor];

        // زرار الصقر العايم
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20, 200, 60, 60);
        btn.backgroundColor = [UIColor darkGrayColor];
        btn.layer.cornerRadius = 30;
        [btn setTitle:@"🦅" forState:UIControlStateNormal];
        [btn addTarget:btn action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
        [mainWindow addSubview:btn];
        
        createMenu();
    });
}

// --- تطبيق منطق الهاك (الطلق اللانهائي) ---
int (*old_ammo)();
int new_ammo() {
    return 999; // طلق ما بيخلصش
}
