#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>

// --- إعدادات الحالة ---
static BOOL isMenuOpen = NO;
static BOOL espEnabled = NO;
static BOOL mineEnabled = NO;
static BOOL deliveryEnabled = NO;
static BOOL speedEnabled = NO;

static UIView *mustafaMenu;
static UIButton *eagleBtn;

// --- منطقة "الزتونة" (القيم التقنية) ---
struct Vector3 { float x, y, z; };

// 1. هوك كشف الأماكن (ESP)
// ملاحظة: بيعتمد على رسم طبقة فوق اللعبة
void (*old_PlayerUpdate)(void *instance);
void new_PlayerUpdate(void *instance) {
    if (instance != NULL && espEnabled) {
        // منطق إظهار الاسم والمسافة
    }
    old_PlayerUpdate(instance);
}

// 2. هوك المنجم (Auto-Mine)
void (*old_Mining)(void *instance, float progress);
void new_Mining(void *instance, float progress) {
    if (instance != NULL && mineEnabled) {
        progress = 1.0f; // إنهاء المهمة فوراً
    }
    old_Mining(instance, progress);
}

// 3. هوك التوصيل (Delivery Snatch)
void (*old_WayPoint)(void *instance, struct Vector3 pos);
void new_WayPoint(void *instance, struct Vector3 pos) {
    if (instance != NULL && deliveryEnabled) {
        // سحب النقطة لإحداثيات اللاعب (تحت رجلك)
    }
    old_WayPoint(instance, pos);
}

@interface MustafaManager : NSObject
+ (void)setupUI;
+ (void)handlePan:(UIPanGestureRecognizer *)p;
@end

@implementation MustafaManager

// تحريك الصقر في أي مكان على الشاشة 
+ (void)handlePan:(UIPanGestureRecognizer *)p {
    CGPoint translation = [p translationInView:eagleBtn.superview];
    eagleBtn.center = CGPointMake(eagleBtn.center.x + translation.x, eagleBtn.center.y + translation.y);
    [p setTranslation:CGPointZero inView:eagleBtn.superview];
}

+ (void)btnPressed:(UIButton *)sender {
    switch (sender.tag) {
        case 1: espEnabled = !espEnabled; break;
        case 2: mineEnabled = !mineEnabled; break;
        case 3: deliveryEnabled = !deliveryEnabled; break;
        case 4: speedEnabled = !speedEnabled; break;
    }
    sender.backgroundColor = sender.selected ? [UIColor colorWithWhite:1 alpha:0.1] : [UIColor colorWithRed:0 green:0.5 blue:0 alpha:0.6];
    sender.selected = !sender.selected;
}

@end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;

        // --- زر الصقر العائم 🦅 ---
        eagleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        eagleBtn.frame = CGRectMake(50, 150, 60, 60);
        [eagleBtn setTitle:@"🦅" forState:UIControlStateNormal];
        eagleBtn.titleLabel.font = [UIFont systemFontOfSize:35];
        eagleBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        eagleBtn.layer.cornerRadius = 30;
        eagleBtn.layer.borderWidth = 1.5;
        eagleBtn.layer.borderColor = [UIColor orangeColor].CGColor;
        
        // إضافة خاصية السحب (Drag)
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:[MustafaManager class] action:@selector(handlePan:)];
        [eagleBtn addGestureRecognizer:pan];
        
        [eagleBtn addTarget:[NSBlockOperation blockOperationWithBlock:^{
            mustafaMenu.hidden = !mustafaMenu.hidden;
        }] action:@selector(main) forControlEvents:UIControlEventTouchUpInside];
        
        [win addSubview:eagleBtn];

        // --- المنيو الرئيسي (Mustafa VIP) ---
        mustafaMenu = [[UIView alloc] initWithFrame:CGRectMake(120, 150, 220, 320)];
        mustafaMenu.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.1 alpha:0.95];
        mustafaMenu.layer.cornerRadius = 20;
        mustafaMenu.layer.borderWidth = 2;
        mustafaMenu.layer.borderColor = [UIColor orangeColor].CGColor;
        mustafaMenu.hidden = YES;
        [win addSubview:mustafaMenu];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 220, 30)];
        label.text = @"MUSTAFA VIP MOD";
        label.textColor = [UIColor orangeColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:16];
        [mustafaMenu addSubview:label];

        NSArray *features = @[@"Wallhack (ESP) 👁️", @"Auto Mine ⛏️", @"Delivery Snatch 📦", @"Super Speed ⚡"];
        for (int i = 0; i < features.count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(10, 50 + (i * 65), 200, 50);
            btn.tag = i + 1;
            [btn setTitle:features[i] forState:UIControlStateNormal];
            btn.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
            btn.layer.cornerRadius = 10;
            [btn addTarget:[MustafaManager class] action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
            [mustafaMenu addSubview:btn];
        }
        
        // --- تفعيل الـ Hooks (العناوين لـ 1.0.3) ---
        uintptr_t base = (uintptr_t)_dyld_get_image_header(0);
        MSHookFunction((void *)(base + 0x1A611B0), (void *)new_Mining, (void **)&old_Mining);
        MSHookFunction((void *)(base + 0x1B20A40), (void *)new_WayPoint, (void **)&old_WayPoint);
    });
}
