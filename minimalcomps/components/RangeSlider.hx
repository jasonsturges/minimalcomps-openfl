/**
 * RangeSlider.as
 * Keith Peters
 * version 0.9.10
 * 
 * Abstract base class for HRangeSlider and VRangeSlider.
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
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;


class RangeSlider extends Component {
    private var _back:Sprite;
    private var _highLabel:Label;
    private var _highValue:Float = 100;
    private var _labelMode:String = ALWAYS;
    private var _labelPosition:String;
    private var _labelPrecision:Int = 0;
    private var _lowLabel:Label;
    private var _lowValue:Float = 0;
    private var _maximum:Float = 100;
    private var _maxHandle:Sprite;
    private var _minimum:Float = 0;
    private var _minHandle:Sprite;
    private var _orientation:String = VERTICAL;
    private var _tick:Float = 1;

    public static inline var ALWAYS:String = "always";
    public static inline var BOTTOM:String = "bottom";
    public static inline var HORIZONTAL:String = "horizontal";
    public static inline var LEFT:String = "left";
    public static inline var MOVE:String = "move";
    public static inline var NEVER:String = "never";
    public static inline var RIGHT:String = "right";
    public static inline var TOP:String = "top";
    public static inline var VERTICAL:String = "vertical";


    /**
     * Constructor
     * @param orientation Whether the slider will be horizontal or vertical.
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
     * Initializes the component.
     */
    private override function init():Void {
        super.init();
        if (_orientation == HORIZONTAL) {
            setSize(110, 10);
            _labelPosition = TOP;
        }
        else {
            setSize(10, 110);
            _labelPosition = RIGHT;
        }
    }

    /**
     * Creates and adds the child display objects of this component.
     */
    private override function addChildren():Void {
        super.addChildren();
        _back = new Sprite();
        _back.filters = [getShadow(2, true)];
        addChild(_back);

        _minHandle = new Sprite();
        _minHandle.filters = [getShadow(1)];
        _minHandle.addEventListener(MouseEvent.MOUSE_DOWN, onDragMin);
        _minHandle.buttonMode = true;
        _minHandle.useHandCursor = true;
        addChild(_minHandle);

        _maxHandle = new Sprite();
        _maxHandle.filters = [getShadow(1)];
        _maxHandle.addEventListener(MouseEvent.MOUSE_DOWN, onDragMax);
        _maxHandle.buttonMode = true;
        _maxHandle.useHandCursor = true;
        addChild(_maxHandle);

        _lowLabel = new Label(this);
        _highLabel = new Label(this);
        _lowLabel.visible = (_labelMode == ALWAYS);
    }

    /**
     * Draws the back of the slider.
     */
    private function drawBack():Void {
        _back.graphics.clear();
        _back.graphics.beginFill(Style.BACKGROUND);
        _back.graphics.drawRect(0, 0, _width, _height);
        _back.graphics.endFill();
    }

    /**
     * Draws the handles of the slider.
     */
    private function drawHandles():Void {
        _minHandle.graphics.clear();
        _minHandle.graphics.beginFill(Style.BUTTON_FACE);
        _maxHandle.graphics.clear();
        _maxHandle.graphics.beginFill(Style.BUTTON_FACE);
        if (_orientation == HORIZONTAL) {
            _minHandle.graphics.drawRect(1, 1, _height - 2, _height - 2);
            _maxHandle.graphics.drawRect(1, 1, _height - 2, _height - 2);
        }
        else {
            _minHandle.graphics.drawRect(1, 1, _width - 2, _width - 2);
            _maxHandle.graphics.drawRect(1, 1, _width - 2, _width - 2);
        }
        _minHandle.graphics.endFill();
        positionHandles();
    }

    /**
     * Adjusts positions of handles when value, maximum or minimum have changed.
     * TODO: Should also be called when slider is resized.
     */
    private function positionHandles():Void {
        var range:Float;
        if (_orientation == HORIZONTAL) {
            range = _width - _height * 2;
            _minHandle.x = (_lowValue - _minimum) / (_maximum - _minimum) * range;
            _maxHandle.x = _height + (_highValue - _minimum) / (_maximum - _minimum) * range;
        }
        else {
            range = _height - _width * 2;
            _minHandle.y = _height - _width - (_lowValue - _minimum) / (_maximum - _minimum) * range;
            _maxHandle.y = _height - _width * 2 - (_highValue - _minimum) / (_maximum - _minimum) * range;
        }
        updateLabels();
    }

    /**
     * Sets the text and positions the labels.
     */
    private function updateLabels():Void {
        _lowLabel.text = getLabelForValue(lowValue);
        _highLabel.text = getLabelForValue(highValue);
        _lowLabel.draw();
        _highLabel.draw();

        if (_orientation == VERTICAL) {
            _lowLabel.y = _minHandle.y + (_width - _lowLabel.height) * 0.5;
            _highLabel.y = _maxHandle.y + (_width - _highLabel.height) * 0.5;
            if (_labelPosition == LEFT) {
                _lowLabel.x = -_lowLabel.width - 5;
                _highLabel.x = -_highLabel.width - 5;
            }
            else {
                _lowLabel.x = _width + 5;
                _highLabel.x = _width + 5;
            }
        }
        else {
            _lowLabel.x = _minHandle.x - _lowLabel.width + _height;
            _highLabel.x = _maxHandle.x;
            if (_labelPosition == BOTTOM) {
                _lowLabel.y = _height + 2;
                _highLabel.y = _height + 2;
            }
            else {
                _lowLabel.y = -_lowLabel.height;
                _highLabel.y = -_highLabel.height;
            }

        }
    }

    /**
     * Generates a label string for the given value.
     * @param value The number to create a label for.
     */
    private function getLabelForValue(value:Float):String {
        var str:String = Std.string(Math.round(value * Math.pow(10, _labelPrecision)) / Math.pow(10, _labelPrecision));
        if (_labelPrecision > 0) {
            // TODO: Improve this logic
            var decimal:String = str.split(".")[1];
            if (decimal == null)
                decimal = "";

            if (decimal.length == 0)
                str += ".";

            for (i in decimal.length ... _labelPrecision) {
                str += "0";
            }
        }
        return str;
    }


    ///////////////////////////////////
    // public methods
    ///////////////////////////////////

    /**
     * Draws the visual ui of the component.
     */
    override public function draw():Void {
        super.draw();
        drawBack();
        drawHandles();
    }


    ///////////////////////////////////
    // event handlers
    ///////////////////////////////////

    /**
     * Internal mouseDown handler for the low value handle. Starts dragging the handle.
     * @param event The MouseEvent passed by the system.
     */
    private function onDragMin(event:MouseEvent):Void {
        stage.addEventListener(MouseEvent.MOUSE_UP, onDrop);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, onMinSlide);
        if (_orientation == HORIZONTAL) {
            _minHandle.startDrag(false, new Rectangle(0, 0, _maxHandle.x - _height, 0));
        }
        else {
            _minHandle.startDrag(false, new Rectangle(0, _maxHandle.y + _width, 0, _height - _maxHandle.y - _width * 2));
        }
        if (_labelMode == MOVE) {
            _lowLabel.visible = true;
            _highLabel.visible = true;
        }
    }

    /**
     * Internal mouseDown handler for the high value handle. Starts dragging the handle.
     * @param event The MouseEvent passed by the system.
     */
    private function onDragMax(event:MouseEvent):Void {
        stage.addEventListener(MouseEvent.MOUSE_UP, onDrop);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, onMaxSlide);
        if (_orientation == HORIZONTAL) {
            _maxHandle.startDrag(false, new Rectangle(_minHandle.x + _height, 0, _width - _height - _minHandle.x - _height, 0));
        }
        else {
            _maxHandle.startDrag(false, new Rectangle(0, 0, 0, _minHandle.y - _width));
        }
        if (_labelMode == MOVE) {
            _lowLabel.visible = true;
            _highLabel.visible = true;
        }
    }

    /**
     * Internal mouseUp handler. Stops dragging the handle.
     * @param event The MouseEvent passed by the system.
     */
    private function onDrop(event:MouseEvent):Void {
        stage.removeEventListener(MouseEvent.MOUSE_UP, onDrop);
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMinSlide);
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMaxSlide);
        stopDrag();
        if (_labelMode == MOVE) {
            _lowLabel.visible = false;
            _highLabel.visible = false;
        }
    }

    /**
     * Internal mouseMove handler for when the low value handle is being moved.
     * @param event The MouseEvent passed by the system.
     */
    private function onMinSlide(event:MouseEvent):Void {
        var oldValue:Float = _lowValue;
        if (_orientation == HORIZONTAL) {
            _lowValue = _minHandle.x / (_width - _height * 2) * (_maximum - _minimum) + _minimum;
        }
        else {
            _lowValue = (_height - _width - _minHandle.y) / (height - _width * 2) * (_maximum - _minimum) + _minimum;
        }
        if (_lowValue != oldValue) {
            dispatchEvent(new Event(Event.CHANGE));
        }
        updateLabels();
    }

    /**
     * Internal mouseMove handler for when the high value handle is being moved.
     * @param event The MouseEvent passed by the system.
     */
    private function onMaxSlide(event:MouseEvent):Void {
        var oldValue:Float = _highValue;
        if (_orientation == HORIZONTAL) {
            _highValue = (_maxHandle.x - _height) / (_width - _height * 2) * (_maximum - _minimum) + _minimum;
        }
        else {
            _highValue = (_height - _width * 2 - _maxHandle.y) / (_height - _width * 2) * (_maximum - _minimum) + _minimum;
        }
        if (_highValue != oldValue) {
            dispatchEvent(new Event(Event.CHANGE));
        }
        updateLabels();
    }

    /**
     * Gets / sets the minimum value of the slider.
     */
    public var minimum(get, set):Float;

    public function set_minimum(value:Float):Float {
        _minimum = value;
        _maximum = Math.max(_maximum, _minimum);
        _lowValue = Math.max(_lowValue, _minimum);
        _highValue = Math.max(_highValue, _minimum);
        positionHandles();

        return _minimum;
    }

    public function get_minimum():Float {
        return _minimum;
    }

    /**
     * Gets / sets the maximum value of the slider.
     */
    public var maximum(get, set):Float;

    public function set_maximum(value:Float):Float {
        _maximum = value;
        _minimum = Math.min(_minimum, _maximum);
        _lowValue = Math.min(_lowValue, _maximum);
        _highValue = Math.min(_highValue, _maximum);
        positionHandles();

        return _maximum;
    }

    public function get_maximum():Float {
        return _maximum;
    }

    /**
     * Gets / sets the low value of this slider.
     */
    public var lowValue(get, set):Float;

    public function set_lowValue(value:Float):Float {
        _lowValue = value;
        _lowValue = Math.min(_lowValue, _highValue);
        _lowValue = Math.max(_lowValue, _minimum);
        positionHandles();
        dispatchEvent(new Event(Event.CHANGE));

        return _lowValue;
    }

    public function get_lowValue():Float {
        return Math.round(_lowValue / _tick) * _tick;
    }

    /**
     * Gets / sets the high value for this slider.
     */
    public var highValue(get, set):Float;

    public function set_highValue(value:Float):Float {
        _highValue = value;
        _highValue = Math.max(_highValue, _lowValue);
        _highValue = Math.min(_highValue, _maximum);
        positionHandles();
        dispatchEvent(new Event(Event.CHANGE));

        return _highValue;
    }

    public function get_highValue():Float {
        return Math.round(_highValue / _tick) * _tick;
    }

    /**
     * Sets / gets when the labels will appear. Can be "never", "move", or "always"
     */
    public var labelMode(get, set):String;

    public function set_labelMode(value:String):String {
        _labelMode = value;
        _highLabel.visible = (_labelMode == ALWAYS);
        _lowLabel.visible = (_labelMode == ALWAYS);

        return _labelMode;
    }

    public function get_labelMode():String {
        return _labelMode;
    }

    /**
     * Sets / gets where the labels will appear. "left" or "right" for vertical sliders, "top" or "bottom" for horizontal.
     */
    public var labelPosition(get, set):String;

    public function set_labelPosition(value:String):String {
        _labelPosition = value;
        updateLabels();

        return _labelPosition;
    }

    public function get_labelPosition():String {
        return _labelPosition;
    }

    /**
     * Sets / gets how many decimal points of precisions will be displayed on the labels.
     */
    public var labelPrecision(get, set):Int;

    public function set_labelPrecision(value:Int):Int {
        _labelPrecision = value;
        updateLabels();

        return _labelPrecision;
    }

    public function get_labelPrecision():Int {
        return _labelPrecision;
    }

    /**
     * Gets / sets the tick value of this slider. This round the value to the nearest multiple of this number.
     */
    public var tick(get, set):Float;

    public function set_tick(value:Float):Float {
        _tick = value;
        updateLabels();

        return _tick;
    }

    public function get_tick():Float {
        return _tick;
    }
}
