
interface TwinPush {
    setAlias(alias: string, successCallback: () => void, errorCallback?: (error: string) => void);
    setRegisterCallback(successCallback: (deviceId: string) => void, errorCallback?: (error: string) => void);
    setNotificationOpenCallback(callback: (notification: TPNotification) => void);
    getDeviceId(successCallback: (deviceId: string) => void, errorCallback?: (error: string) => void);
    setIntegerProperty(key: string, value: number, successCallback: (value: number) => void, errorCallback?: (error: string) => void);
    setFloatProperty(key: string, value: number, successCallback: (value: number) => void, errorCallback?: (error: string) => void);
    setBooleanProperty(key: string, value: boolean, successCallback: (value: boolean) => void, errorCallback?: (error: string) => void);
    setStringProperty(key: string, value: string, successCallback: (value: string) => void, errorCallback?: (error: string) => void);
	setLocation(latitude: number, longitude: number, successCallback: (value: boolean) => void, errorCallback?: (error: string) => void);
	updateLocation(accuracy: number, successCallback: (value: boolean) => void, errorCallback?: (error: string) => void);
}

export declare var twinpush: TwinPush;

interface TPNotification {
    notificationId: string;
    message: string;
    title: string;
    subtitle: string;
    contentUrl: string;
    tags: string[];
    customProperties: {};
    date: Date;
}