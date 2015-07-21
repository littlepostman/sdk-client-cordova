package com.littlepostman.cordova.plugin;

import android.content.Context;

import com.littlepostman.LPGCMService;
import com.littlepostman.cordova.plugin.LittlePostman;
import com.littlepostman.rpc.model.LPMessage;

public class GCMIntentService extends LPGCMService {

    @Override
    protected void onMessage(Context ctx, LPMessage pushMessage) {
        LittlePostman.getInstance().onPushMessage(pushMessage);
    }

}
