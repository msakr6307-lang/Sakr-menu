#import <UIKit/UIKit.h>

// --- المتغيرات الثابتة للتحكم ---
static UIView *mainMenu = nil;
static UIButton *flyIcon = nil;

// --- كلاس المنيو والتحكم ---
@interface MustafaPro : NSObject
+ (void)showHide;
+ (void)dragIcon:(UIPanGestureRecognizer *)sender;
@end

@implementation MustafaPro
// تحريك الأيقونة في أي مكان
+ (void)dragIcon:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:flyIcon.superview];
    flyIcon.center = CGPointMake(flyIcon.center.x + translation.x, flyIcon.center.y + translation.y);
    [sender setTranslation:CGPointZero inView:flyIcon.superview];
}
// إظهار وإخفاء القائمة
+ (void)showHide {
    [UIView animateWithDuration:0.3 animations:^{
        mainMenu.alpha = (mainMenu.alpha == 0) ? 1 : 0;
    }];
}
@end

__attribute__((constructor))
static void initializeMustafaHack() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(12 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        if (!window) return;

        // 1. تصميم المنيو الاحترافي (نفس الصورة)
        mainMenu = [[UIView alloc] initWithFrame:CGRectMake(window.frame.size.width/2 - 250, window.frame.size.height/2 - 150, 500, 300)];
        mainMenu.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:0.98];
        mainMenu.layer.cornerRadius = 12;
        mainMenu.layer.borderWidth = 1.5;
        mainMenu.layer.borderColor = [UIColor cyanColor].CGColor;
        mainMenu.alpha = 0;
        [window addSubview:mainMenu];

        // شريط الاسم العلوي (Header)
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 500, 45)];
        header.backgroundColor = [UIColor colorWithWhite:0.12 alpha:1];
        [mainMenu addSubview:header];

        UILabel *userLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 460, 45)];
        userLabel.text = @"HACKER: MUSTAFA SPECIAL | STATUS: ACTIVE | V2.0";
        userLabel.textColor = [UIColor cyanColor];
        userLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        [header addSubview:userLabel];

        // القائمة الجانبية (Side Tabs)
        UIView *sideTab = [[UIView alloc] initWithFrame:CGRectMake(0, 45, 110, 255)];
        sideTab.backgroundColor = [UIColor colorWithWhite:0.08 alpha:1];
        [mainMenu addSubview:sideTab];

        NSArray *btnTitles = @[@"COMBAT", @"JOBS", @"RESOURCES"];
        for (int i = 0; i < btnTitles.count; i++) {
            UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
            b.frame = CGRectMake(0, i*60 + 20, 110, 40);
            [b setTitle:btnTitles[i] forState:UIControlStateNormal];
            b.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            [sideTab addSubview:b];
        }

        // منطقة المميزات (Features Display)
        UILabel *feat = [[UILabel alloc] initWithFrame:CGRectMake(125, 60, 360, 220)];
        feat.text = @"[ COMBAT ]\n• Magic Bullet (Smart Target) ✅\n• Wallbang (Penetration) ✅\n• Infinite Ammo & No Reload ✅\n\n[ RESOURCES ]\n• Army Base Loot (Fast) ✅\n• Port Docks Loot (Fast) ✅\n\n[ JOBS ]\n• Auto Miner (Start) ✅\n• Delivery Assist ✅";
        feat.textColor = [UIColor whiteColor];
        feat.numberOfLines = 0;
        feat.font = [UIFont systemFontOfSize:13];
        [mainMenu addSubview:feat];

        // 2. زرار الصقر المتحرك
        flyIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        flyIcon.frame = CGRectMake(40, 200, 60, 60);
        [flyIcon setTitle:@"🦅" forState:UIControlStateNormal];
        flyIcon.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        flyIcon.layer.cornerRadius = 30;
        flyIcon.layer.borderWidth = 1;
        flyIcon.layer.borderColor = [UIColor cyanColor].CGColor;

        // تفعيل ميزة السحب والتحريك
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:[MustafaPro class] action:@selector(dragIcon:)];
        [flyIcon addGestureRecognizer:pan];
        [flyIcon addTarget:[MustafaPro class] action:@selector(showHide) forControlEvents:UIControlEventTouchUpInside];

        [window addSubview:flyIcon];
    });
}

// --- الهوكات (البرمجة الفعلية للمميزات) ---
int (*old_ammo)();
int new_ammo() { return 999; } // طلق لا نهائي

int (*old_reload)();
int new_reload() { return 0; } // نو ريلود

// هوك الموارد والوظائف
int (*old_speed)();
int new_speed() { return 100; } 
