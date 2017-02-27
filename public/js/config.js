class Config {
  constructor() {
    console.log("INIT: Config");
  }
  getConfig() {
    console.log("Getting config...");
    // $.ajax({
    //   url: "/config/get/"+getRobotIP(),
    // }).done(function(result) {
    //   console.log(result);
    //   $("#editor").text(result);
    // });

    var tempConfig = `##Config File
#################################
AutoAimP = 0.12
AutoAimI = 0.0
AutoAimD = 0.0

#Swerve Variables:
speedP = 2
speedI = 0.01
speedD = 0

steerP = 1.2
steerI = 0
steerD = 0

steerPFR = 1.1
steerIFR = 0
SteerDFR = 0

steerPFL = 1.1
steerIFL = 0
SteerDFL = 0

steerPBR = 1.1
steerIBR = 0
SteerDBR = 0

steerPBL = 1.1
steerIBL = 0
SteerDBL = 0

#.25
SteeringTolerance = .1
SteerSpeed = 1
turningSpeedFactor = 1
driveCIMmaxRPM = 4200

#SteerEncMax = 4.79
SteerEncMaxBL = 4.968
SteerEncMaxBR = 4.9504
SteerEncMaxFL = 4.97377
SteerEncMaxFR = 4.942251

SteerEncOffsetFR = -0.81
SteerEncOffsetFL = -5.40
SteerEncOffsetBR = -3.25
SteerEncOffsetBL = -1.6

FrameLength = 22.55
FrameWidth = 26.75
#################################`;

    editor.setValue(tempConfig);
    editor.gotoLine(0);
  }
  pushConfig() {
    var confirm = window.confirm("Are you sure you want to push?");
    if (confirm) {
      console.log("Pushing config...");
    }
  }
}
