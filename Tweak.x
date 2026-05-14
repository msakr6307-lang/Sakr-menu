#import <UIKit/UIKit.h>

static bool hShot = NO, bShot = NO, showRadar = NO;
static UIView *mPanel = nil;
static UIButton *eIcon = nil;
static CAShapeLayer *radarCircle = nil;

@interface MustafaFinal : NSObject
@end

@implementation MustafaFinal

+ (void)dragIcon:(UIPanGestureRecognizer *)p {
    UIView *v = p.view;
    CGPoint t = [p translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [p setTranslation:CGPointZero inView:v.superview];
}

+ (void)toggleFeat:(UIButton *)b {
    if (b.tag == 1) { hShot = !hShot; bShot = NO; }
    else if (b.tag == 2) { bShot = !bShot; hShot = NO; }
    else if (b.tag == 101) { 
        showRadar = !showRadar; 
        if (radarCircle) radarCircle.opacity = showRadar ? 1.0 : 0; 
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        if (b.backgroundColor == [UIColor clearColor]) {
            b.backgroundColor = [UIColor colorWithRed:0 green:0.8 blue:0.8 alpha:0.8];
        } else {
            b.backgroundColor = [UIColor clearColor];
        }
    }];
}

+ (void)showHide {
    [UIView animateWithDuration:0.3 animations:^{
        mPanel.alpha = (mPanel.alpha == 0) ? 1 : 0;
    }];
}
@end

%hook PlayerController
-(void)takeDamage:(float)d isHead:(BOOL)h {
    if (hShot) %orig(999, YES); 
    else if (bShot) %orig(999, NO);
    else %orig(d, h);
}
%end

__attribute__((constructor))
static void setupMustafaMenu() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIWindow *win = nil;
        // الطريقة الحديثة بدلاً من keyWindow المرفوضة في صورتك
        for (UIWindowScene* scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *w in scene.windows) {
                    if (w.isKeyWindow) { win = w; break; }
                }
            }
        }
        
        if(!win) return;

        // الرادار
        radarCircle = [CAShapeLayer layer];
        radarCircle.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(win.frame.size.width/2, win.frame.size.height/2) radius:150 startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
        radarCircle.strokeColor = [UIColor cyanColor].CGColor;
        radarCircle.fillColor = [UIColor clearColor].CGColor;
        radarCircle.lineWidth = 2; radarCircle.opacity = 0;
        [win.layer addSublayer:radarCircle];

        // النسر
        eIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        eIcon.frame = CGRectMake(100, 100, 60, 60);
        [eIcon setTitle:@"🦅" forState:UIControlStateNormal];
        eIcon.backgroundColor = [UIColor colorWithRed:0 green:0.5 blue:0.5 alpha:0.8];
        eIcon.layer.cornerRadius = 30;
        [eIcon addTarget:[MustafaFinal class] action:@selector(showHide) forControlEvents:UIControlEventTouchUpInside];
        [eIcon addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[MustafaFinal class] action:@selector(dragIcon:)]];
        [win addSubview:eIcon];

        // المنيو
        mPanel = [[UIView alloc] initWithFrame:CGRectMake(win.frame.size.width/2-150, win.frame.size.height/2-100, 300, 220)];
        mPanel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0.1 alpha:0.95];
        mPanel.layer.cornerRadius = 15; mPanel.layer.borderColor = [UIColor cyanColor].CGColor; mPanel.layer.borderWidth = 2;
        mPanel.alpha = 0; [win addSubview:mPanel];

        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 300, 30)];
        l.text = @"MUSTAFA SUPREME"; l.textColor = [UIColor cyanColor];
        l.textAlignment = NSTextAlignmentCenter; [mPanel addSubview:l];

        NSArray *btns = @[@"AIM HEADSHOT 🎯", @"AIM CHEST 👕", @"SHOW RADAR ⭕"];
        NSArray *tags = @[@1, @2, @101];
        
        for(int i=0; i<3; i++) {
            UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
            b.frame = CGRectMake(10, i*55+45, 280, 45);
            b.backgroundColor = [UIColor clearColor];
            b.layer.cornerRadius = 10; b.layer.borderWidth = 1; b.layer.borderColor = [UIColor cyanColor].CGColor;
            [b setTitle:btns[i] forState:UIControlStateNormal];
            b.tag = [tags[i] intValue];
            [b addTarget:[MustafaFinal class] action:@selector(toggleFeat:) forControlEvents:UIControlEventTouchUpInside];
            [mPanel addSubview:b];
        }
    });
}
