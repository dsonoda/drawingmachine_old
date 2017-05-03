/**
 * The class for the operation of a drawing machine 
 * that draws using multiple motors.
 * @author Daisuke Sonoda / @5onod4 / dksonoda@gmail.com
 * @version 0.1
 */
import java.util.Map;

/**
 * Debug Mode.
 *  1: Display debugging value without moving the motor.
 *  0: Normal operation.
 */
int debugMode = 0;

/**
 * MotorOperation Object.
 * in charge of motor operation.
 */
MotorOperation mo;

/**
 * Raspberry Pi GPIO pin.
 */
// left stepping motor
int bsm_gpioPinA1_l = 12;
int bsm_gpioPinB1_l = 20;
int bsm_gpioPinA2_l = 16;
int bsm_gpioPinB2_l = 21;
// right stepping motor
int bsm_gpioPinA1_r = 18;
int bsm_gpioPinB1_r = 24;
int bsm_gpioPinA2_r = 23;
int bsm_gpioPinB2_r = 25;
// center servo motor
int sm_gpioPin = 13;

/**
 * Motor delay (unit: msec).
 */
int bsm_delay_l = 20;
int bsm_delay_r = 20;
int sm_delay = 2000;

/**
 * Motor excitation method mode.
 * @see BipolarSteppingMotor.ROTATE_MODE_1
 * @see BipolarSteppingMotor.ROTATE_MODE_2
 * @see BipolarSteppingMotor.ROTATE_MODE_1_2
 */
int bsm_rotateMode_l = BipolarSteppingMotor.ROTATE_MODE_1_2;
int bsm_rotateMode_r = BipolarSteppingMotor.ROTATE_MODE_1_2;

/**
 * Motor steps.
 */
int bsm_steps_l = 200;
int bsm_steps_r = 200;

/**
 * Motor radius (unit: mm).
 */
double bsm_radius_l = 23.6;
double bsm_radius_r = 23.6;

/**
 * Right motor x coordinate (unit: mm).
 * the coordinates of the drawing space are based on the center point of the left motor.
 * so, the x coordinate is 0 in the left motor, and an arbitrary value in the right motor,
 * and the y coordinate equals 0 on the left and right motors.
 */
double bsm_coordinate_x_r = 1400.0;

/**
 * Start draw coordinates (unit: mm).
 *  index 0: x
 *  index 1: y
 */
double[] startCoordinate = {450.0, 350.0};

/**
 * Servo angle.
 */
// draw
float sm_offAngle = 90.0;
// not draw
float sm_onAngle = 180.0;

/**
 * Initial setting values.
 */
// about integer
Map<String,Integer> initInt = new HashMap<String,Integer>();
// about float
Map<String, Float> initFloat = new HashMap<String,Float>();
// about double
Map<String, Double> initDouble = new HashMap<String,Double>();

/**
 * One step movement distance of the motor (unit: mm).
 */
double bsm_distancePer1step_l;
double bsm_distancePer1step_r;

/**
 * Output canvas size (unit: mm).
 */
double output_width = 600.0;
double output_height = 900.0;

/**
 * View canvas size.
 */
int size_width = 200;
int size_height = 400;




void setup()
{
    initInt.put("debugMode", debugMode);
    initInt.put("bsm_gpioPinA1_l", bsm_gpioPinA1_l);
    initInt.put("bsm_gpioPinB1_l", bsm_gpioPinB1_l);
    initInt.put("bsm_gpioPinA2_l", bsm_gpioPinA2_l);
    initInt.put("bsm_gpioPinB2_l", bsm_gpioPinB2_l);
    initInt.put("bsm_gpioPinA1_r", bsm_gpioPinA1_r);
    initInt.put("bsm_gpioPinB1_r", bsm_gpioPinB1_r);
    initInt.put("bsm_gpioPinA2_r", bsm_gpioPinA2_r);
    initInt.put("bsm_gpioPinB2_r", bsm_gpioPinB2_r);
    initInt.put("sm_gpioPin", sm_gpioPin);
    initInt.put("bsm_delay_l", bsm_delay_l);
    initInt.put("bsm_delay_r", bsm_delay_r);
    initInt.put("sm_delay", sm_delay);
    initInt.put("bsm_rotateMode_l", bsm_rotateMode_l);
    initInt.put("bsm_rotateMode_r", bsm_rotateMode_r);
    initInt.put("bsm_steps_l", bsm_steps_l);
    initInt.put("bsm_steps_r", bsm_steps_r);
    initFloat.put("sm_offAngle", sm_offAngle);
    initFloat.put("sm_onAngle", sm_onAngle);
    initDouble.put("bsm_radius_l", bsm_radius_l);
    initDouble.put("bsm_radius_r", bsm_radius_r);
    initDouble.put("bsm_coordinate_x_r", bsm_coordinate_x_r);
    initDouble.put("startCoordinate_x", startCoordinate[0]);
    initDouble.put("startCoordinate_y", startCoordinate[1]);

    /**
     * Motor operation instance object.
     */
    mo = new MotorOperation(initInt, initFloat, initDouble);






    // Get one step movement distance of the motor (unit: mm).
    bsm_distancePer1step_l = mo.getMotorDistancePer1Step(bsm_radius_l, bsm_steps_l);
    bsm_distancePer1step_r = mo.getMotorDistancePer1Step(bsm_radius_r, bsm_steps_r);








    mo.moveDrawCoordinate(500.0, 400.0);
    delay(1000);
    mo.moveDrawCoordinate(500.0, 450.0);





}

void draw()
{

}