#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

// --- مخزن الحالات ---
static bool hShot = NO, bShot = NO, mMagic = NO, infA = NO;
static bool espB = NO, espS = NO, espL = NO, espD = NO, espH = NO;
static bool aMine = NO, aDeliv = NO, aLoot = NO, cLoot = NO;
static bool showRadar = NO;

static UIView *mPanel = nil;
static UIButton *eIcon = nil;
static UIView *vC = nil, *vV = nil, *vJ = nil, *vL = nil;
static CAShapeLayer *radarCircle = nil;

@interface SakrFinal : NSObject
@end

@implementation SakrFinal

// تحريك النسر
+ (void)handleDrag:(UIPanGestureRecognizer *)p {
    UIView *v = p.view;
    CGPoint t = [p translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [p setTranslation:CGPointZero inView:v.superview];
}

// تفعيل المميزات وتغيير الألوان
+ (void)fToggle:(UIButton *)b {
    switch (b.tag) {
        case 1: hShot = !hShot; bShot = NO; break;
        case 2: bShot = !bShot; hShot = NO; break;
        case 5: mMagic = !mMagic; break;
        case 4: infA = !infA; break;
        case 101: showRadar = !showRadar; [self updateRadar]; break;
        case 111: espB = !espB; break;
        case 301: aMine = !aMine; break;
        case 401: aLoot = !aLoot; break;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        if (b.backgroundColor == [UIColor colorWithWhite:0.1 alpha:0.8]) {
            b.backgroundColor = [UIColor colorWithRed:0 green:0.7 blue:0.7 alpha:0.9];
            b.layer.borderColor = [UIColor whiteColor].CGColor;
        } else {
            b.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
            b.layer.borderColor = [UIColor clearColor].CGColor;
        }
    }];
}

+ (void)updateRadar {
    if (radarCircle) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        radarCircle.opacity = showRadar ? 1.0 : 0;
        [CATransaction commit];
    }
}

+ (void)tSwitch:(UIButton *)s {
    vC.hidden = vV.hidden = vJ.hidden = vL.hidden = YES;
    if (s.tag == 10) vC.hidden = NO;
    else if (s.tag == 20) vV.hidden = NO;
    else if (s.tag == 30) vJ.hidden = NO;
    else if (s.tag == 40) vL.hidden = NO;
}

+ (void)sh { [UIView animateWithDuration:0.3 animations:^{ mPanel.alpha = (mPanel.alpha == 0) ? 1 : 0; }]; }

+ (void)addB:(NSString *)t y:(CGFloat)y tag:(int)tag p:(UIView *)p {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.frame = CGRectMake(10, y, 360, 42);
    b.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
    b.layer.cornerRadius = 8; b.tag = tag;
    [b setTitle:t forState:UIControlStateNormal];
    b.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [b addTarget:self action:@selector(fToggle:) forControlEvents:UIControlEventTouchUpInside];
    [p addSubview:b];
}
@end

// --- الهوكات (الرصاص والدمج) ---
%hook WeaponSystem
-(int)currentAmmo { return infA ? 999 : %orig; }
%end

%hook PlayerController
-(void)takeDamage:(float)d isHead:(BOOL)h {
    if (hShot) %orig(999, YES); 
    else if (bShot) %orig(999, NO);
    else %orig(d, h);
}
%end

// --- بناء المنيو ---
__attribute__((constructor))
static void buildMenu() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        if (!win) return;

        // الرادار (الدائرة)
        radarCircle = [CAShapeLayer layer];
        radarCircle.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(win.frame.size.width/2, win.frame.size.height/2) radius:150 startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
        radarCircle.strokeColor = [UIColor cyanColor].CGColor;
        radarCircle.fillColor = [UIColor clearColor].CGColor;
        radarCircle.lineWidth = 2; radarCircle.opacity = 0;
        [win.layer addSublayer:radarCircle];

        // النسر العائم
        eIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        eIcon.frame = CGRectMake(80, 80, 65, 65);
        [eIcon setTitle:@"🦅" forState:UIControlStateNormal];
        eIcon.backgroundColor = [UIColor colorWithRed:0 green:0.5 blue:0.5 alpha:0.7];
        eIcon.layer.cornerRadius = 32.5;
        [eIcon addTarget:[SakrFinal class] action:@selector(sh) forControlEvents:UIControlEventTouchUpInside];
        [eIcon addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[SakrFinal class] action:@selector(handleDrag:)]];
        [win addSubview:eIcon];

        // اللوحة
        mPanel = [[UIView alloc] initWithFrame:CGRectMake(win.frame.size.width/2-270, win.frame.size.height/2-165, 540, 330)];
        mPanel.backgroundColor = [UIColor colorWithRed:0.01 green:0.01 blue:0.05 alpha:0.98];
        mPanel.layer.cornerRadius = 15; mPanel.layer.borderColor = [UIColor cyanColor].CGColor; mPanel.layer.borderWidth = 2;
        mPanel.alpha = 0; [win addSubview:mPanel];

        // التبويبات
        NSArray *tabs = @[@"COMBAT", @"VISUALS", @"JOBS", @"LOOT"];
        for(int i=0; i<4; i++){
            UIButton *tb = [UIButton buttonWithType:UIButtonTypeCustom];
            tb.frame = CGRectMake(10, i*60+60, 120, 50);
            [tb setTitle:tabs[i] forState:UIControlStateNormal]; tb.tag = (i+1)*10;
            [tb addTarget:[SakrFinal class] action:@selector(tSwitch:) forControlEvents:UIControlEventTouchUpInside];
            [mPanel addSubview:tb];
        }

        vC = [[UIView alloc] initWithFrame:CGRectMake(140, 60, 380, 260)]; [mPanel addSubview:vC];
        vV = [[UIView alloc] initWithFrame:CGRectMake(140, 60, 380, 260)]; vV.hidden = YES; [mPanel addSubview:vV];
        vJ = [[UIView alloc] initWithFrame:CGRectMake(140, 60, 380, 260)]; vJ.hidden = YES; [mPanel addSubview:vJ];
        vL = [[UIView alloc] initWithFrame:CGRectMake(140, 60, 380, 260)]; vL.hidden = YES; [mPanel addSubview:vL];

        // إضافة المميزات
        [SakrFinal addB:@"AIM HEADSHOT 🎯" y:5 tag:1 p:vC];
        [SakrFinal addB:@"AIM CHEST/BODY 👕" y:55 tag:2 p:vC];
        [SakrFinal addB:@"MAGIC BULLET ✨" y:105 tag:5 p:vC];
        [SakrFinal addB:@"INFINITE AMMO 🔫" y:155 tag:4 p:vC];

        [SakrFinal addB:@"SHOW RADAR CIRCLE ⭕" y:5 tag:101 p:vV];
        [SakrFinal addB:@"ESP BOX" y:55 tag:111 p:vV];

        [SakrFinal addB:@"AUTO MINER ⛏️" y:5 tag:301 p:vJ];
        [SakrFinal addB:@"ARMY BASE LOOT 🎖️" y:5 tag:401 p:vL];
    });
}
