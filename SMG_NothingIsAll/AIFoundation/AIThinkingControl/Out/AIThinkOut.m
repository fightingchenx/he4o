//
//  AIThinkOut.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/24.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIThinkOut.h"
#import "DemandModel.h"
#import "ThinkingUtils.h"
#import "AIPort.h"
#import "AIThinkOutMvModel.h"
#import "AINet.h"
#import "AIKVPointer.h"
#import "AICMVNode.h"
#import "AIAbsCMVNode.h"
#import "AIFrontOrderNode.h"
#import "AINetAbsFoNode.h"
#import "Output.h"
#import "AIThinkOutFoModel.h"
#import "AIAbsAlgNode.h"
#import "AIAlgNode.h"

@implementation AIThinkOut

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================

-(void) dataOut {
    //1. 重排序 & 取当前序列最前的demandModel
    DemandModel *demandModel = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkOut_GetCurrentDemand)]) {
        demandModel = [self.delegate aiThinkOut_GetCurrentDemand];
    }
    if (!demandModel) return;
    
    //2. energy判断;
    if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkOut_EnergyValid)]) {
        if (![self.delegate aiThinkOut_EnergyValid]) {
            ///1. 如果energy<=0,(未找到可行性,直接反射输出)
            [self dataOut_ActionScheme:nil];
            return;
        }
    }
    
    //3. 从expCache中,排序并取到首个值得思考的可行outMvModel, 没有则用mvScheme联想一个新的;
    __block AIThinkOutMvModel *outMvModel = [demandModel getCurrentAIThinkOutMvModel];
    if (!outMvModel) {
        outMvModel = [self dataOut_MvScheme:demandModel];
    }
    if (!outMvModel) {
        ///1. 无解决经验,反射输出;
        [self dataOut_ActionScheme:nil];
        return;
    }
    
    
    //4. 有可具象思考的outMvModel则执行;
    if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkOut_UpdateEnergy:)]) {
        [self.delegate aiThinkOut_UpdateEnergy:-1];//思考与决策消耗能量;
    }
    
    //5. 联想"解决经验"对应的cmvNode & 联想具象数据,并取到决策关键信息 (foScheme);
    AIThinkOutFoModel *outFoModel = [self dataOut_FoScheme:outMvModel];
    if (!outFoModel) return;
    
    //6. 有执行方案,则对执行方案进行反思检查; (父可行性判定)
    CGFloat score = [ThinkingUtils dataOut_CheckScore_ExpOut:outFoModel.content_p];
    outMvModel.order += score;//联想对当前outMvModel的order影响;
    if (score < 3) {
        NSLog(@" >> 本次输出不过关,toLoop...");
        [demandModel.exceptOutMvModels addObject:outMvModel];//排除无效的outMvModel;
        [self dataOut];//并递归到最初;
        return;
    }
    
    //7. 尝试输出"可行性之首"并找到实际操作 (子可行性判定) (algScheme)
    ///1. 取出outLog;
    [self dataOut_AlgScheme:outFoModel];
    
    
    
    
    //8. actionScheme (行为方案输出)
    [self dataOut_ActionScheme:nil];
    
    
    
    
    
    
    
    
    
    
    
    //6. foScheme (联想"解决经验"对应的cmvNode & 联想具象数据,并取到决策关键信息;(可行性判定))
    //1. 从抽象方向找到fo节点;
    //2. 评价fo节点;
    //3. 筛选出out_ps和 "条件"
    //4. 注: 目前条件为"视觉看到的坚果" (已抽象的,如无距离)
    //5. 难点: 在于如何去满足这个条件;
    //6. 在外界去找到"条件";
    
    
    
    
    
    //明日计划;
    //1. 从抽象方向开始找foNode (而不是当前的具象方向);
    //2. 对找到的absFoNode装成outFoModel & 对条件进行判定;
    
    
    
    
    
    //明日计划;
    //1. 找到抽象foNode;
    //2. 把absFoNode中isOut部分跳过,其他为所需条件部分;
    //3. 到祖母中,对所需条件和已有条件进行类比,并分析出不同 (如距离)
    //4. 回归到fo找出能够让 "距离变化" 的时序,并找到行为方式 (如飞行)
    //5. 执行输出;
    //6. 视觉输入,(对outModel中的数据进行判定效果,继续执行决策)
    //先写一些伪代码;把以上步骤定义好结构架子;
    
    
    
    //TODONextYear: 从抽象往具象,往alg两个方向找实现方式与条件;
    
    //对实现方式foScheme已完成;
    
    //TODOTOMORROW: 写条件部分;(祖母)
    
    
    
    
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------MvScheme--------------------
 *  用于找到新的mv经验; (根据index索引找到outMvModel)
 */
-(AIThinkOutMvModel*) dataOut_MvScheme:(DemandModel*)demandModel{
    //1. 判断mv方向
    __block AIThinkOutMvModel *outMvModel = nil;
    [ThinkingUtils getDemand:demandModel.algsType delta:demandModel.delta complete:^(BOOL upDemand, BOOL downDemand) {
        MVDirection direction = downDemand ? MVDirection_Negative : MVDirection_Positive;
        
        //2. filter筛选器取曾经历的除已有outMvModels之外的最强解决;
        NSArray *mvRefs = [theNet getNetNodePointersFromDirectionReference:demandModel.algsType direction:direction filter:^NSArray *(NSArray *protoArr) {
            protoArr = ARRTOOK(protoArr);
            for (NSInteger i = 0; i < protoArr.count; i++) {
                AIPort *port = ARR_INDEX(protoArr, protoArr.count - i - 1);
                BOOL cacheContains = false;
                for (AIThinkOutMvModel *expCacheItem in demandModel.outMvModels) {
                    if (port.target_p && [port.target_p isEqual:expCacheItem.mvNode_p]) {
                        cacheContains = true;
                        break;
                    }
                }
                if (!cacheContains) {
                    return @[port];
                }
            }
            return nil;
        }];
        
        //3. 加入待判断区;
        AIPort *referenceMvPort = ARR_INDEX(mvRefs, 0);
        if (referenceMvPort) {
            outMvModel = [AIThinkOutMvModel newWithExp_p:referenceMvPort.target_p];
            [demandModel addToExpCache:outMvModel];
        }
    }];
    return outMvModel;
}


/**
 *  MARK:--------------------联想具象foNode--------------------
 *  @param outMvModel : 当前mvModel (具象之旅的出发点);
 *  @result : 返回时序节点地址
 *  1. 从上至下的联想foNode;
 *  注:目前支持每层3个(关联强度前3个),最多3层(具象方向3层);
 *
 *  TODO:加上联想到mv时,传回给demandManager;
 *  注:每一次输出,只是决策与预测上的一环;并不意味着结束;
 *  //1. 记录思考mv结果到叠加demandModel.order;
 *  //3. 如果mindHappy_No,可以再尝试下一个getNetNodePointersFromDirectionReference_Single;找到更好的解决方法;
 *  //4. 最终更好的解决方法被输出,并且解决问题后,被加强;
 *  //5. 是数据决定了下一轮循环思维想什么,但数据仅能通过mv来决定,无论是思考的方向,还是思考的能量,还是思考的目标,都是以mv为准的;而mv的一切关联,又是以数据为规律进行关联的;
 *
 */
-(AIThinkOutFoModel*) dataOut_FoScheme:(AIThinkOutMvModel*)outMvModel{
    //1. 数据准备
    if (!ISOK(outMvModel, AIThinkOutMvModel.class)) {
        return nil;
    }
    AICMVNodeBase *checkMvNode = [SMGUtils searchObjectForPointer:outMvModel.mvNode_p fileName:FILENAME_Node time:cRedisNodeTime];
    if (!checkMvNode) {
        return nil;
    }
    
    if (checkMvNode.foNode_p) {
        NSArray *checkFo_ps = @[checkMvNode.foNode_p];
        
        //2. 最多往具象循环三层
        for (NSInteger i = 0; i < cDataOutAssFoDeep; i++) {
            AIFoNodeBase *validFoNode = [ThinkingUtils scheme_GetAValidNode:checkFo_ps except_ps:outMvModel.except_ps checkBlock:nil];
            
            //3. 有效则返回,无效则循环到下一层
            if (ISOK(validFoNode, AIFoNodeBase.class)) {
                AIThinkOutFoModel *result = [[AIThinkOutFoModel alloc] init];
                result.content_p = validFoNode.pointer;
                return result;
            }else{
                checkFo_ps = [ThinkingUtils foScheme_GetNextLayerPs:checkFo_ps];
            }
        }
    }
    
    return nil;
}


/**
 *  MARK:--------------------algScheme--------------------
 *  1. 对条件祖母进行判定;
 *  2. 对条件祖母取最具象 (目前仅支持1层);
 */
-(void) dataOut_AlgScheme:(AIThinkOutFoModel*)outFoModel{
    //1. 数据准备
    if (!ISOK(outFoModel, AIThinkOutFoModel.class)) {
        return;
    }
    AIFoNodeBase *foNode = [SMGUtils searchObjectForPointer:outFoModel.content_p fileName:FILENAME_Node time:cRedisNodeTime];
    if (!foNode) {
        return;
    }
    [outFoModel.memOrder removeAllObjects];
    
    //2. 取条件祖母的最具象,得出memOrder;
    //NSLog(@" >> 所需条件: (%@)",[NVUtils convertOrderPs2Str:notOutAlg_ps]);
    for (AIKVPointer *pointer in foNode.orders_kvp) {
        if (pointer.isOut) {
            AIAlgNodeBase *outAlgNode = [SMGUtils searchObjectForPointer:pointer fileName:FILENAME_Node time:cRedisNodeTime];
            if (outAlgNode) {
                [outFoModel.memOrder addObject:outAlgNode];
            }
        }else{
            //2. 最多往具象循环2层
            NSArray *check_ps = @[pointer];
            for (NSInteger i = 0; i < cDataOutAssAlgDeep; i++) {
                AIAlgNode *validAlgNode = [ThinkingUtils scheme_GetAValidNode:check_ps except_ps:outFoModel.except_ps checkBlock:^BOOL(id checkNode) {
                    return ISOK(checkNode, AIAlgNode.class);
                }];
                
                //3. 有效则返回,无效则循环到下一层
                if (ISOK(validAlgNode, AIAlgNode.class)) {
                    [outFoModel.memOrder addObject:validAlgNode];
                }else{
                    check_ps = [ThinkingUtils algScheme_GetNextLayerPs:check_ps];
                }
            }
        }
    }
    
    //3. 对memOrder有效性初步检查
    if (outFoModel.memOrder.count == foNode.orders_kvp.count) {
        
        //数据合法;
        
        ////////////祖母的取用范围/////////////
        
        //1. 需要找出祖母的微信息不同处;
        //2. fo中,取抽象即可; (如吃坚果(距离0))
        //3. 但要回归到alg中,找具象;或先抽象一下,再找具象;
        //问题: 如何根据,吃坚果,联想到距离非0的坚果的;
        //回答: 可见,在祖母的联想中,是可以先抽象再具象的,只要是可以将微信息调整为合格的,都可以;
        //比如: "小孩子拿纸叠的地鼠,玩打地鼠游戏" 或 "想吃面条时,找到苹果,把苹果吃掉了"
        
        //原则: 一取一用
        //祖母1:"现在就能吃到的" 和祖母2:"可以吃的食物" 是两个祖母,但抽象都是食物;不同点在于其归属或距离问题;
        //白话: 我们从未吃过百米之外的食物,但却可以想到百米之外有食物,并且走过去,并吃掉;
        //分析: 祖母的先抽象,后具象,把食物的发现问题,变成了距离问题;
        //再由距离问题,变成了飞行问题;
        
        
        //TODOTOMORROW:
        
        //最具象即为真实, (本质上其实是fo加工微信息,以得到祖母的过程)
        //吃昨天已经吃完的饭,就是不真实;
        //吃昨天未吃完的剩饭,就是真实;
        
        //0饭,
        //已吃掉的饭,->fo X
        //在冰箱中的饭,->fo 飞行改变距离
        //
        
        /////1. TODOTOMORROW:做意识流双序列;
        
        //1. 首先是要解决强度序列之外的再加时间序列的问题; (其实不是时间序列,仅是一个激活节点的内存缓存)
        //2. 使用XGRedis来做10分钟自动销毁;
        //3. 事务需求:
        //4. 比如我们需要搜索硬盘节点中,哪个port指向的节点在redis中;
        //5. 再比如: 我们需要搜索到哪个redis中的node具有某微信息; (性能优化,建内存索引)
        
        
        
        /////2. TODOTOMORROW:memOrder中条件祖母的判定 (满足条件祖母)
        
        //1. 以上两层具象联想过程不需要; (删掉代码)
        //2. 根据memOrder中的抽象祖母,取抽象,再具象;取到n个不符合的具象祖母;
        //3. 将不符合的"微信息"找出来;
        //4. 到时序中,找可以改变此"微信息"的行为; {祖母[abs:a con:a1,a2] > 时序[a1_do_a2] -> MV[hunger]}
        //5. 根据此时序的mv来判定可行性;
        
        //6. 实例: fo吃坚果 -> alg抽象坚果 -> alg具象坚果(在内存中刚视觉看到的那个) -> \
        找不同,发现距离问题(视觉的距离祖母) -> doChange模型,飞行导致距离变化 -> 输出飞行行为
        
        //问题在于,doChange模型并非源于在fo中查找,而是早已类比抽象出来; (所以下一步思考DoChange模型的构建);
        
        
        
        //////2.2 分析DoChange模型的构建与使用过程;
        
        //1. 关键信息有: 坚果的方向,坚果的距离,飞行的方向;
        //2. 一个具象节点表现为: 飞行了某个方向,导致与某方向的坚果的距离变化;
        //3. 前提是: 离某方向的坚果有某距离;
        //4. 一个抽象节点表现为: 飞行方向变化 -> 距离变化
        //5. 类比的本质转为比大小,而不是相等;
        //6. 比大小比哪些:
        ///1. 如时序[a1_do_a2] 中对比a1与a2的大小,得出一个方向;(变大或变小);
        ///2. 再比如:
        ///3. 模型有可能是: [飞近->离的近] 或 [坚果方向0.7 -> 飞行方向0.7 -> 距离变近]
        //7. 从相对理论出发,应该给静态微信息扩展一个动态微信息值的设计;
        //8. 有了动态微信息,就要有动态值的索引;
        
        //如: "在飞行方向为0.69-0.81" 时 "方向为0.73-0.83的坚果" 距离变为了: "10-8";
        //每一次确切的fo,与联想到的fo,进行类比,并融合出模糊fo;
        
        //9. 模糊微信息,导致索引困难,范围变化时的实时性问题; 所以见10;
        //10. 将动态微信息的功能做到祖母中,以from to delta来表示;
        
        //11. 从sames类比祖母时,可以考虑将 "抽象祖母" 构建为一个范围;,,,
        //12. 然后自然就有了抽具象关联,以用来联想,然后也就不再需要微信息的方向索引;
        
        
        //>>>A: doChange模型其实仅是高度抽象的fo; (doChange只是一种匹配方式)
        //1. 对vision.distance的精度,调节为5dp; (作废)
        //2. 对vision.方向的精度,调节为10度; (使用)
        //2. 我们是否需要方向上的模糊匹配,或者干脆使用无数次经历带来的无数种fo;
        
        //我们可以发现,非常细微的远近差异,所以在祖母层时,微信息还是相对精确的;只是到了时序层类比时,开始变的模糊;
        
        //当微信息不损失精度时的模糊匹配:
        //1. 飞的更近; a2 < a1;
        //2. 找不同算法: `类比不同,发现距离问题` -> `构建距离delta抽象祖母` -> `构建起因于(找不同祖母)的fo`
        //3. 如: 从2可以构建出:"飞行 -> 距离变近" 的fo;
        
        //>>>B: doChange模型其实是"找不同算法",得出的fo;
        //1. 我们要对sames得出的fo与找不同得出的fo,进行区分;"找不同"得出的fo可以解决"条件祖母"的判定问题;
        
        
        
        
        
    }else{
        [self dataOut];
    }
    
    
    //关于条件的获取方式;
    //1. 从瞬时记忆来判定找;
    //2. 由其它时序来执行得到; (打车是祖母,而不是时序) (根据"距离变化"祖母,转化为行走才是时序,如走到路边)
    
    //////某条微信息的值的变化, (如距离)
    
    
    
    
    
    
    
    //1. 根据foNode取到条件;
    //2. 使用AIThinkOutFoModel将条件 (最多两个)记录到outFoModel;
    //3. 对outFoModel进行algModel条件的行为化;
    
    ///1. 比如找到坚果;
    ///2. 找到的坚果与fo中进行类比;
    ///3. 找出坚果距离的不同,或者坚果带皮儿的不同;
    ///4. 将距离与带皮转化成行为; (如飞行,或去皮);
    ///5. 达成条件;
    
    
}


/**
 *  MARK:--------------------尝试输出信息--------------------
 *  @param outArr : orders里筛选出来的algNode组;
 *
 *  三种输出方式:
 *  1. 反射输出 : reflexOut
 *  2. 激活输出 : absNode信息无conPorts方向的outPointer信息时,将absNode的宏信息尝试输出;
 *  3. 经验输出 : expOut指在absNode或conPort方向有outPointer信息;
 */
-(void) dataOut_ActionScheme:(NSArray*)outArr{
    //1. 尝试输出找到解决问题的实际操作 (取到当前cacheModel中的最佳决策,并进行输出;)
    BOOL tryOutSuccess = false;
    if (ARRISOK(outArr)) {
        for (AIKVPointer *algNode_p in outArr) {
            //>1 检查micro_p是否是"输出";
            //>2 假如order_p足够确切,尝试检查并输出;
            BOOL invoked = [Output output_TC:algNode_p];
            if (invoked) {
                tryOutSuccess = true;
            }
        }
    }
    
    //2. 无法解决时,反射一些情绪变化,并增加额外输出;
    if (!tryOutSuccess) {
        //>1 产生"心急mv";(心急产生只是"urgent.energy x 2")
        //>2 输出反射表情;
        //>3 记录log到foOrders;(记录log应该到output中执行)
        
        //1. 如果未找到复现方式,或解决方式,则产生情绪:急
        //2. 通过急,输出output表情哭
        NSLog(@"反射输出 >>");
        [Output output_Mood:AIMoodType_Anxious];
    }
}

@end
