/**
 * Knob.as
 * Keith Peters
 * version 0.9.10
 * 
 * A knob component for choosing a numerical value.
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


class Knob extends Component {

    public static inline var VERTICAL:String = "vertical";
    public static inline var HORIZONTAL:String = "horizontal";
    public static inline var ROTATE:String = "rotate";

    private var _knob:Sprite;
    private var _label:Label;
    private var _labelText:String = "";
    private var _max:Float = 100;
    private var _min:Float = 0;
    private var _mode:String = VERTICAL;
    private var _mouseRange:Float = 100;
    private var _precision:Int = 1;
    private var _radius:Float = 20;
    private var _startX:Float;
    private var _startY:Float;
    private var _value:Float = 0;
    private var _valueLabel:Label;


    /**
     * Constructor
     * @param parent The parent DisplayObjectContainer on which to add this Knob.
     * @param xpos The x position to place this component.
     * @param ypos The y position to place this component.
     * @param label String containing the label for this component.
     * @param defaultHandler The event handling function to handle the default event for this component (change in this case).
     */
    public function new(parent:DisplayObjectContainer = null, xpos:Float = 0.0, ypos:Float = 0.0, label:String = "", defaultHandler:Dynamic = null) {
        _labelText = label;
        super(parent, xpos, ypos);
        if (defaultHandler != null) {
            addEventListener(Event.CHANGE, defaultHandler);
        }
    }

    /**
     * Initializes the component.
     */
    override private function init():Void {
        super.init();
    }

    /**
     * Creates the children for this component
     */
    override private function addChildren():Void {
        _knob = new Sprite();
        _knob.buttonMode = true;
        _knob.useHandCursor = true;
        _knob.addEventListener(MouseEvent.MOUSE_DOWN, onMouseGoDown);
        addChild(_knob);

        _label = new Label();
        _label.autoSize = true;
        addChild(_label);

        _valueLabel = new Label();
        _valueLabel.autoSize = true;
        addChild(_valueLabel);

        _width = _radius * 2;
        _height = _radius * 2 + 40;
    }

    /**
     * Draw the knob at the specified radius.
     */
    private function drawKnob():Void {
        _knob.graphics.clear();
        _knob.graphics.beginFill(Style.BACKGROUND);
        _knob.graphics.drawCircle(0, 0, _radius);
        _knob.graphics.endFill();

        _knob.graphics.beginFill(Style.BUTTON_FACE);
        _knob.graphics.drawCircle(0, 0, _radius - 2);
        _knob.graphics.endFill();

        _knob.graphics.beginFill(Style.BACKGROUND);
        var s:Float = _radius * .1;
        _knob.graphics.drawRect(_radius, -s, s * 1.5, s * 2);
        _knob.graphics.endFill();

        _knob.x = _radius;
        _knob.y = _radius + 20;
        updateKnob();
    }

    /**
     * Updates the rotation of the knob based on the value, then formats the value label.
     */
    private function updateKnob():Void {
        _knob.rotation = -225 + (_value - _min) / (_max - _min) * 270;
        formatValueLabel();
    }

    /**
     * Adjusts value to be within minimum and maximum.
     */
    private function correctValue():Void {
        if (_max > _min) {
            _value = Math.min(_value, _max);
            _value = Math.max(_value, _min);
        }
        else {
            _value = Math.max(_value, _max);
            _value = Math.min(_value, _min);
        }
    }

    /**
     * Formats the value of the knob to a string based on the current level of precision.
     */
    private function formatValueLabel():Void {
        var mult:Float = Math.pow(10, _precision);
        var val:String = Std.string(Math.round(_value * mult) / mult);
        var parts:Array<String> = val.split(".");
        if (parts[1] == null) {
            if (_precision > 0) {
                val += ".";
            }
            for (i in 0 ... _precision) {
                val += "0";
            }
        }
        else if (parts[1].length < _precision) {
            for (i in 0 ... _precision - parts[1].length) {
                val += "0";
            }
        }
        _valueLabel.text = val;
        _valueLabel.draw();
        _valueLabel.x = width / 2 - _valueLabel.width / 2;
    }


    ///////////////////////////////////
    // public methods
    ///////////////////////////////////

    /**
     * Draws the visual ui of the component.
     */
    override public function draw():Void {
        super.draw();

        drawKnob();

        _label.text = _labelText;
        _label.draw();
        _label.x = _radius - _label.width / 2;
        _label.y = 0;

        formatValueLabel();
        _valueLabel.x = _radius - _valueLabel.width / 2;
        _valueLabel.y = _radius * 2 + 20;

        _width = _radius * 2;
        _height = _radius * 2 + 40;
    }


    ///////////////////////////////////
    // event handler
    ///////////////////////////////////

    /**
		 * Internal handler for when user clicks on the knob. Starts tracking up/down motion of the mouse.
		 */
    private function onMouseGoDown(event:MouseEvent):Void {
        _startX = mouseX;
        _startY = mouseY;
        stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoved);
        stage.addEventListener(MouseEvent.MOUSE_UP, onMouseGoUp);
    }

    /**
		 * Internal handler for mouse move event. Updates value based on how far mouse has moved up or down.
		 */
    private function onMouseMoved(event:MouseEvent):Void {
        var diff:Float;
        var range:Float;
        var percent:Float;
        var oldValue:Float = _value;

        if (_mode == ROTATE) {
            var angle:Float = Math.atan2(mouseY - _knob.y, mouseX - _knob.x);
            var rot:Float = angle * 180 / Math.PI - 135;
            while (rot > 360) rot -= 360;
            while (rot < 0) rot += 360;
            if (rot > 270 && rot < 315) rot = 270;
            if (rot >= 315 && rot <= 360) rot = 0;
            _value = rot / 270 * (_max - _min) + _min;
            if (_value != oldValue) {
                dispatchEvent(new Event(Event.CHANGE));
            }
            _knob.rotation = rot + 135;
            formatValueLabel();
        }
        else if (_mode == VERTICAL) {
            diff = _startY - mouseY;
            range = _max - _min;
            percent = range / _mouseRange;
            _value += percent * diff;
            correctValue();
            if (_value != oldValue) {
                updateKnob();
                dispatchEvent(new Event(Event.CHANGE));
            }
            _startY = mouseY;
        }
        else if (_mode == HORIZONTAL) {
            diff = _startX - mouseX;
            range = _max - _min;
            percent = range / _mouseRange;
            _value -= percent * diff;
            correctValue();
            if (_value != oldValue) {
                updateKnob();
                dispatchEvent(new Event(Event.CHANGE));
            }
            _startX = mouseX;
        }
    }

    /**
     * Internal handler for mouse up event. Stops mouse tracking.
     */
    private function onMouseGoUp(event:MouseEvent):Void {
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoved);
        stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseGoUp);
    }


    ///////////////////////////////////
    // getter/setters
    ///////////////////////////////////

    /**
     * Gets / sets the maximum value of this knob.
     */
    public var maximum(get, set):Float;

    public function set_maximum(value:Float):Float {
        _max = value;
        correctValue();
        updateKnob();

        return _max;
    }

    public function get_maximum():Float {
        return _max;
    }

    /**
     * Gets / sets the minimum value of this knob.
     */
    public var minimum(get, set):Float;

    public function set_minimum(value:Float):Float {
        _min = value;
        correctValue();
        updateKnob();

        return _min;
    }

    public function get_minimum():Float {
        return _min;
    }

    /**
     * Sets / gets the current value of this knob.
     */
    public var value(get, set):Float;

    public function set_value(value:Float):Float {
        _value = value;
        correctValue();
        updateKnob();

        return _value;
    }

    public function get_value():Float {
        return _value;
    }

    /**
     * Sets / gets the number of pixels the mouse needs to move to make the value of the knob go from min to max.
     */
    public var mouseRange(get, set):Float;

    public function set_mouseRange(value:Float):Float {
        _mouseRange = value;

        return _mouseRange;
    }

    public function get_mouseRange():Float {
        return _mouseRange;
    }

    /**
     * Gets / sets the number of decimals to format the value label.
     */
    public var labelPrecision(get, set):Int;

    public function set_labelPrecision(value:Int):Int {
        _precision = value;

        return _precision;
    }

    public function get_labelPrecision():Int {
        return _precision;
    }

    /**
     * Gets / sets whether or not to show the value label.
     */
    public var showValue(get, set):Bool;

    public function set_showValue(value:Bool):Bool {
        _valueLabel.visible = value;

        return _valueLabel.visible;
    }

    public function get_showValue():Bool {
        return _valueLabel.visible;
    }

    /**
     * Gets / sets the text shown in this component's label.
     */
    public var label(get, set):String;

    public function set_label(value:String):String {
        _labelText = value;
        draw();

        return _labelText;
    }

    public function get_label():String {
        return _labelText;
    }

    /**
     *
     */
    public var mode(get, set):String;

    public function set_mode(value:String):String {
        _mode = value;

        return _mode;
    }

    public function get_mode():String {
        return _mode;
    }

    /**
     *
     */
    public var radius(get, set):Float;

    public function set_radius(value:Float):Float {
        _radius = value;
        _width = _radius * 2;
        _height = _radius * 2 + 40;
        invalidate();

        return _radius;
    }

    public function get_radius():Float {
        return _radius;
    }

}
