package com.twinpush.cordova;

import android.app.Activity;
import android.content.Intent;
import android.util.Log;

import com.twincoders.twinpush.sdk.TwinPushSDK;
import com.twincoders.twinpush.sdk.activities.RichNotificationActivity;
import com.twincoders.twinpush.sdk.entities.TwinPushOptions;
import com.twincoders.twinpush.sdk.notifications.PushNotification;
import com.twincoders.twinpush.sdk.services.NotificationIntentService;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

public class TwinPush extends CordovaPlugin {
    private static final String LOG_TAG = "TwinPush";

    private TwinPushSDK twinpush() {
        return TwinPushSDK.getInstance(cordova.getActivity());
    }

    @Override
    protected void pluginInitialize() {
        super.pluginInitialize();

        TwinPushOptions options = new TwinPushOptions();
        options.twinPushAppId = preferences.getString("TwinPush_AppId", "");
        options.twinPushApiKey = preferences.getString("TwinPush_ApiKey", "");
        options.subdomain = preferences.getString("TwinPush_Subdomain", "app");
        options.gcmProjectNumber = preferences.getString("TwinPush_GcmSender", " ");

        twinpush().setup(options);
        twinpush().register();
        checkPushNotification(cordova.getActivity().getIntent());
    }

    @Override
    public boolean execute(final String action, final JSONArray data, final CallbackContext callbackContext) {
        if ("setAlias".equals(action)) {
            Log.v(LOG_TAG, "setAlias: data=" + data.toString());
            try {
                String alias = data.getString(0);
                twinpush().register(alias, new TwinPushSDK.OnRegistrationListener() {
                    @Override
                    public void onRegistrationSuccess(String currentAlias) {
                        callbackContext.success("Successfully registered");
                    }

                    @Override
                    public void onRegistrationError(Exception exception) {
                        callbackContext.error(exception.getMessage());
                    }
                });
            } catch (JSONException e) {
                callbackContext.error(e.getMessage());
            }
            return true;
        }
        return false;
    }

    @Override
    public void onStart() {
        super.onStart();
        twinpush().activityStart(cordova.getActivity());
    }

    @Override
    public void onStop() {
        super.onStop();
        twinpush().activityStop(cordova.getActivity());
    }

    @Override
    public void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        checkPushNotification(intent);
    }

    // Checks if the intent contains a Push notification and displays rich content when appropriated
    private void checkPushNotification(Intent intent) {
        if (intent != null && intent.getAction() != null && intent.getAction().equals(NotificationIntentService.ON_NOTIFICATION_OPENED_ACTION)) {
            PushNotification notification = (PushNotification) intent.getSerializableExtra(NotificationIntentService.EXTRA_NOTIFICATION);
            twinpush().onNotificationOpen(notification);

            if (notification != null && notification.isRichNotification()) {
                Intent richIntent = new Intent(cordova.getActivity(), RichNotificationActivity.class);
                richIntent.putExtra(NotificationIntentService.EXTRA_NOTIFICATION, notification);
                cordova.getActivity().startActivity(richIntent);
            }
        }
    }
}