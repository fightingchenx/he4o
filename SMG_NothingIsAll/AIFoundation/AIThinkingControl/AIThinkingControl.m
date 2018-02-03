//
//  AIThinkingControl.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/11/12.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIThinkingControl.h"
#import "AINet.h"
#import "AIMindValue.h"
#import "AIStringAlgsModel.h"
#import "AIInputMindValueAlgsModel.h"
#import "AIActionControl.h"
#import "AINode.h"
#import "AIModel.h"
#import "NSObject+Extension.h"

@interface AIThinkingControl()

@property (strong,nonatomic) NSMutableDictionary *cacheShort;//存AIModel(从Algs传入,待Thinking取用分析)(容量8);
@property (strong,nonatomic) NSMutableArray *cacheLong;//存AINode(相当于Net的缓存区)(容量10000);

@end

@implementation AIThinkingControl

static AIThinkingControl *_instance;
+(AIThinkingControl*) shareInstance{
    if (_instance == nil) {
        _instance = [[AIThinkingControl alloc] init];
    }
    return _instance;
}

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
        [self initRun];
    }
    return self;
}

-(void) initData{
    self.cacheShort = [[NSMutableDictionary alloc] init];
    self.cacheLong = [[NSMutableArray alloc] init];
}

-(void) initRun{
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) inputByShallow:(NSObject*)data{
    //1. update Caches;
    NSDictionary *dic = [NSObject getDic:data];
    NSString *dataType = NSStringFromClass(data.class);
    [self setObject_Caches:dataType value:dic];
    
    //2. check data hav mv;
    if ([self checkHavMV:dic]) { //hav mv
        [self inputByDeep:dataType mvDic:dic];
        return;
    }
    
    //3. if not find mv from caches,then try find actionControl;(充mv)
    for (NSString *dataSource in dic.allKeys) {
        id objValue = [dic objectForKey:dataSource];
        //AINode *dataSourceRoot = [[AIActionControl shareInstance] searchNodeForDataType:nil dataSource:dataSource];
        //AINode *objValueRoot = [[AIActionControl shareInstance] searchNodeForDataObj:objValue];
        NSLog(@"_____根据aiNode取到aiData(urgentValue)的值...");
    }
}


/**
 *  MARK:--------------------思维发现imv,制定cmv,分析实现cmv;--------------------
 *  参考:n9p20
 */
-(void) inputByDeep:(NSString*)dataType mvDic:(NSDictionary*)mvDic {
    //1. 识别dataType
    AINode *absNode = [[AIActionControl shareInstance] searchNodeForDataType:dataType dataSource:nil];
    
    //2. 取mv & targetType
    CGFloat urgentValue = [NUMTOOK([DICTOOK(mvDic) objectForKey:@"urgentValue"]) floatValue];
    AITargetType targetType = [NUMTOOK([DICTOOK(mvDic) objectForKey:@"targetType"]) intValue];
    
    //3. think前,先构建思维对象本体
    AIIdentifierModel *identModel = [[AIIdentifierModel alloc] init];
    identModel.identifier = STRTOOK(dataType);
    AINode *identNode = [[AIActionControl shareInstance] insertModel:identModel dataSource:nil];
    if (absNode) {
        [[AIActionControl shareInstance] updateNode:identNode abs:absNode];
    }
    
    //4. think中,优先构建cmv有关的信息;
    AIIntModel *tTModel = [[AIIntModel alloc] init];
    tTModel.from = targetType;
    tTModel.to = targetType;
    AINode *tTNode = [[AIActionControl shareInstance] insertModel:tTModel dataSource:@"targetType"];
    [[AIActionControl shareInstance] updateNode:tTNode propertyNode:identNode];
    
    AIFloatModel *uVModel = [[AIFloatModel alloc] init];
    uVModel.from = urgentValue;
    uVModel.to = urgentValue;
    AINode *uVNode = [[AIActionControl shareInstance] insertModel:uVModel dataSource:@"urgentValue"];
    [[AIActionControl shareInstance] updateNode:uVNode propertyNode:identNode];
    
    //5. 后根据cmv查找解决问题;(查找同cmv经验,并将tTNode和uVNode指定abs)
    AINode *tTNodeRoot = [[AIActionControl shareInstance] searchNodeForDataType:@"AIIntModel" dataSource:@"targetType"];
    AINode *uVNodeRoot = [[AIActionControl shareInstance] searchNodeForDataType:@"AIFloatModel" dataSource:@"urgentValue"];
    NSLog(@"");
    
    //6. 对查找结果进行类比 (类比符合度从100%->0%,经验优先,分析+多事务次之,猜测或感觉再次,cachesShort数据瞎想最终)
    [self thinkLoop];
    
    //7. 将类比到的数据构建与关联;
    
    //8. 进行思维mv循环
    
    //9. 进行决策输出
}

/**
 *  MARK:--------------------思维循环--------------------
 *  1. 优化级;(经验->多事务分析->感觉猜测->cacheShort瞎关联)
 *  2. 符合度;(99%->1%)
 */
-(void) thinkLoop {
    //类比原则:先用dataType和dataSource取,后存,再类比后作update结构化;
}

//MARK:===============================================================
//MARK:                     < caches >
//MARK:===============================================================
-(void) setObject_Caches:(NSString*)k value:(NSDictionary*)v {
    [self.cacheShort setObject:DICTOOK(v) forKey:k];
    
    if (self.cacheShort.count > 8) {
        NSString *removeKey = ARR_INDEX(self.cacheShort.allKeys, 0);
        [self.cacheShort removeObjectForKey:removeKey];
    }
}

//found mv;
-(BOOL) checkHavMV:(NSDictionary*)dic{
    return [STRTOOK([DICTOOK(dic) objectForKey:@"urgentValue"]) floatValue] > 0;
}

@end


//3. ThinkDemand的解;
//1,依赖于经验等数据;
//2,依赖与常识的简单解决方案;(类比)
//3,复杂的问题分析(多事务,加缓存,加分析)


//4. 老旧思维解决问题方式
//A. 搜索强化经验(经验表)
    //1),参照解决方式,
    //2),类比其常识,
    //3),制定新的解决方式,
    //4),并分析其可行性, & 修正
    //5),预测其结果;(经验中上次的步骤对比)
    //6),执行输出;
//B. 搜索未强化经历(意识流)
    //1),参照记忆,
    //2),尝试执行输出;
    //3),反馈(观察整个执行过程)
    //4),强化(哪些步骤是必须,哪些步骤是有关,哪些步骤是无关)
    //5),转移到经验表;
//C. 无
    //1),取原始情绪表达方式(哭,笑)(是急哭的吗?)
    //3),记忆(观察整个执行过程)


//5. 忙碌状态;
//-(BOOL) isBusy{return false;}

//6. 单次为比的结果;
//@property (assign, nonatomic) ComparisonType comparisonType;    //比较结果(toFeelId/fromFeelId)
