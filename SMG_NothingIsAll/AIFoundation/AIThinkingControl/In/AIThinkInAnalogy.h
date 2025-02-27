//
//  AIThinkInAnalogy.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/3/20.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

//MARK:===============================================================
//MARK:                     < Analogy类比 >
//MARK:===============================================================
@class AIAbsAlgNode,AIAlgNode;
@interface AIThinkInAnalogy : NSObject

/**
 *  MARK:--------------------fo外类比 (外中有内,找相同算法)--------------------
 *  @param canAssBlock      : energy判断器 (为null时,无限能量);
 *  @param updateEnergy     : energy消耗器 (为null时,不消耗能量值);
 *  @result notnull             : 返回orderSames用于构建absFo
 *
 *  1. 连续信号中,找重复;(连续也是拆分,多事务处理的)
 *  2. 两条信息中,找交集;
 *  3. 在连续信号的处理中,实时将拆分单信号存储到内存区,并提供可检索等,其形态与最终存硬盘是一致的;
 *  4. 类比处理(瓜是瓜)
 *  注: 类比的处理,是足够细化的,对思维每个信号作类比操作;(而将类比到的最基本的结果,输出给thinking,以供为构建网络的依据,最终是以网络为目的的)
 *  注: 随后可以由一个sames改为多个sames并实时使用block抽象 (并消耗energy);
 */
+(NSArray*) analogyOutsideOrdersA:(NSArray*)ordersA ordersB:(NSArray*)ordersB canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)())updateEnergy;


/**
 *  MARK:--------------------fo内类比 (内中有外,找不同算法)--------------------
 *  @param checkFo      : 要处理的fo.orders;
 *  @param canAssBlock  : energy判断器 (为null时,无限能量);
 *  @param updateEnergy : energy消耗器 (为null时,不消耗能量值);
 *
 *  1. 此方法对一个fo内的orders进行内类比,并将找到的变化进行抽象构建网络;
 *  2. 如: 绿瓜变红瓜,如远坚果变近坚果;
 *  3. 每发现一个有效变化目标,则构建2个absAlg和2个absFo; (参考n15p18内类比构建图)
 *  注: 目前仅支持一个微信息变化的规律;
 *  TODO: 将内类比的类比部分代码,进行单独PrivateMethod,然后与外类比中调用的进行复用;
 */
+(void) analogyInnerOrders:(AIFoNodeBase*)checkFo canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)())updateEnergy;

@end
