var exec = require('cordova/exec');

module.exports = {
    LocationAccuracy: {
        FINE: 0,
        HIGH: 1,
        MEDIUM: 2,
        LOW: 3,
        COARSE: 4
    },

	setAlias: function(alias, successCallback, errorCallback = () => {}) {
		cordova.exec(successCallback, errorCallback, 'TwinPush', 'setAlias', [alias]);
	},

	setRegisterCallback: function(successCallback, errorCallback = () => {}) {
		cordova.exec(successCallback, errorCallback, 'TwinPush', 'setRegisterCallback', []);
	},

	getDeviceId: function(successCallback, errorCallback = () => {}) {
		cordova.exec(successCallback, errorCallback, 'TwinPush', 'getDeviceId', []);	
	},

	setIntegerProperty: function(key, value, successCallback, errorCallback = () => {}) {
		cordova.exec(successCallback, errorCallback, 'TwinPush', 'setIntegerProperty', [key, value]);	
	},

	setFloatProperty: function(key, value, successCallback, errorCallback = () => {}) {
		cordova.exec(successCallback, errorCallback, 'TwinPush', 'setFloatProperty', [key, value]);	
	},

	setBooleanProperty: function(key, value, successCallback, errorCallback = () => {}) {
		cordova.exec(successCallback, errorCallback, 'TwinPush', 'setBooleanProperty', [key, value]);	
	},

	setStringProperty: function(key, value, successCallback, errorCallback = () => {}) {
		cordova.exec(successCallback, errorCallback, 'TwinPush', 'setStringProperty', [key, value]);	
	},

	setLocation: function(latitude, longitude, successCallback, errorCallback = () => {}) {
		cordova.exec(successCallback, errorCallback, 'TwinPush', 'setLocation', [latitude, longitude]);
	},

	updateLocation: function(accuracy, successCallback, errorCallback = () => {}) {
		cordova.exec(successCallback, errorCallback, 'TwinPush', 'updateLocation', [accuracy]);
	},
}