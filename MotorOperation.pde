/**
 * The class for the operation of a drawing machine that draws using multiple motors.
 * @author Daisuke Sonoda / @5onod4 / dksonoda@gmail.com
 * @version 0.1
 */
import java.util.*;

class MotorOperation
{
    /**
     * Debug Mode.
     *  1: Display debugging value without moving the motor.
     *  0: Normal operation.
     */
    private int debugMode = 0;

    /**
     * Stepping Motor objects.
     */
    private BipolarSteppingMotor motorL;
    private BipolarSteppingMotor motorR;

    /**
     * Servo Motor objects.
     */
    private SoftwareServo servo1;

    /**
     * Error message.
     */
    private String errorMessage;

    /**
     * Number of motor steps per 1 rotation.
     */
    private int bsm_steps_l;
    private int bsm_steps_r;

    /**
     * Center coordinates of the right motor (unit: mm).
     */
    private double bsm_coordinate_x_r;

    /**
     * Motor radius (unit: mm).
     */
    private double bsm_radius_l;
    private double bsm_radius_r;

    /**
     * Motor circumference (unit: mm).
     */
    private double bsm_cicumference_l;
    private double bsm_cicumference_r;

    /**
     * Movement distance per 1 step of the motor (unit: mm).
     */
    private double bsm_distancePer1Step_l;
    private double bsm_distancePer1Step_r;

    /**
     * Calculated values to be prepared for subsequent processing.
     */
    // rasius to the second power
    private double pow2Radius_l;
    private double pow2Radius_r;
    // rasius to the fourth power
    private double pow4Radius_l;
    private double pow4Radius_r;
    // 2 times rasius to the second power
    private double times2Pow2Radius_l;
    private double times2Pow2Radius_r;
    // 4 times rasius to the fourth power
    private double times4Pow4Radius_l;
    private double times4Pow4Radius_r;

    /**
     * Number of current movement steps.
     */
    private int currentSteps_l;
    private int currentSteps_r;

    /**
     * Current draw point coordinates (unit: mm).
     * index 0: x coordinate, 1:y coordinate.
     */
    private double[] currentCoordinate = new double[2];

    /**
     * Servo delay.
     */
    private int sm_delay;

    /**
     * Servo angle.
     */
    // draw
    private float sm_offAngle;
    // not draw
    private float sm_onAngle;


    /**
     * Constructor.
     * @param initInt: about integer initial setting.
     * @param initFloat: about float initial setting.
     * @param initDouble: about double initial setting.
     */
    public MotorOperation(
        Map<String,Integer> initInt,
        Map<String,Float> initFloat,
        Map<String,Double> initDouble
    ) {
        // validation
        if (!this.hasInit(initInt, initFloat, initDouble)) {
            throw new RuntimeException(this.getErrorMessage());
        }

        // set debug mode
        this.debugMode = initInt.get("debugMode");
        if (this.debugMode == 1) {
            println("*** constructor ***");
        }

        /**
         * instance object of left motor.
         */
        this.motorL = new BipolarSteppingMotor(
            initInt.get("bsm_gpioPinA1_l"),
            initInt.get("bsm_gpioPinB1_l"),
            initInt.get("bsm_gpioPinA2_l"),
            initInt.get("bsm_gpioPinB2_l"),
            initInt.get("bsm_delay_l"),
            initInt.get("bsm_rotateMode_l")
        );
        // energize the motor and fix the pulley.
        this.motorL.rotateRight(1);
        this.motorL.rotateLeft(1);

        /**
         * instance object of right motor.
         */
        this.motorR = new BipolarSteppingMotor(
            initInt.get("bsm_gpioPinA1_r"),
            initInt.get("bsm_gpioPinB1_r"),
            initInt.get("bsm_gpioPinA2_r"),
            initInt.get("bsm_gpioPinB2_r"),
            initInt.get("bsm_delay_r"),
            initInt.get("bsm_rotateMode_r")
        );
        // energize the motor and fix the pulley.
        this.motorR.rotateRight(1);
        this.motorR.rotateLeft(1);

        /**
         * instance object of servo motor.
         */
        this.servo1 = new SoftwareServo(this);
        this.servo1.attach(initInt.get("sm_gpioPin"));
        this.sm_delay = initInt.get("sm_delay");
        this.sm_offAngle = initFloat.get("sm_offAngle");
        this.sm_onAngle = initFloat.get("sm_onAngle");
        // servo initial setting.
        this.drawOff();


        this.bsm_steps_l = this.motorL.getSteps(initInt.get("bsm_steps_l"));
        this.bsm_steps_r = this.motorR.getSteps(initInt.get("bsm_steps_r"));

        this.bsm_radius_l = initDouble.get("bsm_radius_l");
        this.bsm_radius_r = initDouble.get("bsm_radius_r");

        this.bsm_cicumference_l = getMotorCircumference(this.bsm_radius_l);
        this.bsm_cicumference_r = getMotorCircumference(this.bsm_radius_r);

        this.bsm_distancePer1Step_l = getMotorDistancePer1Step(this.bsm_radius_l, this.bsm_steps_l);
        this.bsm_distancePer1Step_r = getMotorDistancePer1Step(this.bsm_radius_r, this.bsm_steps_r);

        this.pow2Radius_l = Math.pow(this.bsm_radius_l, 2);
        this.pow2Radius_r = Math.pow(this.bsm_radius_r, 2);
        this.pow4Radius_l = Math.pow(this.bsm_radius_l, 4);
        this.pow4Radius_r = Math.pow(this.bsm_radius_r, 4);
        this.times2Pow2Radius_l = 2 * this.pow2Radius_l;
        this.times2Pow2Radius_r = 2 * this.pow2Radius_r;
        this.times4Pow4Radius_l = 4 * this.pow4Radius_l;
        this.times4Pow4Radius_r = 4 * this.pow4Radius_r;

        /**
         * set motor center point coordinate.
         */
        this.bsm_coordinate_x_r = initDouble.get("bsm_coordinate_x_r");

        /**
         * set current draw point coordinate.
         */
        this.setCurrentCoordinate(initDouble.get("startCoordinate_x"), initDouble.get("startCoordinate_y"));

        /**
         * set number of start movement steps.
         */
        this.currentSteps_l = this.getDistanceSteps('l', initDouble.get("startCoordinate_x"), initDouble.get("startCoordinate_y"));
        this.currentSteps_r = this.getDistanceSteps('r', initDouble.get("startCoordinate_x"), initDouble.get("startCoordinate_y"));

        if (this.debugMode == 1) {
            println("currentCoordinate_l="+this.getCurrentCoordinate(0));
            println("currentCoordinate_r="+this.getCurrentCoordinate(1));
            println("currentSteps_l="+this.currentSteps_l);
            println("currentSteps_r="+this.currentSteps_r);
            println("");
            println("");
        }
    }

    /**
     * Checks whether initial setting information of integer and double type exists.
     * @param initInt
     * @param initFloat
     * @param initDouble
     * @see When the setting value added,
     *      it is necessary to add additional information to a 'checkInitInt' or 'checkInitDouble' variable.
     * @return true: validation ok.
     */
    private boolean hasInit(Map<String,Integer> initInt, Map<String,Float> initFloat, Map<String,Double> initDouble)
    {
        // initial setting value of integer
        String [] checkInitInt = {
            "debugMode",
            "bsm_gpioPinA1_l", "bsm_gpioPinB1_l", "bsm_gpioPinA2_l", "bsm_gpioPinB2_l",
            "bsm_gpioPinA1_r", "bsm_gpioPinB1_r", "bsm_gpioPinA2_r", "bsm_gpioPinB2_r",
            "sm_gpioPin", 
            "bsm_delay_l", "bsm_delay_r",
            "sm_delay", 
            "bsm_steps_l", "bsm_steps_r",
            "bsm_rotateMode_l", "bsm_rotateMode_r",
        };

        // initial setting value of float
        String [] checkInitFloat = {
            "sm_offAngle", "sm_onAngle",
        };

        // initial setting value of double
        String [] checkInitDouble = {
            "bsm_radius_l", "bsm_radius_r",
            "bsm_coordinate_x_r",
            "startCoordinate_x", "startCoordinate_y",
        };

        for (int i = 0; i < checkInitInt.length; i++) {
            if (!initInt.containsKey(checkInitInt[i])) {
                this.setErrorMessage("Initial setting value of integer type is insufficient.");
                return false;
            }
        }

        for (int i = 0; i < checkInitFloat.length; i++) {
            if (!initFloat.containsKey(checkInitFloat[i])) {
                this.setErrorMessage("Initial setting value of float type is insufficient.");
                return false;
            }
        }

        for (int j = 0; j < checkInitDouble.length; j++) {
            if (!initDouble.containsKey(checkInitDouble[j])) {
                this.setErrorMessage("Initial setting value of double type is insufficient.");
                return false;
            }
        }

        if ((initDouble.get("bsm_radius_l") + initDouble.get("bsm_radius_r")) >= initDouble.get("bsm_coordinate_x_r")) {
            this.setErrorMessage("'bsm_coordinate_x_r' value must be greater than 'bsm_radius_l' + 'bsm_radius_r'.");
            return false;
        }

        return true;
    }

    /**
     * Set error message.
     * @param message: error message.
     */
    protected void setErrorMessage(String message)
    {
        this.errorMessage = message;
    }

    /**
     * Get error message.
     * @return error message.
     */
    public String getErrorMessage()
    {
        return this.errorMessage;
    }

    /**
     * Set current draw point coordinate
     * @param x coordinate (unit: mm)
     * @param y coordinate (unit: mm)
     */
    private void setCurrentCoordinate(double x, double y)
    {
        this.currentCoordinate[0] = x;
        this.currentCoordinate[1] = y;
    }

    /**
     * Get cuurent draw point coordinate
     * @param index 0:x coordinate / 1:y coordinate
     * @return double
     */
    public double getCurrentCoordinate(int index)
    {
        if (index == 0 || index == 1) {
            return this.currentCoordinate[index];
        }
        return 0.0;
    }

    /**
     * Move the drawing point by number of steps.
     * @param steps_l: left motor steps
     * @param steps_r: right motor steps
     */
    public void moveDrawStep(int steps_l, int steps_r)
    {
        if (steps_l < 0) {
            this.motorL.rotateLeft(steps_l * -1);
            this.currentSteps_l -= steps_l;
        } else if (0 < steps_l) {
            this.motorL.rotateRight(steps_l);
            this.currentSteps_l += steps_l;
        }

        if (steps_r < 0) {
            this.motorR.rotateRight(steps_r * -1);
            this.currentSteps_r -= steps_r;
        } else if (0 < steps_r) {
            this.motorR.rotateLeft(steps_r);
            this.currentSteps_r += steps_r;
        }

        if (this.debugMode == 1) {
            println("*** moveDrawStep() ***");
            println("currentCoordinate_l="+this.getCurrentCoordinate(0));
            println("currentCoordinate_r="+this.getCurrentCoordinate(1));
            println("currentSteps_l="+this.currentSteps_l);
            println("currentSteps_r="+this.currentSteps_r);
            println("");
            println("");
        }
    }

    /**
     * Move to the drawing point with the specified coordinates.
     * @param to_x: to x coordinate
     * @param to_y: to y coordinate
     */
    public void moveDrawCoordinate(double to_x, double to_y)
    {
        if (this.debugMode == 1) {
            println("*** moveDrawCoordinate() ***");
        }

        // calculate left motor rotation steps
        int toSteps_l = this.getDistanceSteps('l', to_x, to_y);
        // motor rotate
        if (this.currentSteps_l > toSteps_l) {
            if (this.debugMode == 0) {
                this.motorL.rotateLeft(this.currentSteps_l - toSteps_l);
            }
        } else if (toSteps_l > this.currentSteps_l) {
            if (this.debugMode == 0) {
                this.motorL.rotateRight(toSteps_l - this.currentSteps_l);
            }
        }
        this.currentSteps_l = toSteps_l;

        // calculate right motor rotation steps
        int toSteps_r = this.getDistanceSteps('r', to_x, to_y);
        // motor rotate
        if (this.currentSteps_r > toSteps_r) {
            if (this.debugMode == 0) {
                this.motorR.rotateRight(this.currentSteps_r - toSteps_r);
            }
        } else if (toSteps_r > this.currentSteps_r) {
            if (this.debugMode == 0) {
                this.motorR.rotateLeft(toSteps_r - this.currentSteps_r);
            }
        }
        this.currentSteps_r = toSteps_r;

        // keeping current accurate coordinates corrected for errors (unit: mm)
        this.setCurrentCoordinate(to_x, to_y);

        if (this.debugMode == 1) {
            println("currentCoordinate_l="+this.getCurrentCoordinate(0));
            println("currentCoordinate_r="+this.getCurrentCoordinate(1));
            println("currentSteps_l="+this.currentSteps_l);
            println("currentSteps_r="+this.currentSteps_r);
            println("");
            println("");
        }
    }

    /**
     * calculate the contact coordinates of circle and line containing the draw point,
     * and the contact coordinates of circle and motor circle top point,
     * and convert distance to steps.
     * @param bsm_position: motor position ('l' or 'r').
     * @param x: current draw x coordinate (unit: mm).
     * @param y: current draw y coordinate (unit: mm).
     * @return steps
     */
    private int getDistanceSteps(char bsm_position, double x, double y)
    {
        double bsm_coordinate_x;
        double bsm_cicumference;
        double bsm_distancePer1Step;
        double pow2Radius;
        double pow4Radius;
        double times2Pow2Radius;
        double times4Pow4Radius;
        switch (bsm_position) {
            // left motor
            case 'l':
                bsm_coordinate_x = 0.0;
                bsm_cicumference = this.bsm_cicumference_l;
                bsm_distancePer1Step = this.bsm_distancePer1Step_l;
                pow2Radius = this.pow2Radius_l;
                pow4Radius = this.pow4Radius_l;
                times2Pow2Radius = this.times2Pow2Radius_l;
                times4Pow4Radius = this.times4Pow4Radius_l;
                break;
            // right motor
            case 'r':
                bsm_coordinate_x = this.bsm_coordinate_x_r;
                bsm_cicumference = this.bsm_cicumference_r;
                bsm_distancePer1Step = this.bsm_distancePer1Step_r;
                pow2Radius = this.pow2Radius_r;
                pow4Radius = this.pow4Radius_r;
                times2Pow2Radius = this.times2Pow2Radius_r;
                times4Pow4Radius = this.times4Pow4Radius_r;
                break;
            default:
                return 0;
        }

        // get contact coordinates of motor circle and line containing the draw point
        double[] contactCoordinate = getContactCoordinate(
            x,
            y,
            bsm_coordinate_x,
            pow2Radius,
            pow4Radius,
            times2Pow2Radius,
            times4Pow4Radius
        );

        // get radian of contact coordinates of motor circle and line containing the draw point
        double radian = getAtan2(bsm_coordinate_x, 0.0, contactCoordinate[0], contactCoordinate[1]);

        // get the distance from the top of the circle of motor to the draw point
        double distance = getArcDistance(bsm_cicumference, ((Math.PI / 2) - radian)) + getDistance(contactCoordinate[0], contactCoordinate[1], x, y);

        if (this.debugMode == 1) {
            println("bsm_position="+bsm_position);
            println("contactCoordinate x="+contactCoordinate[0]);
            println("contactCoordinate y="+contactCoordinate[1]);
            println("radian="+radian);
            println("distance="+distance);
        }

        // convert distance to steps and return
        return convertDistance2Steps(distance, bsm_distancePer1Step);
    }

    /**
     * calculate the contact coordinates of motor circle and line containing the draw point.
     * @param x: current draw x coordinate (unit: mm).
     * @param y: current draw y coordinate (unit: mm).
     * @param bsm_coordinate_x: motor coordinate x (unit: mm).
     * @param pow2Radius
     * @param pow4Radius
     * @param times2Pow2Radius
     * @param times4Pow4Radius
     * @return coordinate
     *  index 0: x (unit: mm)
     *  index 1: y (unit: mm)
     */
    private final double[] getContactCoordinate(
        double x,
        double y,
        double bsm_coordinate_x,
        double pow2Radius,
        double pow4Radius,
        double times2Pow2Radius,
        double times4Pow4Radius
    ) {
        double[] coordinate = new double[2];
        double[] tmpCoordinate = new double[4];
        double currentCoordinateMinus_x = x - bsm_coordinate_x;
        double pow2_x = Math.pow(currentCoordinateMinus_x, 2);
        double pow2_y = Math.pow(y, 2);

        double discriminant = (times4Pow4Radius * pow2_x) - (4 * (pow2_x + pow2_y) * (pow4Radius - (pow2Radius * pow2_y)));
        double val1 = times2Pow2Radius * currentCoordinateMinus_x;
        double val2 = 2 * (pow2_x + pow2_y);

        if (discriminant > 0) {
            tmpCoordinate[0] = ((val1 + Math.sqrt(discriminant)) / val2) + bsm_coordinate_x;
            tmpCoordinate[1] = ((val1 - Math.sqrt(discriminant)) / val2) + bsm_coordinate_x;
        } else if (discriminant == 0) {
            tmpCoordinate[0] = (val1 / val2) + bsm_coordinate_x;
            tmpCoordinate[1] = tmpCoordinate[0];
        } else {
            tmpCoordinate[0] = (val1 / val2) + bsm_coordinate_x;
            tmpCoordinate[1] = (Math.sqrt(discriminant) / val2) + bsm_coordinate_x;
        }

        tmpCoordinate[2] = (pow2Radius - (currentCoordinateMinus_x * (tmpCoordinate[0] - bsm_coordinate_x))) / y;

        // adopte the contact coordinates of which the y coordinate of the contact point is a value what less than or equal to 0
        if (tmpCoordinate[2] <= 0) {
            coordinate[0] = tmpCoordinate[0];
            coordinate[1] = tmpCoordinate[2];
        } else {
            coordinate[0] = tmpCoordinate[1];
            coordinate[1] = (pow2Radius - (currentCoordinateMinus_x * (tmpCoordinate[1] - bsm_coordinate_x))) / y;
        }

        return coordinate;
    }

    /**
     * Gget string concatenation value.
     * @param bsm_position: motor position ('l' or 'r').
     * @param param_name: parameter name.
     * @return Concatenated character string.
     */
    protected final String getConsolidatedString(char bsm_position, String param_name)
    {
        StringBuilder buff = new StringBuilder();
        buff.append(param_name);
        buff.append("_");
        buff.append(bsm_position);
        return buff.toString();
    }

    /**
     * calculate and get motor circumference.
     * @param radius: motor radius.
     * @return motor circumference (unit: mm).
     */
    public final double getMotorCircumference(double radius)
    {
        return 2 * radius * Math.PI;
    }

    /**
     * calculate and get moving distance around 1 step of the motor.
     * @param radius: motor radius.
     * @param steps: motor steps per 1 around.
     * @return moving distance around 1 step of the motor (unit: mm).
     */
    public double getMotorDistancePer1Step(double radius, double steps)
    {
        return getMotorCircumference(radius) / steps;
    }

    /**
     * calculate and get radian value of contact coordinates of circle and line including draw point.
     * @param center_x: motor coordinate x (unit: mm).
     * @param center_y: motor coordinate y (unit: mm).
     * @param contact_x: contact coordinate x (unit: mm).
     * @param contact_y: contact coordinate y (unit: mm).
     * @return radian
     */
    private final double getAtan2(double center_x, double center_y, double contact_x, double contact_y) {
        return Math.atan2(prepareCalcCoordinate(center_y, contact_y), prepareCalcCoordinate(center_x, contact_x));
    }

    /**
     * common processing within getAtan2() method.
     * Lambda expression can not be used, becourse Java 8 is not supported in proce55ing. So, use static method.
     * @see https://github.com/processing/processing/issues/3411
     * @param centerCoordinate
     * @param contactCoordinate
     * @return
     */
    private final double prepareCalcCoordinate(double centerCoordinate, double contactCoordinate)
    {
        if (centerCoordinate != 0) {
            contactCoordinate -= centerCoordinate;
        }
        if (contactCoordinate < 0) {
            contactCoordinate *= -1;
        }
        return contactCoordinate;
    }

    /**
     * calculate and get the length of arc from circumference and radian value.
     * @param circumference: motor circumference.
     * @param radian: radian value.
     * @return distance of arc (unit: mm).
     */
    private final double getArcDistance(double circumference, double radian)
    {
        return circumference * (radian / (2 * Math.PI));
    }

    /**
     * Calculate and get the distance between two points.
     * @param from_x
     * @param from_y
     * @param to_x
     * @param to_y
     * @return
     */
    private final double getDistance(double from_x, double from_y, double to_x, double to_y)
    {
        double distance_x = (from_x - to_x);
        if (distance_x < 0) {
            distance_x *= -1;
        }
        double distance_y = (from_y - to_y);
        if (distance_y < 0) {
            distance_y *= -1;
        }
        return Math.sqrt(Math.pow(distance_x, 2) + Math.pow(distance_y, 2));
    }

    /**
     * calculate and get the number of moving steps.
     * @param distance: moving distance (unit: mm).
     * @param bsm_distancePer1Step: moving distance per motor 1 step (unit: mm).
     * @return number of moving steps.
     */
    private final int convertDistance2Steps(double distance, double bsm_distancePer1Step)
    {
        return (int) Math.round(distance / bsm_distancePer1Step);
    }

    /**
     * Contact pen with canvas.
     */
    public final void drawOn()
    {
        this.servo1.write(this.sm_offAngle);
        delay(this.sm_delay);
    }

    /**
     * Release pen from canvas.
     */
    public final void drawOff()
    {
        this.servo1.write(this.sm_onAngle);
        delay(this.sm_delay);
    }

}