unit Pedometer;

  interface

    uses
      System.SysUtils,
      System.Classes,
      System.Sensors,
      System.Sensors.Components,
      FMX.Types,
      FireDAC.Comp.Client;

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
          FTimer : TTimer;  // Is it really useful as FListPoints could store each point timestamp?
          FListPoints : TFDMemTable;
          // ??? missing field to record results when stopping pedometer ???
        protected
          procedure SetStopDetectionTimeout(const aDuration : Single); virtual;
          procedure SetStrideLenghtUserDefined(const aLength : Single); virtual;
          procedure SetDistance(const aLength : Single); virtual;
          procedure SetElapsedTime(const aDuration : NativeUInt); virtual;
          procedure SetSimpleSteps(const aQuantity : NativeUInt); virtual;
          procedure SetStrideLengthComputed(const aLength : Single); virtual;
          procedure SetWalkSteps(const aQuantity : NativeUInt); virtual;
          procedure SetSensitivity(const aValue : Double); virtual;
          function GetSensitivity : Double; virtual;
          procedure SetIsPaused(const aStatus : Boolean); virtual;
          procedure SetIsStarted(const aStatus : Boolean); virtual;
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
          property StrideLengthComputed : Single read FStrideLengthComputed;
          property WalkSteps : NativeUInt read FWalkSteps;
          property IsPaused : Boolean read FIsPaused default False;
          property IsStarted : Boolean read FIsStarted default False;
        published
          property StopDetectionTimeout : Single read FStopDetectionTimeout write SetStopDetectionTimeout;
          property StrideLenghtUserDefined : Single read FStrideLenghtUserDefined write SetStrideLenghtUserDefined;
          property Sensitivity : Double read GetSensitivity write SetSensitivity;
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
        if TSensorManager.Current.CanActivate then
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
                       // initialize MemTable with fields: 1 field for each property of sensor available (depends on hardware and plateform) + timestamp
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

    function TPedometer.GetSensitivity: Double;
      begin
        Result := 0.0;
        if Assigned(FSensor) then
          Result := FSensor.UpdateInterval;
      end;

    procedure TPedometer.Pause;
      begin
        if Assigned(FSensor) then
          begin
            if IsStarted then
              begin
                if IsPaused then
                  begin
                    {
                    stop recording FSensor.OnDataChange events
                    pause FTimer
                    }
                  end
                else
                  begin
                    {
                    start recording FSensor.OnDataChange events
                    restart FTimer
                    }
                  end;
                IsPaused := not IsPaused;
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
        StopDetectionTimeout := 10000.0;
        SetStrideLengthComputed(0.73);
        StrideLenghtUserDefined := 0.73;
        Sensitivity := 50000;
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

    procedure TPedometer.SetDistance(const aLength: Single);
      begin
        if aLength < 0 then
          raise EArgumentOutOfRangeException.Create('Value MUST be POSITIVE');
        FDistance := aLength;
      end;

    procedure TPedometer.SetElapsedTime(const aDuration: NativeUInt);
      begin
        FElapsedTime := aDuration;
      end;

    procedure TPedometer.SetIsPaused(const aStatus: Boolean);
      begin
        FIsPaused := aStatus;
      end;

    procedure TPedometer.SetIsStarted(const aStatus: Boolean);
      begin
        FIsStarted := aStatus;
      end;

    procedure TPedometer.SetSensitivity(const aValue: Double);
      begin
        if Assigned(FSensor) then
          FSensor.UpdateInterval := aValue;
      end;

    procedure TPedometer.SetSimpleSteps(const aQuantity: NativeUInt);
      begin
        FSimpleSteps := aQuantity;
      end;

    procedure TPedometer.SetStopDetectionTimeout(const aDuration: Single);
      begin
        if aDuration < 0 then
          raise EArgumentOutOfRangeException.Create('Value MUST be POSITIVE');
        FStopDetectionTimeout := aDuration;
      end;

    procedure TPedometer.SetStrideLenghtUserDefined(const aLength: Single);
      begin
        if aLength < 0 then
          raise EArgumentOutOfRangeException.Create('Value MUST be POSITIVE');
        FStrideLenghtUserDefined := aLength;
      end;

    procedure TPedometer.SetStrideLengthComputed(const aLength: Single);
      begin
        if aLength < 0 then
          raise EArgumentOutOfRangeException.Create('Value MUST be POSITIVE');
        FStrideLengthComputed := aLength;
      end;

    procedure TPedometer.SetWalkSteps(const aQuantity: NativeUInt);
      begin
        FWalkSteps := aQuantity;
      end;

    procedure TPedometer.Start;
      begin
        if Assigned(FSensor) then
          IsStarted := True;
        {
        - start timer
        - start recording FSensor.OnDataChange events
        }
      end;

    procedure TPedometer.Stop;
      begin
        if Assigned(FSensor) then
          begin
            if IsStarted then
              begin
                // stop recording FSensor.OnDataChange events
                Save;
                IsStarted := False;
                Reset;
              end;
          end;
      end;

end.
