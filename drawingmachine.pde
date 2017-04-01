/**
 * The class for the operation of a drawing machine 
 * that draws using multiple motors.
 * @author Daisuke Sonoda / @5onod4 / dksonoda@gmail.com
 * @version 0.1
 */

//import processing.io.*;
import java.util.HashMap;


/**
 * MotorOperation Object
 * in charge of motor operation.
 */
MotorOperation mo;

/**
 * raspberry pi GPIO pin.
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
 * motor delay (unit: msec)
 */
int m_delay_l = 5;
int m_delay_r = 5;

/**
 * motor excitation method mode
 * @see BipolarSteppingMotor.M_ROTATE_MODE_1
 * @see BipolarSteppingMotor.M_ROTATE_MODE_2
 * @see BipolarSteppingMotor.M_ROTATE_MODE_1_2
 */
int m_rotateMode_l = BipolarSteppingMotor.ROTATE_MODE_1_2;
int m_rotateMode_r = BipolarSteppingMotor.ROTATE_MODE_1_2;

/**
 * motor steps
 */
int m_steps_l = 200;
int m_steps_r = 200;

/**
 * motor radius (unit: mm)
 */
double m_radius_l = 5.0;
double m_radius_r = 5.0;

/**
 * motor center coodinate (unit: mm)
 */
// left motor
double[] m_coordinate_l = {0.0, 0.0};
// right motor
double[] m_coordinate_r = {250.0, 0.0};

/**
 * start draw coordinates (unit: mm)
 *  index 0: x
 *  index 1: y
 */
double[] startCoordinate = {70.0, 10.0};

/**
 * initial setting values
 */
// about integer
Map<String,Integer> initInt = new HashMap<String,Integer>();
// about double
Map<String, Double> initDouble = new HashMap<String,Double>();

/**
 * moving distance around 1 step of the motor (unit: mm)
 */
double m_distPer1step_l = MotorOperation.getMotorDistPer1Step(m_radius_l, m_steps_l);
double m_distPer1step_r = MotorOperation.getMotorDistPer1Step(m_radius_r, m_steps_r);

/**
 * output canvas size (unit: mm)
 */
double output_width = 600.0;
double output_height = 900.0;

/**
 * view canvas size
 */
int size_width = 200;
int size_height = 400;




void setup()
{
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
    initDouble.put("m_coordinate_x_l", m_coordinate_l[0]);
    initDouble.put("m_coordinate_y_l", m_coordinate_l[1]);
    initDouble.put("m_coordinate_x_r", m_coordinate_r[0]);
    initDouble.put("m_coordinate_y_r", m_coordinate_r[1]);
    initDouble.put("startCoordinate_x", startCoordinate[0]);
    initDouble.put("startCoordinate_y", startCoordinate[1]);
    mo = new MotorOperation(this, initInt, initDouble);

    size(size_width, size_height);



    println(mo.getContactCoodinate('r', startCoordinate[0], startCoordinate[1]));



}

void draw()
{

}