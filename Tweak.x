#import <UIKit/UIKit.h>

// --- متغيرات التحكم ---
static BOOL infAmmo = NO;
static BOOL fastJob = NO;
static BOOL stealthPort = NO;
static BOOL unlockMil = NO;

// واجهة المستخدم
static UIView *mainMenu = nil;
static UIButton *icon = nil;
static UIView *v1 = nil; static UIView *v2 = nil;
static UIView *v3 = nil; static UIView *v4 = nil;

@interface M_Manager : NSObject
@end

@implementation M_Manager
// تحريك الأيقونة
+ (void)drag:(UIPanGestureRecognizer *)p {
    UIView *v = p.view;
    CGPoint t = [p translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [p setTranslation:CGPointZero inView:v.superview];
}
// إظهار/إخفاء
+ (void)show {
    [UIView animateWithDuration:0.3 animations:^{ mainMenu.alpha = (mainMenu.alpha == 0) ? 1.0 : 0; }];
}
// التبديل بين الأقسام
+ (void)tab:(UIButton *)b {
    v1.hidden = (b.tag != 100); v2.hidden = (b.tag != 10);
    v3.hidden = (b.tag != 20); v4.hidden = (b.tag != 30);
}
// تفعيل وقفل الميزة
+ (void)sw:(UIButton *)b {
    if (b.tag == 7) infAmmo = !infAmmo;
    if (b.tag == 1) fastJob = !fastJob;
    if (b.tag == 4) stealthPort = !stealthPort;
    if (b.tag == 5) unlockMil = !unlockMil;
    
    b.backgroundColor = (b.backgroundColor == [UIColor clearColor]) ? 
    [UIColor colorWithRed:0 green:0.8 blue:0.4 alpha:0.6] : [UIColor clearColor];
}
@end

// --- الهوكات الشغالة 100% ---
%hook WeaponController
-(void)consumeAmmo:(int)a { if (!infAmmo) %orig; }
%end

%hook JobSystem
-(float)cooldownTime { return fastJob ? 0.0f : %orig; }
%end

%hook PortSystem
-(BOOL)isAlarmActive { return stealthPort ? NO : %orig; }
%end

%hook MilitaryBase
-(BOOL)isLocked { return unlockMil ? NO : %orig; }
%end

// --- بناء المنيو بطريقة آمنة ---
__attribute__((constructor))
static void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // الوصول للويندو بأمان لتجنب Error 1
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        if (!win && [UIApplication sharedApplication].windows.count > 0) 
            win = [UIApplication sharedApplication].windows.firstObject;
        if (!win) return;

        // الأيقونة العائمة
        icon = [UIButton buttonWithType:UIButtonTypeCustom];
        icon.frame = CGRectMake(100, 100, 50, 50);
        [icon setTitle:@"💀" forState:UIControlStateNormal];
        icon.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        icon.layer.cornerRadius = 25; icon.layer.borderWidth = 1; icon.layer.borderColor = [UIColor greenColor].CGColor;
        [icon addTarget:[M_Manager class] action:@selector(show) forControlEvents:UIControlEventTouchUpInside];
        [icon addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[M_Manager class] action:@selector(drag:)]];
        [win addSubview:icon];

        // المنيو الرئيسية
        mainMenu = [[UIView alloc] initWithFrame:CGRectMake(win.frame.size.width/2-140, win.frame.size.height/2-120, 280, 240)];
        mainMenu.backgroundColor = [UIColor colorWithRed:0.02 green:0.02 blue:0.02 alpha:0.98];
        mainMenu.layer.cornerRadius = 15; mainMenu.layer.borderWidth = 2; mainMenu.layer.borderColor = [UIColor greenColor].CGColor;
        mainMenu.alpha = 0; [win addSubview:mainMenu];

        // أزرار التابات (الخانات)
        NSArray *tabs = @[@"COMBAT", @"JOBS", @"PORT", @"MIL"];
        for(int i=0; i<4; i++){
            UIButton *t = [UIButton buttonWithType:UIButtonTypeCustom];
            t.frame = CGRectMake(5+(i*68), 40, 65, 30);
            t.backgroundColor = [UIColor darkGrayColor]; t.layer.cornerRadius = 4;
            t.titleLabel.font = [UIFont systemFontOfSize:9 weight:UIFontWeightBold];
            [t setTitle:tabs[i] forState:UIControlStateNormal];
            t.tag = (i==0) ? 100 : i*10;
            [t addTarget:[M_Manager class] action:@selector(tab:) forControlEvents:UIControlEventTouchUpInside];
            [mainMenu addSubview:t];
        }

        // إنشاء الخانات
        v1 = [[UIView alloc] initWithFrame:CGRectMake(10, 80, 260, 150)];
        v2 = [[UIView alloc] initWithFrame:CGRectMake(10, 80, 260, 150)]; v2.hidden = YES;
        v3 = [[UIView alloc] initWithFrame:CGRectMake(10, 80, 260, 150)]; v3.hidden = YES;
        v4 = [[UIView alloc] initWithFrame:CGRectMake(10, 80, 260, 150)]; v4.hidden = YES;
        [mainMenu addSubview:v1]; [mainMenu addSubview:v2]; [mainMenu addSubview:v3]; [mainMenu addSubview:v4];

        // الأزرار داخل الخانات
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn1.frame = CGRectMake(0, 30, 260, 45); btn1.tag = 7;
        [btn1 setTitle:@"INFINITE AMMO ♾️" forState:UIControlStateNormal];
        btn1.layer.borderWidth = 1; btn1.layer.borderColor = [UIColor greenColor].CGColor;
        [btn1 addTarget:[M_Manager class] action:@selector(sw:) forControlEvents:UIControlEventTouchUpInside];
        [v1 addSubview:btn1];

        UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn2.frame = CGRectMake(0, 30, 260, 45); btn2.tag = 1;
        [btn2 setTitle:@"FAST JOB NO COOLDOWN" forState:UIControlStateNormal];
        btn2.layer.borderWidth = 1; btn2.layer.borderColor = [UIColor greenColor].CGColor;
        [btn2 addTarget:[M_Manager class] action:@selector(sw:) forControlEvents:UIControlEventTouchUpInside];
        [v2 addSubview:btn2];

        UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn3.frame = CGRectMake(0, 30, 260, 45); btn3.tag = 4;
        [btn3 setTitle:@"STEALTH PORT ROBBERY" forState:UIControlStateNormal];
        btn3.layer.borderWidth = 1; btn3.layer.borderColor = [UIColor greenColor].CGColor;
        [btn3 addTarget:[M_Manager class] action:@selector(sw:) forControlEvents:UIControlEventTouchUpInside];
        [v3 addSubview:btn3];

        UIButton *btn4 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn4.frame = CGRectMake(0, 30, 260, 45); btn4.tag = 5;
        [btn4 setTitle:@"UNLOCK MILITARY GATES" forState:UIControlStateNormal];
        btn4.layer.borderWidth = 1; btn4.layer.borderColor = [UIColor greenColor].CGColor;
        [btn4 addTarget:[M_Manager class] action:@selector(sw:) forControlEvents:UIControlEventTouchUpInside];
        [v4 addSubview:btn4];
    });
}
