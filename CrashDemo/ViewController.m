//
//  ViewController.m
//  CrashDemo
//
//  Created by Bruce on 16/12/29.
//  Copyright © 2016年 Bruce. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

        NSString *str = @"我是一只小鸟";
        NSLog(@"字符串长度length: %ld", (long)str.length);
        NSLog(@"字符串截取测试: %@", [str substringToIndex:1]);
        NSLog(@"字符串截取测试: %@", [str substringToIndex:10]);
    
//        NSMutableString *mutableStr = [NSMutableString new];
//        [mutableStr insertString:@"A" atIndex:0];
//        [mutableStr insertString:@"B" atIndex:1];
//        [mutableStr insertString:@"C" atIndex:2];
//        NSLog(@"替换前字符串长度: %@", mutableStr);
//        NSLog(@"====%s", class_getName([mutableStr class]));
//        [mutableStr replaceCharactersInRange:NSMakeRange(1, 1) withString:@"b"];
//        NSLog(@"替换后字符串长度: %@", mutableStr);
    
    //    NSMutableAttributedString *attributedStr = [NSMutableAttributedString new];
    //    [attributedStr insertAttributedString:[[NSAttributedString alloc] initWithString:@"A"] atIndex:0];
    //    [attributedStr insertAttributedString:[[NSAttributedString alloc] initWithString:@"B"] atIndex:1];
    //    [attributedStr insertAttributedString:[[NSAttributedString alloc] initWithString:@"C"] atIndex:2];
    //    NSLog(@"替换前字符串长度: %@", attributedStr);
    
    
    //    NSLog(@"====%s", class_getName([attributedStr class]));
    //    NSLog(@"length: %ld", (long)attributedStr.length);
    //    [attributedStr replaceCharactersInRange:NSMakeRange(10, 9) withString:@"a"];
    //    NSLog(@"替换后字符串长度: %@", attributedStr);
    
    //    NSDictionary *dict = @{@"userName": @"bruce", @"password": @"123456"};
    //    id obj = dict[@"password"];
    //    NSLog(@"class name : %s", class_getName([dict class]));
    //    NSLog(@"obj : %@", obj);
    
    //    id testObj = @"123456";
    //    NSLog(@"testObj : %@", testObj[@"password"]);
    
    //    NSString *test = @"test123";
    //    NSLog(@"className: %s", class_getName([test class]));
    
    //    id str = [[NSMutableString alloc] initWithString:@"test123"];
    //    NSLog(@"className: %s", class_getName([str class]));
    //    NSLog(@"test obj : %@", str[@"password"]);
    
    //    id obj = @{@"test": @"123456"};
    //    NSLog(@"length: %ld", ((NSString *)obj).length);
    
    //    UIWebView *webView = [[UIWebView alloc] init];
    //    NSLog(@"className: %s", class_getName([webView class]));
    
    //    NSMutableString *str = [[NSMutableString alloc] initWithString:@"ABC"];
    //    NSLog(@"class name : %s", class_getName([str class]));
    //    NSLog(@"是否包含: %d", [str containsString:@"D"]);
    
    //    id obj = [NSMutableArray arrayWithObjects:@"A", @"B", @"C", nil];
    //    NSLog(@"className: %s", class_getName([obj class]));
    //    NSLog(@"长度测试: %ld", [obj integerValue]);
    
    //    UISearchBar *searchBar = [[UISearchBar alloc] init];
    //    searchBar.returnKeyType = UIReturnKeySearch;
    
    //    id obj = [[NSNull alloc] init];
    //    NSLog(@"class name: %s", class_getName([obj class]));
    //    NSLog(@"length: %ld", (long)[obj length]);
}

// 第一种crash 'NSInvalidArgumentException'
/*
 1.1
 attempt to insert nil object from objects[1]'
 后台返回的数据有时可能为空，就会造成插入nil对象，从而导致crash
 可以利用Objective-C的runtime来解决该问题。
 */
- (void)demo1 {
    NSString *password = nil;
    NSDictionary *dict = @{
                           @"userName": @"bruce",
                           @"password": password
                           };
    NSLog(@"dict is : %@", dict);
    
}

/*
 1.2
 reason: 'data parameter is nil'
 解决方法：在序列化的时候，统一加入判断，判断data是不是nil即可
 */
- (void)demo2 {
    NSData *data = nil;
    NSError *error;
    NSDictionary *orginDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSLog(@"originDict is : %@", orginDict);
}

/*
 1.3
 unrecognized selector sent to instance 0x15d23910
 'NSRangeException'超出数组范围
 原因：就是一个类调用了一个不存在的方法，造成的崩溃
 解决方法：判断一下类型，不符合类型的不让调用比如respondsToSelector:
 也可以使用runtime对常见的方法调用做一下错误兼容，当调用不存在的方法的时候，替换成自己定义的方法，使之不会崩溃
 */
- (void)demo3 {
    /*
     [mutableArr objectAtIndex:100]  不会出错
     mutableArr[100]  会出错
     */
    
    NSArray  *emptyArr = [NSArray new];
    NSLog(@"%@",[emptyArr objectAtIndex:10]);   //emptyArr=nil，向nil发消息不会崩溃
    
    NSArray *arr = @[@"FlyElephant",@"keso"];
    NSString *result = [arr objectAtIndex:10];   //为什么不会出错
    NSLog(@"=======%@",result);
    
    NSMutableArray *mutableArr = [[NSMutableArray alloc] initWithArray:arr];
    NSLog(@"mutableArr: %@", mutableArr[100]);  // 超出数组范围了
    
    NSString *obj;
    [mutableArr addObject:obj]; // 向数组中添加 nil 对象不会崩溃
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:@"Q"];
    [array addObject:@"I"];
    NSLog(@"数组测试结果：%@", array[2]);  // 超出数组范围了
    NSLog(@"数组测试结果：%@", array[1]);
    
}

/*
 第二种
 SIGSEGV 异常，SEGV让代码终止的标识，当去访问没有被开辟的内存或者已经被释放的内存时，就会发生
 解决方法：一种是用Xcode自带的内存分析工具（Leaks），一种是使用facebook提供的自动化工具来监测内存问题
 FBRetainCycleDetector、FBAllocationTracker、FBMemoryProfiler
 
 */
- (void)demo4 {
   // dataOut = malloc(dataOutAvailable * sizeof(uint8_t));
    
    // 在不使用的时候加上如下代码，释放内存
   // free(dataOut);
}

/*
 第三种  NSRangeException 异常
 一种是数组越界，一种字符串截取越界
 解决方法：一是获取数组的时候，判断一下数组长度
 二、利用runtime的Swizzle Method特性
 */
- (void)demo5 {
    
}

/*
 第四种 SIGPIPE 异常
 对一个端已经关闭的socket调用两次write，第二次write将会产生SIGPIPE信号，该信号默认结束进程
 在iOS系统中，只需把下面这段代码放在.pch文件即可
 */
- (void)demo6 {
    // 仅在 IOS 系统上支持 SO_NOSIGPIPE
#if defined(SO_NOSIGPIPE) && !defined(MSG_NOSIGNAL)
    // We do not want SIGPIPE if writing to socket.
    const int value = 1;
    setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &value, sizeof(int));
#endif
}

/*
 第五种 SIGABRT 异常
 这是一个让程序终止的标识，会在断言、app内部、操作系统用终止方法抛出。通常发生在异步执行系统方法的时候。如CoreData、NSUserDefaults等，还有一些其他的系统多线程操作。
 注意：这并不一定意味着是系统代码存在bug，代码仅仅是成了无效状态，或者异常状态。
 */

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self demo3];
}

- (IBAction)btnAction:(id)sender {
    UIViewController *test01 = [[UIViewController alloc] init];
    [self.navigationController pushViewController:test01 animated:YES];
    [self.navigationController pushViewController:test01 animated:YES];
    
   // [self.view addSubview:self.view];  // Can't add self as subview
}

@end
