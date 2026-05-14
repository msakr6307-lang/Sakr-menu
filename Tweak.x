#import <UIKit/UIKit.h>

// --- حالة الميزات ---
static bool hShot = NO, bShot = NO, wBang = NO, infA = NO;
static bool espB = NO, espS = NO, espL = NO;
static bool aMine = NO, aDeliv = NO, aLoot = NO, pLoot = NO;
static float espDist = 150.0f;

static UIView *mPanel = nil;
static UIButton *eIcon = nil;
static UIView *vC = nil, *vV = nil, *vJ = nil, *vL = nil;
static UILabel *dLab = nil;

@interface MustafaSupremeFinal : NSObject
+ (void)tSwitch:(UIButton *)s;
+ (void)fToggle:(UIButton *)b;
+ (void)sSlide:(UISlider *)s;
+ (void)sh;
@end

@implementation MustafaSupremeFinal

+ (void)drag:(UIPanGestureRecognizer *)p {
    CGPoint t = [p translationInView:eIcon.superview];
    eIcon.center = CGPointMake(eIcon.center.x + t.x, eIcon.center.y + t.y);
    [p setTranslation:CGPointZero inView:eIcon.superview];
}

+ (void)tSwitch:(UIButton *)s {
    // إخفاء الكل وإظهار المختار فوراً
    vC.hidden = vV.hidden = vJ.hidden = vL.hidden = YES;
    if (s.tag == 10) vC.hidden = NO;
    else if (s.tag == 20) vV.hidden = NO;
    else if (s.tag == 30) vJ.hidden = NO;
    else if (s.tag == 40) vL.hidden = NO;
}

+ (void)fToggle:(UIButton *)b {
    // تنفيذ الأمر بناءً على الـ Tag
    switch (b.tag) {
        case 1: hShot = !hShot; bShot = NO; break;
        case 2: bShot = !bShot; hShot = NO; break;
        case 3: wBang = !wBang; break;
        case 4: infA = !infA; break;
        case 101: espB = !espB; break;
        case 102: espS = !espS; break;
        case 103: espL = !espL; break;
        case 301: aMine = !aMine; break;
        case 302: aDeliv = !aDeliv; break;
        case 401: aLoot = !aLoot; break;
        case 402: pLoot = !pLoot; break;
    }

    // تأثير التفاعل البصري الفوري (التوهج السيان)
    if (b.backgroundColor == [UIColor colorWithWhite:0.1 alpha:0.8]) {
        b.backgroundColor = [UIColor colorWithRed:0 green:0.6 blue:0.6 alpha:0.8];
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

// دالة البناء المستقرة
+ (void)addBtn:(NSString *)t y:(CGFloat)y tag:(int)tag p:(UIView *)p {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.frame = CGRectMake(10, y, 360, 42);
    b.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
    b.layer.cornerRadius = 8; b.layer.borderWidth = 1;
    b.layer.borderColor = [UIColor grayColor].CGColor;
    b.tag = tag; [b setTitle:t forState:UIControlStateNormal];
    b.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [b addTarget:self action:@selector(fToggle:) forControlEvents:UIControlEventTouchUpInside];
    [p addSubview:b];
}
@end

__attribute__((constructor))
static void startFinalSupreme() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        if (!win) return;

        mPanel = [[UIView alloc] initWithFrame:CGRectMake(win.frame.size.width/2-270, win.frame.size.height/2-165, 540, 330)];
        mPanel.backgroundColor = [UIColor colorWithRed:0.01 green:0.04 blue:0.05 alpha:0.96];
        mPanel.layer.cornerRadius = 20; mPanel.layer.borderColor = [UIColor cyanColor].CGColor;
        mPanel.layer.borderWidth = 2.0; mPanel.alpha = 0;
        [win addSubview:mPanel];

        UILabel *idL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 540, 45)];
        idL.text = @"   🦅 MUSTAFA SPECIAL | THE SUPREME V5.0";
        idL.textColor = [UIColor cyanColor]; idL.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        [mPanel addSubview:idL];

        // التبويبات
        NSArray *tabs = @[@"COMBAT", @"VISUALS", @"JOBS", @"LOOT"];
        for(int i=0; i<4; i++){
            UIButton *tb = [UIButton buttonWithType:UIButtonTypeCustom];
            tb.frame = CGRectMake(0, i*65+60, 130, 60);
            [tb setTitle:tabs[i] forState:UIControlStateNormal]; tb.tag = (i+1)*10;
            [tb addTarget:[MustafaSupremeFinal class] action:@selector(tSwitch:) forControlEvents:UIControlEventTouchUpInside];
            [mPanel addSubview:tb];
        }

        // إنشاء الحاويات فوراً
        vC = [[UIView alloc] initWithFrame:CGRectMake(140, 60, 380, 260)]; [mPanel addSubview:vC];
        vV = [[UIView alloc] initWithFrame:CGRectMake(140, 60, 380, 260)]; vV.hidden = YES; [mPanel addSubview:vV];
        vJ = [[UIView alloc] initWithFrame:CGRectMake(140, 60, 380, 260)]; vJ.hidden = YES; [mPanel addSubview:vJ];
        vL = [[UIView alloc] initWithFrame:CGRectMake(140, 60, 380, 260)]; vL.hidden = YES; [mPanel addSubview:vL];

        // ملء COMBAT
        [MustafaSupremeFinal addBtn:@"SMART HEADSHOT 🎯" y:0 tag:1 p:vC];
        [MustafaSupremeFinal addBtn:@"SMART BODYSHOT 👕" y:50 tag:2 p:vC];
        [MustafaSupremeFinal addBtn:@"WALLBANG (FIRE) 🔥" y:100 tag:3 p:vC];
        [MustafaSupremeFinal addBtn:@"INFINITE AMMO 🔫" y:150 tag:4 p:vC];

        // ملء VISUALS
        [MustafaSupremeFinal addBtn:@"ESP BOX [BOX]" y:0 tag:101 p:vV];
        [MustafaSupremeFinal addBtn:@"ESP SKELETON" y:45 tag:102 p:vV];
        [MustafaSupremeFinal addBtn:@"ESP LINES" y:90 tag:103 p:vV];
        dLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 145, 350, 25)];
        dLab.text = @"ESP Distance: 150M"; dLab.textColor = [UIColor cyanColor]; [vV addSubview:dLab];
        UISlider *sd = [[UISlider alloc] initWithFrame:CGRectMake(15, 175, 350, 30)];
        sd.minimumValue = 50; sd.maximumValue = 300; sd.value = 150;
        [sd addTarget:[MustafaSupremeFinal class] action:@selector(sSlide:) forControlEvents:UIControlEventValueChanged];
        [vV addSubview:sd];

        // ملء JOBS
        [MustafaSupremeFinal addBtn:@"AUTO MINER ⛏️" y:0 tag:301 p:vJ];
        [MustafaSupremeFinal addBtn:@"AUTO DELIVERY 📦" y:50 tag:302 p:vJ];

        // ملء LOOT
        [MustafaSupremeFinal addBtn:@"ARMY BASE LOOT 🎖️" y:0 tag:401 p:vL];
        [MustafaSupremeFinal addBtn:@"PORT CARGO LOOT 🚢" y:50 tag:402 p:vL];

        // الأيقونة
        eIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        eIcon.frame = CGRectMake(50, 150, 65, 65);
        [eIcon setTitle:@"🦅" forState:UIControlStateNormal];
        eIcon.backgroundColor = [UIColor colorWithRed:0 green:0.2 blue:0.2 alpha:0.6];
        eIcon.layer.cornerRadius = 32.5; eIcon.layer.borderWidth = 2; eIcon.layer.borderColor = [UIColor cyanColor].CGColor;
        [eIcon addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[MustafaSupremeFinal class] action:@selector(drag:)]];
        [eIcon addTarget:[MustafaSupremeFinal class] action:@selector(sh) forControlEvents:UIControlEventTouchUpInside];
        [win addSubview:eIcon];
    });
}
