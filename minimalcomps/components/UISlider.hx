/**
 * UISlider.as
 * Keith Peters
 * version 0.9.10
 * 
 * A Slider with a label and value label. Abstract base class for VUISlider and HUISlider
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
import openfl.events.Event;


class UISlider extends Component {
    private var _label:Label;
    private var _valueLabel:Label;
    private var _slider:Slider;
    private var _precision:Int = 1;
    private var _sliderClass:Class<Dynamic>;
    private var _labelText:String;
    private var _tick:Float = 1;

    /**
     * Constructor
     * @param parent The parent DisplayObjectContainer on which to add this UISlider.
     * @param xpos The x position to place this component.
     * @param ypos The y position to place this component.
     * @param label The initial string to display as this component's label.
     * @param defaultHandler The event handling function to handle the default event for this component (change in this case).
     */
    public function new(parent:DisplayObjectContainer = null, xpos:Float = 0.0, ypos:Float = 0.0, label:String = "", defaultHandler:Dynamic = null) {
        _labelText = label;
        super(parent, xpos, ypos);
        if (defaultHandler != null) {
            addEventListener(Event.CHANGE, defaultHandler);
        }
        formatValueLabel();
    }

    /**
     * Creates and adds the child display objects of this component.
     */
    override private function addChildren():Void {
        _label = new Label(this, 0, 0);
        _slider = Type.createInstance(_sliderClass, [this, 0, 0, onSliderChange]);
        _valueLabel = new Label(this);
    }

    /**
     * Formats the value of the slider to a string based on the current level of precision.
     */
    private function formatValueLabel():Void {
        if (Math.isNaN(_slider.value)) {
            _valueLabel.text = "NaN";
            return;
        }
        var mult:Float = Math.pow(10, _precision);
        var val:String = Std.string(Math.round(_slider.value * mult) / mult);
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
        positionLabel();
    }

    /**
     * Positions the label when it has changed. Implemented in child classes.
     */
    private function positionLabel():Void {
    }


    ///////////////////////////////////
    // public methods
    ///////////////////////////////////

    /**
     * Draws the visual ui of this component.
     */
    override public function draw():Void {
        super.draw();
        _label.text = _labelText;
        _label.draw();
        formatValueLabel();
    }

    /**
     * Convenience method to set the three main parameters in one shot.
     * @param min The minimum value of the slider.
     * @param max The maximum value of the slider.
     * @param value The value of the slider.
     */
    public function setSliderParams(min:Float, max:Float, value:Float):Void {
        _slider.setSliderParams(min, max, value);
    }


    ///////////////////////////////////
    // event handlers
    ///////////////////////////////////

    /**
     * Handler called when the slider's value changes.
     * @param event The Event passed by the slider.
     */
    private function onSliderChange(event:Event):Void {
        formatValueLabel();
        dispatchEvent(new Event(Event.CHANGE));
    }


    ///////////////////////////////////
    // getter/setters
    ///////////////////////////////////

    /**
     * Sets / gets the current value of this slider.
     */
    public var value(get, set):Float;

    public function set_value(value:Float):Float {
        _slider.value = value;
        formatValueLabel();

        return _slider.value;
    }

    public function get_value():Float {
        return _slider.value;
    }

    /**
     * Gets / sets the maximum value of this slider.
     */
    public var maximum(get, set):Float;

    public function set_maximum(value:Float):Float {
        _slider.maximum = value;

        return _slider.maximum;
    }

    public function get_maximum():Float {
        return _slider.maximum;
    }

    /**
     * Gets / sets the minimum value of this slider.
     */
    public var minimum(get, set):Float;

    public function set_minimum(value:Float):Float {
        _slider.minimum = value;

        return _slider.minimum;
    }

    public function get_minimum():Float {
        return _slider.minimum;
    }

    /**
     * Gets / sets the number of decimals to format the value label. Does not affect the actual value of the slider, just the number shown.
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
     * Gets / sets the tick value of this slider. This round the value to the nearest multiple of this number.
     */
    public var tick(get, set):Float;

    public function set_tick(value:Float):Float {
        _tick = value;
        _slider.tick = _tick;

        return _tick;
    }

    public function get_tick():Float {
        return _tick;
    }
}
