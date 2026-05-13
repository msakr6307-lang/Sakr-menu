#import "ArchitectMenu.h"

// إعدادات الهاك الذكي
static bool espEnabled = true;
static float fovSize = 100.0f; 
static float espMaxDistance = 300.0f; // المسافة الافتراضية للكشف
static int targetType = 0; 

@implementation ArchitectMenu {
    UIView *_mainPanel;
    UILabel *_distanceValLabel;
}

+ (instancetype)sharedInstance {
    static ArchitectMenu *_shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[ArchitectMenu alloc] initWithFrame:[UIScreen mainScreen].bounds];
    });
    return _shared;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;

        // --- 1. الأيقونة العائمة باسم SAKR ---
        self.floatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.floatingButton.frame = CGRectMake(50, 150, 60, 60);
        self.floatingButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.1 blue:0.3 alpha:0.9]; 
        self.floatingButton.layer.cornerRadius = 30;
        self.floatingButton.layer.borderWidth = 2;
        self.floatingButton.layer.borderColor = [UIColor cyanColor].CGColor;
        [self.floatingButton setTitle:@"SAKR" forState:UIControlStateNormal];
        [self.floatingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.floatingButton.userInteractionEnabled = YES;
        [self.floatingButton addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
        [self.floatingButton addGestureRecognizer:pan];
        [self addSubview:self.floatingButton];

        // --- 2. الدائرة الزرقاء (FOV) ---
        self.crosshair = [[UIView alloc] initWithFrame:CGRectMake(0, 0, fovSize, fovSize)];
        self.crosshair.center = self.center;
        self.crosshair.layer.cornerRadius = fovSize/2;
        self.crosshair.layer.borderWidth = 1.2;
        self.crosshair.layer.borderColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:0.5].CGColor;
        [self addSubview:self.crosshair];

        // --- 3. القائمة السوداء المطورة ---
        _mainPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 420)];
        _mainPanel.center = self.center;
        _mainPanel.backgroundColor = [UIColor colorWithWhite:0.05 alpha:0.95];
        _mainPanel.layer.cornerRadius = 20;
        _mainPanel.layer.borderColor = [UIColor systemBlueColor].CGColor;
        _mainPanel.layer.borderWidth = 2;
        _mainPanel.hidden = YES;
        _mainPanel.userInteractionEnabled = YES;
        [self addSubview:_mainPanel];

        UILabel *titleHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 280, 30)];
        titleHeader.text = @"SAKR MOD MENU";
        titleHeader.textColor = [UIColor cyanColor];
        titleHeader.textAlignment = NSTextAlignmentCenter;
        titleHeader.font = [UIFont boldSystemFontOfSize:20];
        [_mainPanel addSubview:titleHeader];

        // التحكم في حجم الدائرة
        [self addSliderToPanel:@"Magic Bullet FOV" yPos:60 min:30 max:500 current:fovSize action:@selector(fovChanged:)];

        // التحكم في مسافة الكشف (ESP Distance)
        _distanceValLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 130, 240, 20)];
        _distanceValLabel.text = [NSString stringWithFormat:@"ESP Distance: %.0fm", espMaxDistance];
        _distanceValLabel.textColor = [UIColor whiteColor];
        [_mainPanel addSubview:_distanceValLabel];

        UISlider *distSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 155, 240, 30)];
        distSlider.minimumValue = 50;
        distSlider.maximumValue = 1000;
        distSlider.value = espMaxDistance;
        [distSlider addTarget:self action:@selector(distanceChanged:) forControlEvents:UIControlEventValueChanged];
        [_mainPanel addSubview:distSlider];

        // مكان الضرب (هيد / جسم)
        self.targetPart = [[UISegmentedControl alloc] initWithItems:@[@"Headshot", @"Body"]];
        self.targetPart.frame = CGRectMake(20, 210, 240, 35);
        self.targetPart.selectedSegmentIndex = 0;
        [self.targetPart addTarget:self action:@selector(partUpdated:) forControlEvents:UIControlEventValueChanged];
        [_mainPanel addSubview:self.targetPart];
    }
    return self;
}

// وظيفة مساعدة لإضافة سلايدر
- (void)addSliderToPanel:(NSString *)title yPos:(float)y min:(float)min max:(float)max current:(float)curr action:(SEL)sel {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 240, 20)];
    lbl.text = title;
    lbl.textColor = [UIColor lightGrayColor];
    [_mainPanel addSubview:lbl];
    UISlider *s = [[UISlider alloc] initWithFrame:CGRectMake(20, y+25, 240, 30)];
    s.minimumValue = min; s.maximumValue = max; s.value = curr;
    [s addTarget:self action:sel forControlEvents:UIControlEventValueChanged];
    [_mainPanel addSubview:s];
}

- (void)distanceChanged:(UISlider *)s {
    espMaxDistance = s.value;
    _distanceValLabel.text = [NSString stringWithFormat:@"ESP Distance: %.0fm", espMaxDistance];
}

- (void)fovChanged:(UISlider *)s {
    fovSize = s.value;
    self.crosshair.frame = CGRectMake(0, 0, fovSize, fovSize);
    self.crosshair.center = self.center;
    self.crosshair.layer.cornerRadius = fovSize/2;
}

- (void)partUpdated:(UISegmentedControl *)s { targetType = (int)s.selectedSegmentIndex; }
- (void)togglePanel { _mainPanel.hidden = !_mainPanel.hidden; }
- (void)handleDrag:(UIPanGestureRecognizer *)p {
    CGPoint trans = [p translationInView:self];
    p.view.center = CGPointMake(p.view.center.x + trans.x, p.view.center.y + trans.y);
    [p setTranslation:CGPointZero inView:self];
}
@end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].keyWindow addSubview:[ArchitectMenu sharedInstance]];
    });
}
