//
//  SMGConfig.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/26.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

//MARK:===============================================================
//MARK:                     < redisTime >
//MARK:===============================================================
#define cRedisIndexTime 300
#define cRedisReferenceTime 300
#define cRedisValueTime 30
#define cRedisNodeTime 30
#define cRedisDefaultTime 30    //默认,例如:小脑canout序列;
#define cRedisPortTime 30


//MARK:===============================================================
//MARK:                     < thinkingControl >
//MARK:===============================================================
#define cAssDataLimit 3 //应以当前整体思维活跃度,变化为1-3左右;
#define cMinEnergy 0 //思维活力限低
#define cMaxEnergy 5 //思维活力限高
#define cShortMemoryLimit 8 //瞬时记忆最多8条

//MARK:===============================================================
//MARK:                     < ThinkOut >
//MARK:===============================================================
#define cDataOutAssFoCount 3    //在决策过程中,foScheme横向最大条数;
#define cDataOutAssFoDeep 3     //在决策过程中,foScheme纵向最大深度;

#define cDataOutAssAlgCount 5    //在决策过程中,algScheme横向最大条数;
#define cDataOutAssAlgDeep 2     //在决策过程中,algScheme纵向最大深度;

#define cGreater NSIntegerMax  //表示内类比算法中,比大小时的大;
#define cLess NSIntegerMin     //表示内类比算法中,比大小时的大;

//MARK:===============================================================
//MARK:                     < ThinkIn >
//MARK:===============================================================
#define cMvNoneIdent @"mvNone"     //mv的默认标识
