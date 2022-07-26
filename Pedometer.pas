unit Pedometer;

  interface

    uses
      System.SysUtils, System.Classes, System.Sensors.Components, FMX.Types, FireDAC.Comp.Client;

    const
      DefaultStrideLength : Single = 0.73;
      DefaultDetectionTimeout : Single = 10000.0;
      DefaultSensitivity : NativeUInt = 50000;

    type
      TPedometer = class(TComponent)
        private
          FStopDetectionTimeout : Single;
          FStrideLenghtUserDefined : Single;
          FDistance : Single;
          FElapsedTime : NativeUInt;
          FSimpleSteps : NativeUInt;
          FStrideLengthComputed : Single;
          FWalkSteps : NativeUInt;
          FIsPaused : Boolean;
          FIsStarted : Boolean;
          FSensor : TMotionSensor;
          FTimer : TTimer;  // really useful?  ->  clarify its use in this component...
          FListPoints : TFDMemTable; // for recording measures
          FSensitivity : NativeUInt;
          // ??? missing field to record results when stopping pedometer ???
        protected
          procedure SetStopDetectionTimeout(aDuration : Single); virtual;
          procedure SetStrideLenghtUserDefined(aLength : Single); virtual;
          procedure SetDistance(aLength : Single); virtual;
          procedure SetElapsedTime(aDuration : NativeUInt); virtual;
          procedure SetSimpleSteps(aQuantity : NativeUInt); virtual;
          procedure SetStrideLengthComputed(aLength : Single); virtual;
          procedure SetWalkSteps(aQuantity : NativeUInt); virtual;
          procedure SetIsPaused(aStatus : Boolean); virtual;
          procedure SetIsStarted(aStatus : Boolean); virtual;
          procedure ResetToDefaultValues; virtual;
        public
          class constructor Create(AOwner: TComponent); override;
          destructor Destroy; override;
          procedure Reset; virtual;
          procedure Save; virtual;
          procedure Pause; virtual;
          procedure Start; virtual;
          procedure Stop; virtual;
          function SensorInfo : TStringList; virtual;
          property Distance : Single read FDistance;
          property ElapsedTime : NativeUInt read FElapsedTime;
          property SimpleSteps : NativeUInt read FSimpleSteps;
          property StrideLengthComputed : Single read FStrideLengthComputed default DefaultStrideLength;
          property WalkSteps : NativeUInt read FWalkSteps;
          property IsPaused : Boolean read FIsPaused default False;
          property IsStarted : Boolean read FIsStarted default False;
        published
          property StopDetectionTimeout : Single read FStopDetectionTimeout write SetStopDetectionTimeout default DefaultDetectionTimeout;
          property StrideLenghtUserDefined : Single read FStrideLenghtUserDefined write SetStrideLenghtUserDefined default DefaultStrideLength;
          property Sensitivity : NativeUInt read FSensitivity write FSensitivity default DefaultSensitivity;
      end;

    procedure Register;

  implementation

    procedure Register;
      begin
        RegisterComponents('JBHuet dot com', [TPedometer]);
      end;

    { TPedometer }

    class constructor TPedometer.Create(AOwner: TComponent);
      begin
        inherited;
        FSensor := nil;
        if TSensorManager.CanActivate then
          begin
            TSensorManager.Current.Activate;
            if Length(TSensorManager.Current.GetSensorsByCategory(TSensorCategory.Motion)) > 0 then
              begin
                FSensor := TMotionSensor.Create(Self);
                try
                  FTimer := TTimer.Create(Self);
                  try
                    FListPoints := TFDMemTable.Create(Self);
                    try
                       // initialize MemTable with fields: 1 field for each property of sensor available (depends on hardware and plateform)
                       ResetToDefaultValues;
                    except
                      FListPoints.Free;
                    end;
                  except on E: Exception do
                    FTimer.Free;
                  end;
                except
                  FSensor.Free;
                end;
            end;
          TSensorManager.Current.Deactivate;
        end;
      end;

    destructor TPedometer.Destroy;
      begin
        if Assigned(FListPoints) then
          FListPoints.EmptyDataSet;
        FListPoints.Free;
        FTimer.Free;
        FSensor.Free;
        inherited;
      end;

    procedure TPedometer.Pause;
      begin
        if Assigned(FSensor) then
          begin
            if FIsStarted then
              begin
                {
                if FIsPaused = False
                   stop recording FSensor.OnDataChange events
                   pause FTimer
                   SetFIsPaused(True)
                 else
                   start recording FSensor.OnDataChange events
                   restart FTimer
                   SetFIsPaused(False)
                }
              end;
          end;
      end;

    procedure TPedometer.Reset;
      begin
        if Assigned(FSensor) then
          begin
            if FIsStarted then
              begin
                ResetToDefaultValues;
              end;
          end;
      end;

    procedure TPedometer.ResetToDefaultValues;
      begin
        if Assigned(FListPoints) then
          FListPoints.EmptyDataSet;
        SetStopDetectionTimeout(DefaultDetectionTimeout);
        SetStrideLengthComputed(DefaultStrideLength);
        SetStrideLenghtUserDefined(DefaultStrideLength);
        FSensitivity := DefaultSensitivity;
      end;

    procedure TPedometer.Save;
      begin
        if Assigned(FSensor) then
          begin
            // If FListPoints not empty, store results somewhere...
          end;
      end;

    function TPedometer.SensorInfo : TStringList;
      begin
        // something similar to https://docwiki.embarcadero.com/CodeExamples/Sydney/en/FMX.SensorInfo_Sample
      end;

    procedure TPedometer.SetDistance(aLength: Single);
      begin
        if aLength < 0 then
          raise EArgumentOutOfRangeException.Create('Value MUST be POSITIVE');
        FDistance := aLength;
      end;

    procedure TPedometer.SetElapsedTime(aDuration: NativeUInt);
      begin
        FElapsedTime := aDuration;
      end;

    procedure TPedometer.SetIsPaused(aStatus: Boolean);
      begin
        FIsPaused := aStatus;
      end;

    procedure TPedometer.SetIsStarted(aStatus: Boolean);
      begin
        FIsStarted := aStatus;
      end;

    procedure TPedometer.SetSimpleSteps(aQuantity: NativeUInt);
      begin
        FSimpleSteps := aQuantity;
      end;

    procedure TPedometer.SetStopDetectionTimeout(aDuration: Single);
      begin
        if aDuration < 0 then
          raise EArgumentOutOfRangeException.Create('Value MUST be POSITIVE');
        FStopDetectionTimeout := aDuration;
      end;

    procedure TPedometer.SetStrideLenghtUserDefined(aLength: Single);
      begin
        if aLength < 0 then
          raise EArgumentOutOfRangeException.Create('Value MUST be POSITIVE');
        FStrideLenghtUserDefined := aLength;
      end;

    procedure TPedometer.SetStrideLengthComputed(aLength: Single);
      begin
        if aLength < 0 then
          raise EArgumentOutOfRangeException.Create('Value MUST be POSITIVE');
        FStrideLengthComputed := aLength;
      end;

    procedure TPedometer.SetWalkSteps(aQuantity: NativeUInt);
      begin
        FWalkSteps := aQuantity;
      end;

    procedure TPedometer.Start;
      begin
        // If motion sensor is available, start it, else raise exception?
        SetIsStarted(True);
      end;

    procedure TPedometer.Stop;
      begin
        if Assigned(FSensor) then
          begin
            if FIsStarted then
              begin
                // stop recording FSensor.OnDataChange events
                Save;
                SetIsStarted(False);
                Reset;
              end;
          end;
      end;

end.
