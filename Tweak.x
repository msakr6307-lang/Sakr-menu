#import <UIKit/UIKit.h>

// --- مخزن الحالات ---
static bool hShot = NO, bShot = NO, mMagic = NO, showRadar = NO;
static UIView *mPanel = nil;
static UIButton *eIcon = nil;
static CAShapeLayer *radarCircle = nil;

@interface SakrFinalBoss : NSObject
@end

@implementation SakrFinalBoss

// نظام تحريك الأيقونة (إجباري)
+ (void)drag:(UIPanGestureRecognizer *)p {
    UIView *v = p.view;
    CGPoint t = [p translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [p setTranslation:CGPointZero inView:v.superview];
}

// تشغيل المميزات وتغيير لون الزرار
+ (void)fToggle:(UIButton *)b {
    if (b.tag == 1) { hShot = !hShot; bShot = NO; }
    else if (b.tag == 2) { bShot = !bShot; hShot = NO; }
    else if (b.tag == 5) mMagic = !mMagic;
    else if (b.tag == 101) { 
        showRadar = !showRadar; 
        if (radarCircle) radarCircle.opacity = showRadar ? 1.0 : 0; 
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        b.backgroundColor = (b.backgroundColor == [UIColor clearColor]) ? 
        [UIColor colorWithRed:0 green:0.8 blue:0.8 alpha:0.8] : [UIColor clearColor];
    }];
}

+ (void)sh { [UIView animateWithDuration:0.3 animations:^{ mPanel.alpha = (mPanel.alpha == 0) ? 1 : 0; }]; }

+ (void)addB:(NSString *)t y:(CGFloat)y tag:(int)tag p:(UIView *)p {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.frame = CGRectMake(10, y, 330, 45);
    b.backgroundColor = [UIColor clearColor];
    b.layer.cornerRadius = 10; b.layer.borderWidth = 1; b.layer.borderColor = [UIColor cyanColor].CGColor;
    b.tag = tag; [b setTitle:t forState:UIControlStateNormal];
    b.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [b addTarget:self action:@selector(fToggle:) forControlEvents:UIControlEventTouchUpInside];
    [p addSubview:b];
}
@end

// --- الهوكات (القتل والدمج) ---
%hook PlayerController
-(void)takeDamage:(float)d isHead:(BOOL)h {
    if (hShot) %orig(999, YES); 
    else if (bShot) %orig(999, NO);
    else %orig(d, h);
}
%end

// --- تشغيل المنيو (حل مشكلة Deprecated اللي في الصورة) ---
__attribute__((constructor))
static void start() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = nil;
        for (UIWindowScene* scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                win = scene.windows.firstObject; break;
            }
        }
        if(!win) return;

        // رسم الدائرة
        radarCircle = [CAShapeLayer layer];
        radarCircle.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(win.frame.size.width/2, win.frame.size.height/2) radius:150 startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
        radarCircle.strokeColor = [UIColor cyanColor].CGColor;
        radarCircle.fillColor = [UIColor clearColor].CGColor;
        radarCircle.lineWidth = 2; radarCircle.opacity = 0;
        [win.layer addSublayer:radarCircle];

        // النسر العائم
        eIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        eIcon.frame = CGRectMake(100, 100, 65, 65);
        [eIcon setTitle:@"🦅" forState:UIControlStateNormal];
        eIcon.backgroundColor = [UIColor colorWithRed:0 green:0.4 blue:0.4 alpha:0.8];
        eIcon.layer.cornerRadius = 32.5;
        [eIcon addTarget:[SakrFinalBoss class] action:@selector(sh) forControlEvents:UIControlEventTouchUpInside];
        [eIcon addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[SakrFinalBoss class] action:@selector(drag:)]];
        [win addSubview:eIcon];

        // القائمة
        mPanel = [[UIView alloc] initWithFrame:CGRectMake(win.frame.size.width/2-175, win.frame.size.height/2-125, 350, 250)];
        mPanel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.1 alpha:0.95];
        mPanel.layer.cornerRadius = 20; mPanel.layer.borderWidth = 2; mPanel.layer.borderColor = [UIColor cyanColor].CGColor;
        mPanel.alpha = 0; [win addSubview:mPanel];

        [SakrFinalBoss addB:@"AIM HEADSHOT 🎯" y:15 tag:1 p:mPanel];
        [SakrFinalBoss addB:@"AIM CHEST/BODY 👕" y:70 tag:2 p:mPanel];
        [SakrFinalBoss addB:@"MAGIC BULLET ✨" y:125 tag:5 p:mPanel];
        [SakrFinalBoss addB:@"SHOW RADAR CIRCLE ⭕" y:180 tag:101 p:mPanel];
    });
}
