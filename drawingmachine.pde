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
// left motor
int m_gpioPinA1_l = 12;
int m_gpioPinB1_l = 20;
int m_gpioPinA2_l = 16;
int m_gpioPinB2_l = 21;
// right motor
int m_gpioPinA1_r = 18;
int m_gpioPinB1_r = 24;
int m_gpioPinA2_r = 23;
int m_gpioPinB2_r = 25;

/**
 * Motor delay (unit: msec).
 */
int m_delay_l = 20;
int m_delay_r = 20;

/**
 * Motor excitation method mode.
 * @see BipolarSteppingMotor.M_ROTATE_MODE_1
 * @see BipolarSteppingMotor.M_ROTATE_MODE_2
 * @see BipolarSteppingMotor.M_ROTATE_MODE_1_2
 */
int m_rotateMode_l = BipolarSteppingMotor.ROTATE_MODE_1_2;
int m_rotateMode_r = BipolarSteppingMotor.ROTATE_MODE_1_2;

/**
 * Motor steps.
 */
int m_steps_l = 200;
int m_steps_r = 200;

/**
 * Motor radius (unit: mm).
 */
double m_radius_l = 50.0;
double m_radius_r = 50.0;

/**
 * Right motor x coordinate (unit: mm).
 * the coordinates of the drawing space are based on the center point of the left motor.
 * so, the x coordinate is 0 in the left motor, and an arbitrary value in the right motor,
 * and the y coordinate equals 0 on the left and right motors.
 */
double m_coordinate_x_r = 250.0;

/**
 * Start draw coordinates (unit: mm).
 *  index 0: x
 *  index 1: y
 */
double[] startCoordinate = {70.0, 10.0};

/**
 * Initial setting values.
 */
// about integer
Map<String,Integer> initInt = new HashMap<String,Integer>();
// about double
Map<String, Double> initDouble = new HashMap<String,Double>();

/**
 * One step movement distance of the motor (unit: mm).
 */
double m_distancePer1step_l;
double m_distancePer1step_r;

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
    initInt.put("m_gpioPinA1_l", m_gpioPinA1_l);
    initInt.put("m_gpioPinB1_l", m_gpioPinB1_l);
    initInt.put("m_gpioPinA2_l", m_gpioPinA2_l);
    initInt.put("m_gpioPinB2_l", m_gpioPinB2_l);
    initInt.put("m_gpioPinA1_r", m_gpioPinA1_r);
    initInt.put("m_gpioPinB1_r", m_gpioPinB1_r);
    initInt.put("m_gpioPinA2_r", m_gpioPinA2_r);
    initInt.put("m_gpioPinB2_r", m_gpioPinB2_r);
    initInt.put("m_delay_l", m_delay_l);
    initInt.put("m_delay_r", m_delay_r);
    initInt.put("m_rotateMode_l", m_rotateMode_l);
    initInt.put("m_rotateMode_r", m_rotateMode_r);
    initInt.put("m_steps_l", m_steps_l);
    initInt.put("m_steps_r", m_steps_r);
    initDouble.put("m_radius_l", m_radius_l);
    initDouble.put("m_radius_r", m_radius_r);
    initDouble.put("m_coordinate_x_r", m_coordinate_x_r);
    initDouble.put("startCoordinate_x", startCoordinate[0]);
    initDouble.put("startCoordinate_y", startCoordinate[1]);
    mo = new MotorOperation(initInt, initDouble);

    m_distancePer1step_l = mo.getMotorDistancePer1Step(m_radius_l, m_steps_l);
    m_distancePer1step_r = mo.getMotorDistancePer1Step(m_radius_r, m_steps_r);


    mo.moveDrawCoordinate(100.0, 20.0);
    delay(1000);
    mo.moveDrawCoordinate(70.0, 10.0);





}

void draw()
{

}