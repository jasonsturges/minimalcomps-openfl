/**
 * ScrollBar.as
 * Keith Peters
 * version 0.9.10
 * 
 * Base class for HScrollBar and VScrollBar
 * 
 * Copyright (c) 2011 Keith Peters
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package minimalcomps.components;

import openfl.display.DisplayObjectContainer;
import openfl.display.Shape;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TimerEvent;
import openfl.utils.Timer;


class ScrollBar extends Component {
    private static inline var DELAY_TIME:Int = 500;
    private static inline var REPEAT_TIME:Int = 100;
    private static inline var UP:String = "up";
    private static inline var DOWN:String = "down";

    private var _autoHide:Bool = false;
    private var _upButton:PushButton;
    private var _downButton:PushButton;
    private var _scrollSlider:ScrollSlider;
    private var _orientation:String;
    private var _lineSize:Int = 1;
    private var _delayTimer:Timer;
    private var _repeatTimer:Timer;
    private var _direction:String;
    private var _shouldRepeat:Bool = false;

    /**
     * Constructor
     * @param orientation Whether this is a vertical or horizontal slider.
     * @param parent The parent DisplayObjectContainer on which to add this Slider.
     * @param xpos The x position to place this component.
     * @param ypos The y position to place this component.
     * @param defaultHandler The event handling function to handle the default event for this component (change in this case).
     */
    public function new(orientation:String, parent:DisplayObjectContainer = null, xpos:Float = 0.0, ypos:Float = 0.0, defaultHandler:Dynamic = null) {
        _orientation = orientation;
        super(parent, xpos, ypos);
        if (defaultHandler != null) {
            addEventListener(Event.CHANGE, defaultHandler);
        }
    }

    /**
     * Creates and adds the child display objects of this component.
     */
    override private function addChildren():Void {
        _scrollSlider = new ScrollSlider(_orientation, this, 0, 10, onChange);
        _upButton = new PushButton(this, 0, 0, "");
        _upButton.addEventListener(MouseEvent.MOUSE_DOWN, onUpClick);
        _upButton.setSize(10, 10);
        var upArrow:Shape = new Shape();
        _upButton.addChild(upArrow);

        _downButton = new PushButton(this, 0, 0, "");
        _downButton.addEventListener(MouseEvent.MOUSE_DOWN, onDownClick);
        _downButton.setSize(10, 10);
        var downArrow:Shape = new Shape();
        _downButton.addChild(downArrow);

        if (_orientation == Slider.VERTICAL) {
            upArrow.graphics.beginFill(Style.DROPSHADOW, 0.5);
            upArrow.graphics.moveTo(5, 3);
            upArrow.graphics.lineTo(7, 6);
            upArrow.graphics.lineTo(3, 6);
            upArrow.graphics.endFill();

            downArrow.graphics.beginFill(Style.DROPSHADOW, 0.5);
            downArrow.graphics.moveTo(5, 7);
            downArrow.graphics.lineTo(7, 4);
            downArrow.graphics.lineTo(3, 4);
            downArrow.graphics.endFill();
        }
        else {
            upArrow.graphics.beginFill(Style.DROPSHADOW, 0.5);
            upArrow.graphics.moveTo(3, 5);
            upArrow.graphics.lineTo(6, 7);
            upArrow.graphics.lineTo(6, 3);
            upArrow.graphics.endFill();

            downArrow.graphics.beginFill(Style.DROPSHADOW, 0.5);
            downArrow.graphics.moveTo(7, 5);
            downArrow.graphics.lineTo(4, 7);
            downArrow.graphics.lineTo(4, 3);
            downArrow.graphics.endFill();
        }


    }

    /**
     * Initializes the component.
     */
    private override function init():Void {
        super.init();
        if (_orientation == Slider.HORIZONTAL) {
            setSize(100, 10);
        }
        else {
            setSize(10, 100);
        }
        _delayTimer = new Timer(DELAY_TIME, 1);
        _delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onDelayComplete);
        _repeatTimer = new Timer(REPEAT_TIME);
        _repeatTimer.addEventListener(TimerEvent.TIMER, onRepeat);
    }


    ///////////////////////////////////
    // public methods
    ///////////////////////////////////

    /**
     * Convenience method to set the three main parameters in one shot.
     * @param min The minimum value of the slider.
     * @param max The maximum value of the slider.
     * @param value The value of the slider.
     */
    public function setSliderParams(min:Float, max:Float, value:Float):Void {
        _scrollSlider.setSliderParams(min, max, value);
    }

    /**
     * Sets the percentage of the size of the thumb button.
     */
    public function setThumbPercent(value:Float):Void {
        _scrollSlider.setThumbPercent(value);
    }

    /**
     * Draws the visual ui of the component.
     */
    override public function draw():Void {
        super.draw();
        if (_orientation == Slider.VERTICAL) {
            _scrollSlider.x = 0;
            _scrollSlider.y = 10;
            _scrollSlider.width = 10;
            _scrollSlider.height = _height - 20;
            _downButton.x = 0;
            _downButton.y = _height - 10;
        }
        else {
            _scrollSlider.x = 10;
            _scrollSlider.y = 0;
            _scrollSlider.width = _width - 20;
            _scrollSlider.height = 10;
            _downButton.x = _width - 10;
            _downButton.y = 0;
        }
        _scrollSlider.draw();
        if (_autoHide) {
            visible = _scrollSlider.thumbPercent < 1.0;
        }
        else {
            visible = true;
        }
    }


    ///////////////////////////////////
    // getter/setters
    ///////////////////////////////////

    /**
     * Sets / gets whether the scrollbar will auto hide when there is nothing to scroll.
     */
    public var autoHide(get, set):Bool;

    public function set_autoHide(value:Bool):Bool {
        _autoHide = value;
        invalidate();

        return _autoHide;
    }

    public function get_autoHide():Bool {
        return _autoHide;
    }

    /**
     * Sets / gets the current value of this scroll bar.
     */
    public var value(get, set):Float;

    public function set_value(value:Float):Float {
        _scrollSlider.value = value;

        return _scrollSlider.value;
    }

    public function get_value():Float {
        return _scrollSlider.value;
    }

    /**
     * Sets / gets the minimum value of this scroll bar.
     */
    public var minimum(get, set):Float;

    public function set_minimum(value:Float):Float {
        _scrollSlider.minimum = value;

        return _scrollSlider.minimum;
    }

    public function get_minimum():Float {
        return _scrollSlider.minimum;
    }

    /**
     * Sets / gets the maximum value of this scroll bar.
     */
    public var maximum(get, set):Float;

    public function set_maximum(value:Float):Float {
        _scrollSlider.maximum = value;

        return _scrollSlider.maximum;
    }

    public function get_maximum():Float {
        return _scrollSlider.maximum;
    }

    /**
     * Sets / gets the amount the value will change when up or down buttons are pressed.
     */
    public var lineSize(get, set):Int;

    public function set_lineSize(value:Int):Int {
        _lineSize = value;

        return _lineSize;
    }

    public function get_lineSize():Int {
        return _lineSize;
    }

    /**
     * Sets / gets the amount the value will change when the back is clicked.
     */
    public var pageSize(get, set):Int;

    public function set_pageSize(value:Int):Int {
        _scrollSlider.pageSize = value;
        invalidate();

        return _scrollSlider.pageSize;
    }

    public function get_pageSize():Int {
        return _scrollSlider.pageSize;
    }


    ///////////////////////////////////
    // event handlers
    ///////////////////////////////////

    private function onUpClick(event:MouseEvent):Void {
        goUp();
        _shouldRepeat = true;
        _direction = UP;
        _delayTimer.start();
        stage.addEventListener(MouseEvent.MOUSE_UP, onMouseGoUp);
    }

    private function goUp():Void {
        _scrollSlider.value -= _lineSize;
        dispatchEvent(new Event(Event.CHANGE));
    }

    private function onDownClick(event:MouseEvent):Void {
        goDown();
        _shouldRepeat = true;
        _direction = DOWN;
        _delayTimer.start();
        stage.addEventListener(MouseEvent.MOUSE_UP, onMouseGoUp);
    }

    private function goDown():Void {
        _scrollSlider.value += _lineSize;
        dispatchEvent(new Event(Event.CHANGE));
    }

    private function onMouseGoUp(event:MouseEvent):Void {
        _delayTimer.stop();
        _repeatTimer.stop();
        _shouldRepeat = false;
    }

    private function onChange(event:Event):Void {
        dispatchEvent(event);
    }

    private function onDelayComplete(event:TimerEvent):Void {
        if (_shouldRepeat) {
            _repeatTimer.start();
        }
    }

    private function onRepeat(event:TimerEvent):Void {
        if (_direction == UP) {
            goUp();
        }
        else {
            goDown();
        }
    }


}
