unit Pedometer;

  interface

    uses
      System.SysUtils, System.Classes, System.Sensors.Components, FMX.Types, FireDAC.Comp.Client;

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
          FTimer : TTimer;
          FListPoints : TFDMemTable; // for recording mesures
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
          procedure SetFIsPaused(aStatus : Boolean); virtual;
          procedure SetFIsStarted(aStatus : Boolean); virtual;
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
          property StrideLengthComputed : Single read FStrideLengthComputed default 0.73;
          property WalkSteps : NativeUInt read FWalkSteps;
          property IsPaused : Boolean read FIsPaused default False;
          property IsStarted : Boolean read FIsStarted default False;
        published
          property StopDetectionTimeout : Single read FStopDetectionTimeout write SetStopDetectionTimeout default 10000.0;
          property StrideLenghtUserDefined : Single read FStrideLenghtUserDefined write SetStrideLenghtUserDefined default 0.73;
          property Sensitivity : NativeUInt read FSensitivity write FSensitivity default 50000;
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
        FSensor := TMotionSensor.Create;
        try
          FTimer := TTimer.Create;
          try
            FListPoints := TFDMemTable.Create;
            try
              { If motion sensor is available and active:
                - initialize MemTable with fields: 1 field for each property of sensor available (depends on hardware and plateform)
                - initialize FSensor.UpdateInterval to FSensitivity
                - initialize computed and user defined stride lengths
                - initialize detection timeout
                }
            except
              FListPoints.Free;
            end;
          except on E: Exception do
            FTimer.Free;
          end;
        except on E: Exception do
          FSensor.Free;
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

    procedure TPedometer.Reset;
      begin
        {
        - clear FListPoints
        - reset FTimer
        - set default values for every field
        }
      end;

    procedure TPedometer.Save;
      begin
        // should be delegated to owner application?
      end;

    function TPedometer.SensorInfo : TStringList;
      begin
        // something similar to https://docwiki.embarcadero.com/CodeExamples/Sydney/en/FMX.SensorInfo_Sample
      end;

    procedure TPedometer.SetDistance(aLength: Single);
      begin

      end;

    procedure TPedometer.SetElapsedTime(aDuration: NativeUInt);
      begin

      end;

    procedure TPedometer.SetFIsPaused(aStatus: Boolean);
      begin
        FIsPaused := aStatus;
      end;

    procedure TPedometer.SetFIsStarted(aStatus: Boolean);
      begin
        FIsStarted := aStatus;
      end;

    procedure TPedometer.SetSimpleSteps(aQuantity: NativeUInt);
      begin

      end;

    procedure TPedometer.SetStopDetectionTimeout(aDuration: Single);
      begin
        // Raise exception if negative value
      end;

    procedure TPedometer.SetStrideLenghtUserDefined(aLength: Single);
      begin
        // Raise exception if negative value
      end;

    procedure TPedometer.SetStrideLengthComputed(aLength: Single);
      begin
        // Raise exception if negative value
      end;

    procedure TPedometer.SetWalkSteps(aQuantity: NativeUInt);
      begin

      end;

    procedure TPedometer.Start;
      begin
        // If motion sensor is available, start it, else raise exception?
        SetFIsStarted(True);
      end;

    procedure TPedometer.Stop;
      begin
        // stop recording FSensor.OnDataChange events
        // save results somewhere...
        SetFIsStarted(False);
        Reset;
      end;

end.
