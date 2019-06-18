interface TwinPush {
    setAlias(alias: string, successCallback: () => void, errorCallback?: (error: string) => void);
    setRegisterCallback(successCallback: (deviceId: string) => void, errorCallback?: (error: string) => void);
    getDeviceId(successCallback: (deviceId: string) => void, errorCallback?: (error: string) => void);
    setIntegerProperty(key: string, value: number, successCallback: (value: number) => void, errorCallback?: (error: string) => void);
    setFloatProperty(key: string, value: number, successCallback: (value: number) => void, errorCallback?: (error: string) => void);
    setBooleanProperty(key: string, value: boolean, successCallback: (value: boolean) => void, errorCallback?: (error: string) => void);
    setStringProperty(key: string, value: string, successCallback: (value: string) => void, errorCallback?: (error: string) => void);
}

declare var twinpush: TwinPush;
