/**
 * The class for operating a bipolar motor on raspberry pi.
 * @author Daisuke Sonoda / @5onod4 / dksonoda@gmail.com
 * @version 0.1
 */
import processing.core.PApplet;
import processing.io.*;

public class BipolarSteppingMotor
{
    /**
     * processing core.
     */
    private PApplet pa;

    /**
     * raspberry pi GPIO pin.
     */
    private int gpioPinA1;
    private int gpioPinB1;
    private int gpioPinA2;
    private int gpioPinB2;

    /**
     * motor excitation method mode.
     */
    // 1 phase excitation
    public static final int ROTATE_MODE_1 = 1;
    // 2 phase excitation
    public static final int ROTATE_MODE_2 = 2;
    // 1-2 phase excitation
    public static final int ROTATE_MODE_1_2 = 3;

    /**
     * motor excitation method mode.
     */
    private int rotateMode;

    /**
     * motor excitation method sequence.
     * {A1,B1,A2,B2}
     */
    // 1 phase excitation
    private static final int[][] ROTATE_SEQUENCE_1 = {{0,0,0,1}, {0,0,1,0}, {0,1,0,0}, {1,0,0,0}};
    // 2 phase excitation
    private static final int[][] ROTATE_SEQUENCE_2 = {{0,0,1,1}, {0,1,1,0}, {1,1,0,0}, {1,0,0,1}};
    // 1-2 phase excitation
    private static final int[][] ROTATE_SEQUENCE_1_2 = {{0,0,0,1}, {0,0,1,1}, {0,0,1,0}, {0,1,1,0}, {0,1,0,0}, {1,1,0,0}, {1,0,0,0}, {1,0,0,1}};

    /**
     * selected motor excitation method sequence.
     */
    private int[][] rotateSeq;

    /**
     * selected motor excitation method max sequence no.
     * it is used in motor sequencing.
     *  1 phase excitation: 3
     *  2 phase excitation: 3
     *  1-2 phase excitation: 7
     */
    private int rotateMaxSeq;

    /**
     * current motor rotation sequence.
     *  1 phase excitation: 0 - 3
     *  2 phase excitation: 0 - 3
     *  1-2 phase excitation: 0 - 7
     */
    private int currentRotateSeq = 0;

    /**
     * minimum delay value.
     * (unit: millisecond)
     */
    private static final int DELAY_MIN = 5;

    /**
     * the time spent on one step so that the stepping motor does not step out.
     * (unit: millisecond)
     */
    private int delay;


    /**
     * Constructor.
     * @param papplet
     * @param gpioPinA1
     * @param gpioPinB1
     * @param gpioPinA2
     * @param gpioPinB2
     * @param delay
     * @param rotateMode 
     */
    public BipolarSteppingMotor(
        PApplet papplet,
        int gpioPinA1,
        int gpioPinB1,
        int gpioPinA2,
        int gpioPinB2,
        int delay,
        int rotateMode
    ) {
        this.pa = papplet;

        this.gpioPinA1 = gpioPinA1;
        this.gpioPinB1 = gpioPinB1;
        this.gpioPinA2 = gpioPinA2;
        this.gpioPinB2 = gpioPinB2;

        if (delay < DELAY_MIN) {
            this.delay = DELAY_MIN;
        } else {
            this.delay = delay;
        }

        this.rotateMode = rotateMode;
        switch (this.rotateMode) {
            case ROTATE_MODE_1:
                this.rotateSeq = ROTATE_SEQUENCE_1;
                break;
            case ROTATE_MODE_2:
                this.rotateSeq = ROTATE_SEQUENCE_2;
                break;
            case ROTATE_MODE_1_2:
            default:
                this.rotateSeq = ROTATE_SEQUENCE_1_2;
                break;
        }

        this.rotateMaxSeq = this.rotateSeq.length - 1;

        /**
         * set the output pin on the raspberry pi GPIO pin.
         */
        GPIO.pinMode(this.gpioPinA1, GPIO.OUTPUT);
        GPIO.pinMode(this.gpioPinB1, GPIO.OUTPUT);
        GPIO.pinMode(this.gpioPinA2, GPIO.OUTPUT);
        GPIO.pinMode(this.gpioPinB2, GPIO.OUTPUT);
    }

    /**
     * rotate the motor clockwise.
     * @param steps 
     */
    public void rotateRight(int steps)
    {
        for (int i = 0; i < steps; i++) {
            if (this.currentRotateSeq >= this.rotateMaxSeq) {
                this.currentRotateSeq = 0;
            } else {
                this.currentRotateSeq++;
            }
            this.rotate(this.rotateSeq[this.currentRotateSeq]);
        }
    }

    /**
     * rotate the motor counterclockwise.
     * @param steps 
     */
    public void rotateLeft(int steps)
    {
        for (int i = 0; i < steps; i++) {
            if (this.currentRotateSeq <= 0) {
                this.currentRotateSeq = this.rotateMaxSeq;
            } else {
                this.currentRotateSeq--;
            }
            this.rotate(this.rotateSeq[this.currentRotateSeq]);
        }
    }

    /**
     * set High or Low voltage to GPIO pin.
     * @param rotateSeq 
     */
    private void rotate(int[] rotateSeq)
    {
        GPIO.digitalWrite(this.gpioPinA1, (rotateSeq[0] == 1) ? GPIO.HIGH : GPIO.LOW);
        GPIO.digitalWrite(this.gpioPinB1, (rotateSeq[1] == 1) ? GPIO.HIGH : GPIO.LOW);
        GPIO.digitalWrite(this.gpioPinA2, (rotateSeq[2] == 1) ? GPIO.HIGH : GPIO.LOW);
        GPIO.digitalWrite(this.gpioPinB2, (rotateSeq[3] == 1) ? GPIO.HIGH : GPIO.LOW);
        this.pa.delay(this.delay);
    }

    /**
     * get step number of motor.
     * @param steps
     * @return 
     */
    public int getSteps (int steps)
    {
        return (int) (Math.round(this.rotateSeq.length / ROTATE_SEQUENCE_1.length) * steps);
    }
}