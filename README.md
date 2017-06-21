### Installation

To install the plugin in your Cordova application, add the plugin using cordova CLI and add the required parameters:

    cordova plugin add https://github.com/TwinPush/twinpush-cordova-plugin.git --variable APP_ID="YOUR_APP_ID" --variable API_KEY="YOUR_API_KEY"
    
This is the list of the allowed parameters, all of them must follow the format `--variable VARIABLE_NAME="VARIABLE_VALUE"` and can be later modified in the `config.xml` file as preferences:

- `APP_ID` is the Application Identifier in the TwinPush platform. It can be obtained from the TwinPush web console in the Application settings section. This parameter is required. It can be later modified as `TwinPush_AppId` in the project _config.xml_ file.

- `API_KEY` is the API Authentication Key required to connect to the TwinPush API. It can be obtained from the TwinPush web console in the Application settings section. This parameter is required. It can be later modified as `TwinPush_ApiKey` in the project _config.xml_ file.

- `SUBDOMAIN` variable is optional and defaults to `app`. It only has to be set if you are using a custom subdomain. It can be later modified as `TwinPush_Subdomain` in the project _config.xml_ file.

- `GCM_SENDER` is required for Android builds. It indicates the sender identifier for Google Cloud Messaging. It can be obtained in the GCM web console. It can be later modified as `TwinPush_GcmSender` in the project _config.xml_ file.

### Basic TwinPush integration
    
Once installed, the plugin will automatically register for push notifications and track activity events. You can extend the default integration by calling the exposed TwinPush methods.

#### Alias

You can set the device alias by calling the `setAlias` method of the `twinpush` module:

    var success = function(message) {
        alert(message); // This is only for testing purposes
    }

    var failure = function() {
        alert("Error calling setAlias method");
    }

    twinPush.setAlias("email@company.com", success, failure);
    
