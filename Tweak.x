#import <UIKit/UIKit.h>

// --- متغيرات الحالة ---
static bool hShot = NO, bShot = NO, mMagic = NO, infA = NO;
static bool showRadar = NO;
static UIView *mPanel = nil;
static UIButton *eIcon = nil;
static UIView *vC = nil;
static CAShapeLayer *radarCircle = nil;

@interface SakrFinalMenu : NSObject
@end

@implementation SakrFinalMenu

+ (void)drag:(UIPanGestureRecognizer *)p {
    UIView *v = p.view;
    CGPoint t = [p translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [p setTranslation:CGPointZero inView:v.superview];
}

+ (void)fToggle:(UIButton *)b {
    if (b.tag == 1) { hShot = !hShot; bShot = NO; }
    else if (b.tag == 2) { bShot = !bShot; hShot = NO; }
    else if (b.tag == 101) { 
        showRadar = !showRadar; 
        if (radarCircle) radarCircle.opacity = showRadar ? 1.0 : 0; 
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        b.backgroundColor = (b.backgroundColor == [UIColor colorWithWhite:0.1 alpha:0.8]) ? 
        [UIColor colorWithRed:0 green:0.7 blue:0.7 alpha:0.9] : [UIColor colorWithWhite:0.1 alpha:0.8];
    }];
}

+ (void)sh { mPanel.alpha = (mPanel.alpha == 0) ? 1 : 0; }

+ (void)addB:(NSString *)t y:(CGFloat)y tag:(int)tag p:(UIView *)p {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.frame = CGRectMake(10, y, 360, 42);
    b.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
    b.layer.cornerRadius = 8; b.tag = tag;
    [b setTitle:t forState:UIControlStateNormal];
    [b addTarget:self action:@selector(fToggle:) forControlEvents:UIControlEventTouchUpInside];
    [p addSubview:b];
}
@end

// --- الهوكات ---
%hook PlayerController
-(void)takeDamage:(float)d isHead:(BOOL)h {
    if (hShot) %orig(999, YES); 
    else if (bShot) %orig(999, NO);
    else %orig(d, h);
}
%end

__attribute__((constructor))
static void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        if(!win) return;

        // الرادار
        radarCircle = [CAShapeLayer layer];
        radarCircle.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(win.frame.size.width/2, win.frame.size.height/2) radius:150 startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
        radarCircle.strokeColor = [UIColor cyanColor].CGColor;
        radarCircle.fillColor = [UIColor clearColor].CGColor;
        radarCircle.lineWidth = 2; radarCircle.opacity = 0;
        [win.layer addSublayer:radarCircle];

        // الأيقونة
        eIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        eIcon.frame = CGRectMake(80, 80, 60, 60);
        [eIcon setTitle:@"🦅" forState:UIControlStateNormal];
        eIcon.backgroundColor = [UIColor colorWithRed:0 green:0.5 blue:0.5 alpha:0.7];
        eIcon.layer.cornerRadius = 30;
        [eIcon addTarget:[SakrFinalMenu class] action:@selector(sh) forControlEvents:UIControlEventTouchUpInside];
        [eIcon addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[SakrFinalMenu class] action:@selector(drag:)]];
        [win addSubview:eIcon];

        // اللوحة
        mPanel = [[UIView alloc] initWithFrame:CGRectMake(win.frame.size.width/2-200, win.frame.size.height/2-150, 400, 300)];
        mPanel.backgroundColor = [UIColor colorWithRed:0.01 green:0.01 blue:0.05 alpha:0.95];
        mPanel.layer.cornerRadius = 10; mPanel.layer.borderWidth = 1.5; mPanel.layer.borderColor = [UIColor cyanColor].CGColor;
        mPanel.alpha = 0; [win addSubview:mPanel];

        vC = [[UIView alloc] initWithFrame:CGRectMake(0, 40, 400, 260)]; [mPanel addSubview:vC];
        [SakrFinalMenu addB:@"AIM HEADSHOT 🎯" y:10 tag:1 p:vC];
        [SakrFinalMenu addB:@"AIM CHEST/BODY 👕" y:60 tag:2 p:vC];
        [SakrFinalMenu addB:@"SHOW RADAR CIRCLE ⭕" y:110 tag:101 p:vC];
    });
}
