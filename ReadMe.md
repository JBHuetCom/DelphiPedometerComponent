#Pedometer
This component keeps count of steps using the accelerometer.

## Properties
*TCustomMotionSensor.AccelerationX*
Acceleration in gals for the X axis.
*TCustomMotionSensor.AccelerationY*
Acceleration in gals for the Y axis.
*TCustomMotionSensor.AccelerationZ*
Acceleration in gals for the Z axis.
*TCustomMotionSensor.AngleAccelX*
Angular acceleration in degrees per second squared for the X axis.
*TCustomMotionSensor.AngleAccelY*
Angular acceleration in degrees per second squared for the Y axis.
*TCustomMotionSensor.AngleAccelZ*
Angular acceleration in degrees per second squared for the Z axis.
*TCustomMotionSensor.AvailableProperties*
List of properties that this specific sensor can provide.
*TCustomMotionSensor.Category*
Category of the sensor.
*TCustomMotionSensor.CustomData*
Sensor-specific data fields.
*TCustomMotionSensor.CustomProperty*
Sensor-specific properties.
*TCustomMotionSensor.Description*
Description of the system sensor.
*TCustomMotionSensor.HasCustomData*
Specifies whether the system sensor has custom data with the specified index (True) or not (False).
*TCustomMotionSensor.HasCustomProperty*
Specifies whether the system sensor has a custom property with the specified index (True) or not (False).
*TCustomMotionSensor.Manager*
Manager that handles this sensor.
*TCustomMotionSensor.Manufacturer*
Manufacturer of the system sensor.
*TCustomMotionSensor.Model*
Model of the system sensor.
*TCustomMotionSensor.Motion*
Specifies whether the device is currently in motion (True) or not (False).
*TCustomMotionSensor.Name*
Name of the system sensor.
*TCustomMotionSensor.SensorType*
Type of the sensor.
*TCustomMotionSensor.SerialNo*
Serial number of the system sensor.
*TCustomMotionSensor.Speed*
Speed in meters per second.
*TCustomMotionSensor.Started*
Indicates whether the sensor is activated and ready.
*TCustomMotionSensor.State*
State of the sensor.
*TCustomMotionSensor.TimeStamp*
Date of the most recent measures that the sensor took.
*TCustomMotionSensor.UniqueID*
ID that uniquely identifies the sensor.
*TCustomMotionSensor.UpdateInterval*
Determines how often sensor data is updated in microseconds.
*TMotionSensor.Active*
Specifies whether the sensor is currently running (True) or stopped (False).
*TMotionSensor.Sensor*
Instance of a sensor associated with this sensor component.
*Distance*
- Type: Single
- Read / Write: Read Only
- Value constraint: positive ( >= 0)
- Visibility: Public
- Definition: Returns the approximate distance traveled in meters.
*ElapsedTime*
- Type: NativeUInt
- Read / Write: Read Only
- Visibility: Public
- Definition: Returns the time elapsed in milliseconds since the pedometer has started.
*SimpleSteps*
- Type: NativeUInt
- Read / Write: Read Only
- Visibility: Public
- Definition: Returns the number of simple steps taken since the pedometer has started.
*StopDetectionTimeout*
- Type: Single
- Read / Write: Read and Write
- Value constraint: positive ( >= 0)
- Visibility: Published
- Definition: Returns the duration of idleness (no steps detected) after which to go into a “stopped” state.
*StrideLengthComputed*
- Type: Single
- Read / Write: Read Only
- Value constraint: positive ( >= 0)
- Default value: 0.73
- Visibility: Public
- Definition: Returns the current estimate of stride length in meters, if calibrated, or returns the default (0.73 m) otherwise.
*StrideLenghtUserDefined*
- Type: Single
- Read / Write: Read and Write
- Value constraint: positive ( >= 0)
- Default value: 0.73
- Visibility: Published
- Definition: Returns the user defined stride length in meters, or returns the default (0.73 m) otherwise.
*WalkSteps*
- Type: NativeUInt
- Read / Write: Read Only
- Definition: Returns the number of walk steps taken since the pedometer has started.

## Fields
*FIsPaused*
- Type: Boolean
- Default value: False
- Visibility: Private
*FOnSimpleStep*
- Type: Event
- Visibility: Private
*FOnWalkStep*
- Type: Event
- Visibility: Private

## Events
*TCustomMotionSensor.OnDataChanged*
Occurs when the data measured by the sensor changes.
*TCustomMotionSensor.OnSensorRemoved*
Occurs right before a sensor is removed from the sensor manager.
*TCustomMotionSensor.OnStateChanged*
Occurs when the state of the sensor changes.
*OnSimpleStep(simpleSteps,distance)*
This event is run when a raw step is detected.
*OnWalkStep(walkSteps,distance)*
This event is run when a walking step is detected. A walking step is a step that appears to be involved in forward motion.

## Methods
*Start()*
Activates the sensor.
*Stop()*
Deactivates the sensor.
*Reset()*
Resets the step counter, distance measure and time running.
*Save()*
Saves the pedometer state to the phone. Permits permits accumulation of steps and distance between invocations of an App that uses the pedometer. Different Apps will have their own saved state.
*Pause()*
Pauses the pedometer.