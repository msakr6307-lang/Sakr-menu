#import <UIKit/UIKit.h>

static bool hShot = NO, bShot = NO, showRadar = NO;
static UIView *mPanel = nil;
static UIButton *eIcon = nil;
static CAShapeLayer *radarCircle = nil;

@interface MustafaVip : NSObject
@end

@implementation MustafaVip
+ (void)p:(UIPanGestureRecognizer *)g {
    UIView *v = g.view;
    CGPoint t = [g translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [g setTranslation:CGPointZero inView:v.superview];
}
+ (void)t { mPanel.alpha = (mPanel.alpha == 0) ? 1 : 0; }
+ (void)a:(UIButton *)b {
    if (b.tag == 1) { hShot = !hShot; bShot = NO; }
    if (b.tag == 3) { showRadar = !showRadar; if(radarCircle) radarCircle.opacity = showRadar ? 1 : 0; }
    b.backgroundColor = (b.backgroundColor == [UIColor clearColor]) ? [UIColor cyanColor] : [UIColor clearColor];
}
@end

%hook PlayerController
-(void)takeDamage:(float)d isHead:(BOOL)h {
    if (hShot) %orig(999, YES); else %orig(d, h);
}
%end

__attribute__((constructor))
static void go() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // الطريقة اللي هتكسر عين الـ Compiler (بدون keyWindow)
        UIWindow *w = nil;
        NSArray *ss = [[UIApplication sharedApplication].connectedScenes allObjects];
        for (id s in ss) {
            if ([s respondsToSelector:@selector(windows)]) {
                NSArray *ws = [s performSelector:@selector(windows)];
                for (UIWindow *tmp in ws) {
                    if (tmp.isKeyWindow) { w = tmp; break; }
                }
            }
        }
        if (!w) w = [[UIApplication sharedApplication] windows].firstObject;
        if (!w) return;

        radarCircle = [CAShapeLayer layer];
        radarCircle.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(w.frame.size.width/2, w.frame.size.height/2) radius:140 startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
        radarCircle.strokeColor = [UIColor cyanColor].CGColor;
        radarCircle.fillColor = [UIColor clearColor].CGColor;
        radarCircle.lineWidth = 1.5; radarCircle.opacity = 0;
        [w.layer addSublayer:radarCircle];

        eIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        eIcon.frame = CGRectMake(100, 100, 55, 55);
        [eIcon setTitle:@"🦅" forState:UIControlStateNormal];
        eIcon.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
        eIcon.layer.cornerRadius = 27.5;
        [eIcon addTarget:[MustafaVip class] action:@selector(t) forControlEvents:UIControlEventTouchUpInside];
        [eIcon addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[MustafaVip class] action:@selector(p:)]];
        [w addSubview:eIcon];

        mPanel = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 250, 180)];
        mPanel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0.1 alpha:0.9];
        mPanel.layer.cornerRadius = 10; mPanel.layer.borderWidth = 1; mPanel.layer.borderColor = [UIColor cyanColor].CGColor;
        mPanel.alpha = 0; [w addSubview:mPanel];

        UIButton *b1 = [UIButton buttonWithType:UIButtonTypeCustom];
        b1.frame = CGRectMake(10, 40, 230, 40); b1.tag = 1;
        [b1 setTitle:@"HEADSHOT" forState:UIControlStateNormal];
        [b1 addTarget:[MustafaVip class] action:@selector(a:) forControlEvents:UIControlEventTouchUpInside];
        [mPanel addSubview:b1];

        UIButton *b3 = [UIButton buttonWithType:UIButtonTypeCustom];
        b3.frame = CGRectMake(10, 100, 230, 40); b3.tag = 3;
        [b3 setTitle:@"RADAR" forState:UIControlStateNormal];
        [b3 addTarget:[MustafaVip class] action:@selector(a:) forControlEvents:UIControlEventTouchUpInside];
        [mPanel addSubview:b3];
    });
}
