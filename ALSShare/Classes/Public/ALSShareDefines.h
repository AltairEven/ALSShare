//
//  ALSShareDefines.h
//  ALSShare
//
//  Created by Altair on 13/10/2017.
//

#ifndef ALSShareDefines_h
#define ALSShareDefines_h


#endif /* ALSShareDefines_h */


typedef enum {
    ALSSharePlatformUnknown,
    ALSSharePlatformWeChat,
    ALSSharePlatformWeibo,
    ALSSharePlatformTencent,
    ALSSharePlatformUnDefined
}ALSSharePlatform;

typedef enum {
    ALSShareSceneCommon = 0,
    ALSShareSceneWeChatSession,
    ALSShareSceneWeChatTimeLine,
    ALSShareSceneWeChatFavorite,
    ALSShareSceneTencentQQ,
    ALSShareSceneTencentQZone
}ALSShareScene;
