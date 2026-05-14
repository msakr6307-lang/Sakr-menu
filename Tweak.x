#import <UIKit/UIKit.h>

// --- الترسانة البرمجية الشاملة ---
static bool hShot = NO, bShot = NO, wBang = NO, infA = NO;
static bool espB = NO, espS = NO, espL = NO;
static bool aMine = NO, aDeliv = NO, aLoot = NO, pLoot = NO;
static float espDist = 150.0f;

static UIView *mPanel = nil;
static UIButton *eIcon = nil;
static UIView *vC = nil, *vV = nil, *vJ = nil, *vL = nil;
static UILabel *dLab = nil;

@interface MustafaFinalElite : NSObject
+ (void)tSwitch:(UIButton *)s;
+ (void)fToggle:(UIButton *)b;
+ (void)sSlide:(UISlider *)s;
+ (void)sh;
+ (void)addB:(NSString *)t y:(CGFloat)y tag:(int)tag p:(UIView *)p;
@end

@implementation MustafaFinalElite

// تحريك أيقونة الصقر بسلاسة
+ (void)drag:(UIPanGestureRecognizer *)p {
    CGPoint t = [p translationInView:eIcon.superview];
    eIcon.center = CGPointMake(eIcon.center.x + t.x, eIcon.center.y + t.y);
    [p setTranslation:CGPointZero inView:eIcon.superview];
}

// التبديل الفوري بين الخانات (تأكدنا من ظهور Jobs و Loot)
+ (void)tSwitch:(UIButton *)s {
    vC.hidden = YES; vV.hidden = YES; vJ.hidden = YES; vL.hidden = YES;
    if (s.tag == 10) vC.hidden = NO;
    else if (s.tag == 20) vV.hidden = NO;
    else if (s.tag == 30) vJ.hidden = NO;
    else if (s.tag == 40) vL.hidden = NO;
}

// تفعيل الميزات مع تأثير بصري (تغيير اللون)
+ (void)fToggle:(UIButton *)b {
    // ربط الأزرار بالمتغيرات
    if (b.tag == 1) { hShot = !hShot; bShot = NO; }
    else if (b.tag == 2) { bShot = !bShot; hShot = NO; }
    else if (b.tag == 3) wBang = !wBang;
    else if (b.tag == 4) infA = !infA;
    else if (b.tag == 101) espB = !espB;
    else if (b.tag == 102) espS = !espS;
    else if (b.tag == 103) espL = !espL;
    else if (b.tag == 301) aMine = !aMine;
    else if (b.tag == 302) aDeliv = !aDeliv;
    else if (b.tag == 401) aLoot = !aLoot;
    else if (b.tag == 402) pLoot = !pLoot;

    // تغيير شكل الزرار عند التفعيل
    if (b.backgroundColor == [UIColor colorWithWhite:0.1 alpha:0.8]) {
        b.backgroundColor = [UIColor colorWithRed:0 green:0.6 blue:0.6 alpha:0.8]; // سيان مضيء
        b.layer.borderColor = [UIColor cyanColor].CGColor;
    } else {
        b.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
        b.layer.borderColor = [UIColor grayColor].CGColor;
    }
}

+ (void)sSlide:(UISlider *)s {
    espDist = s.value;
    dLab.text = [NSString stringWithFormat:@"ESP Distance: %.0fM", espDist];
}

+ (void)sh { [UIView animateWithDuration:0.3 animations:^{ mPanel.alpha = (mPanel.alpha == 0) ? 1 : 0; }]; }

// دالة بناء الأزرار (تم تعديل المسافات لتناسب الشاشة)
+ (void)addB:(NSString *)t y:(CGFloat)y tag:(int)tag p:(UIView *)p {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.frame = CGRectMake(10, y, 360, 42);
    b.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
    b.layer.cornerRadius = 8; b.layer.borderWidth = 1; b.layer.borderColor = [UIColor grayColor].CGColor;
    b.tag = tag; [b setTitle:t forState:UIControlStateNormal];
    b.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [b addTarget:self action:@selector(fToggle:) forControlEvents:UIControlEventTouchUpInside];
    [p addSubview:b];
}
@end

__attribute__((constructor))
static void loadMustafaSupreme() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        if (!win) return;

        // القائمة الرئيسية
        mPanel = [[UIView alloc] initWithFrame:CGRectMake(win.frame.size.width/2-270, win.frame.size.height/2-165, 540, 330)];
        mPanel.backgroundColor = [UIColor colorWithRed:0.01 green:0.04 blue:0.05 alpha:0.96];
        mPanel.layer.cornerRadius = 20; mPanel.layer.borderColor = [UIColor cyanColor].CGColor;
        mPanel.layer.borderWidth = 2.0; mPanel.alpha = 0;
        [win addSubview:mPanel];

        UILabel *idL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 540, 45)];
        idL.text = @"   🦅 MUSTAFA SPECIAL | THE SUPREME V5.0";
        idL.textColor = [UIColor cyanColor]; idL.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        [mPanel addSubview:idL];

        // التبويبات (Tabs)
        NSArray *tabs = @[@"COMBAT", @"VISUALS", @"JOBS", @"LOOT"];
        for(int i=0; i<4; i++){
            UIButton *tb = [UIButton buttonWithType:UIButtonTypeCustom];
            tb.frame = CGRectMake(0, i*65+60, 130, 60);
            [tb setTitle:tabs[i] forState:UIControlStateNormal]; tb.tag = (i+1)*10;
            [tb addTarget:[MustafaFinalElite class] action:@selector(tSwitch:) forControlEvents:UIControlEventTouchUpInside];
            [mPanel addSubview:tb];
        }

        // الحاويات (ضمان وجودها جميعاً)
        vC = [[UIView alloc] initWithFrame:CGRectMake(140, 60, 380, 260)]; [mPanel addSubview:vC];
        vV = [[UIView alloc] initWithFrame:CGRectMake(140, 60, 380, 260)]; vV.hidden = YES; [mPanel addSubview:vV];
        vJ = [[UIView alloc] initWithFrame:CGRectMake(140, 60, 380, 260)]; vJ.hidden = YES; [mPanel addSubview:vJ];
        vL = [[UIView alloc] initWithFrame:CGRectMake(140, 60, 380, 260)]; vL.hidden = YES; [mPanel addSubview:vL];

        // 1. قسم COMBAT
        [MustafaFinalElite addB:@"SMART HEADSHOT 🎯" y:0 tag:1 p:vC];
        [MustafaFinalElite addB:@"SMART BODYSHOT 👕" y:50 tag:2 p:vC];
        [MustafaFinalElite addB:@"WALLBANG 🔥" y:100 tag:3 p:vC];
        [MustafaFinalElite addB:@"INFINITE AMMO 🔫" y:150 tag:4 p:vC];

        // 2. قسم VISUALS
        [MustafaFinalElite addB:@"ESP BOX" y:0 tag:101 p:vV];
        [MustafaFinalElite addB:@"ESP SKELETON" y:45 tag:102 p:vV];
        [MustafaFinalElite addB:@"ESP LINES" y:90 tag:103 p:vV];
        dLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 145, 350, 25)];
        dLab.text = @"ESP Distance: 150M"; dLab.textColor = [UIColor whiteColor]; [vV addSubview:dLab];
        UISlider *sd = [[UISlider alloc] initWithFrame:CGRectMake(15, 175, 350, 30)];
        sd.minimumValue = 50; sd.maximumValue = 300; sd.value = 150;
        [sd addTarget:[MustafaFinalElite class] action:@selector(sSlide:) forControlEvents:UIControlEventValueChanged];
        [vV addSubview:sd];

        // 3. قسم JOBS (مملوء الآن)
        [MustafaFinalElite addB:@"AUTO MINER ⛏️" y:0 tag:301 p:vJ];
        [MustafaFinalElite addB:@"AUTO DELIVERY 📦" y:50 tag:302 p:vJ];

        // 4. قسم LOOT (مملوء الآن)
        [MustafaFinalElite addB:@"ARMY BASE LOOT 🎖️" y:0 tag:401 p:vL];
        [MustafaFinalElite addB:@"PORT CARGO LOOT 🚢" y:50 tag:402 p:vL];

        // أيقونة الصقر
        eIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        eIcon.frame = CGRectMake(50, 150, 65, 65);
        [eIcon setTitle:@"🦅" forState:UIControlStateNormal];
        eIcon.backgroundColor = [UIColor colorWithRed:0 green:0.2 blue:0.2 alpha:0.6];
        eIcon.layer.cornerRadius = 32.5; eIcon.layer.borderWidth = 2; eIcon.layer.borderColor = [UIColor cyanColor].CGColor;
        [eIcon addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[MustafaFinalElite class] action:@selector(drag:)]];
        [eIcon addTarget:[MustafaFinalElite class] action:@selector(sh) forControlEvents:UIControlEventTouchUpInside];
        [win addSubview:eIcon];
    });
}
