var exec = require('cordova/exec');

module.exports = {
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
}