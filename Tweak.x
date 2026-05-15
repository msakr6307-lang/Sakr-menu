#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>

// --- العناوين اللي معاك (تأكد من مطابقتها هنا) ---
#define ADDR_MINING 0x1A611B0   
#define ADDR_DELIVERY 0x1B20A40 
#define ADDR_SPEED 0x1C5A210    

static BOOL mine_ON = NO, deliv_ON = NO, speed_ON = NO, esp_ON = NO;
static UIButton *eagleBtn;
static UIView *mustafaView;

// --- تنفيذ الدوال بناءً على الأوفسيتس الصح ---
void (*old_Mine)(void *inst, float p);
void new_Mine(void *inst, float p) {
    if (inst && mine_ON) p = 1.0f; // إنهاء المهمة
    old_Mine(inst, p);
}

void (*old_WP)(void *inst, CGPoint pos);
void new_WP(void *inst, CGPoint pos) {
    if (inst && deliv_ON) {
        // منطق سحب الإحداثيات
    }
    old_WP(inst, pos);
}

@interface MustafaFinal : NSObject
@end

@implementation MustafaFinal
+ (void)handleEagle:(UIPanGestureRecognizer *)p {
    CGPoint t = [p translationInView:eagleBtn.superview];
    eagleBtn.center = CGPointMake(eagleBtn.center.x + t.x, eagleBtn.center.y + t.y);
    [p setTranslation:CGPointZero inView:eagleBtn.superview];
}

+ (void)btnAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if(sender.tag == 1) esp_ON = !esp_ON;
    if(sender.tag == 2) mine_ON = !mine_ON;
    if(sender.tag == 3) deliv_ON = !deliv_ON;
    if(sender.tag == 4) speed_ON = !speed_ON;
    
    sender.backgroundColor = sender.selected ? [UIColor colorWithRed:0 green:0.6 blue:0.2 alpha:0.8] : [UIColor colorWithWhite:1 alpha:0.1];
}
@end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        uintptr_t base = (uintptr_t)_dyld_get_image_header(0);
        UIWindow *win = [UIApplication sharedApplication].keyWindow;

        // الحقن باستخدام الأوفسيتس الـ 100% صح
        MSHookFunction((void *)(base + ADDR_MINING), (void *)new_Mine, (void **)&old_Mine);

        // إعداد النسر 🦅
        eagleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        eagleBtn.frame = CGRectMake(50, 150, 60, 60);
        [eagleBtn setTitle:@"🦅" forState:UIControlStateNormal];
        eagleBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        eagleBtn.layer.cornerRadius = 30;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:[MustafaFinal class] action:@selector(handleEagle:)];
        pan.cancelsTouchesInView = NO;
        [eagleBtn addGestureRecognizer:pan];
        [eagleBtn addTarget:[NSBlockOperation blockOperationWithBlock:^{ mustafaView.hidden = !mustafaView.hidden; }] action:@selector(main) forControlEvents:UIControlEventTouchUpInside];
        [win addSubview:eagleBtn];

        // إعداد المنيو
        mustafaView = [[UIView alloc] initWithFrame:CGRectMake(win.frame.size.width/2-110, win.frame.size.height/2-150, 220, 330)];
        mustafaView.backgroundColor = [UIColor colorWithRed:0.02 green:0.02 blue:0.1 alpha:0.95];
        mustafaView.layer.borderColor = [UIColor orangeColor].CGColor;
        mustafaView.layer.borderWidth = 2;
        mustafaView.layer.cornerRadius = 20;
        mustafaView.hidden = YES;
        [win addSubview:mustafaView];

        UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 220, 30)];
        t.text = @"MUSTAFA VIP (STABLE)";
        t.textColor = [UIColor orangeColor];
        t.textAlignment = NSTextAlignmentCenter;
        t.font = [UIFont boldSystemFontOfSize:15];
        [mustafaView addSubview:t];

        NSArray *m = @[@"ESP 👁️", @"Auto Mine ⛏️", @"Fast Delivery 📦", @"Speed ⚡"];
        for(int i=0; i<4; i++){
            UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
            b.frame = CGRectMake(10, 50+(i*65), 200, 50);
            b.tag = i+1;
            [b setTitle:m[i] forState:UIControlStateNormal];
            b.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
            b.layer.cornerRadius = 10;
            [b addTarget:[MustafaFinal class] action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
            [mustafaView addSubview:b];
        }
    });
}
