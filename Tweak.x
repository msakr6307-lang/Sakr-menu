#import <UIKit/UIKit.h>

// --- المتغيرات ---
static bool autoMine = false;
static bool magicBullet = false;
static bool infiniteAmmo = true; // خليتها شغالة تلقائي لراحتك

UIWindow *sakrWindow;
UIView *sakrMenu;

// --- دالة المنيو ---
@interface SakrController : NSObject
-(void)toggleMenu;
@end

@implementation SakrController
-(void)toggleMenu {
    sakrMenu.hidden = !sakrMenu.hidden;
}
@end

static SakrController *controller;

// --- بناء الواجهة ---
void setupUI() {
    controller = [[SakrController alloc] init];
    
    // النافذة الأساسية
    sakrWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    sakrWindow.windowLevel = UIWindowLevelAlert + 1;
    sakrWindow.hidden = NO;
    [sakrWindow makeKeyAndVisible];
    sakrWindow.backgroundColor = [UIColor clearColor];

    // زرار الصقر العايم
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 200, 60, 60);
    btn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    btn.layer.cornerRadius = 30;
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = [UIColor whiteColor].CGColor;
    [btn setTitle:@"🦅" forState:UIControlStateNormal];
    [btn addTarget:controller action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [sakrWindow addSubview:btn];

    // المنيو السوداء
    sakrMenu = [[UIView alloc] initWithFrame:CGRectMake(100, 150, 220, 250)];
    sakrMenu.backgroundColor = [UIColor blackColor];
    sakrMenu.layer.cornerRadius = 10;
    sakrMenu.hidden = YES;
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 220, 30)];
    lbl.text = @"SAKR MOD - ONESTATE";
    lbl.textColor = [UIColor whiteColor];
    lbl.textAlignment = NSTextAlignmentCenter;
    [sakrMenu addSubview:lbl];
    
    // زرار تفعيل الطلق اللانهائي
    UIButton *ammoBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    ammoBtn.frame = CGRectMake(10, 60, 200, 40);
    [ammoBtn setTitle:@"طلق لانهائي: شغال ✅" forState:UIControlStateNormal];
    [sakrMenu addSubview:ammoBtn];

    [sakrWindow addSubview:sakrMenu];
}

// --- تشغيل الهاك ---
__attribute__((constructor))
static void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        setupUI();
    });
}

// كود الطلق اللانهائي المبسط
int (*old_getAmmo)();
int new_getAmmo() {
    return 999;
}
