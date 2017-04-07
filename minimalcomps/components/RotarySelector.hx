/**
 * RotarySelector.as
 * Keith Peters
 * version 0.9.10
 * 
 * A rotary selector component for choosing among different values.
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


class RotarySelector extends Component {
    public static inline var ALPHABETIC:String = "alphabetic";
    public static inline var NUMERIC:String = "numeric";
    public static inline var NONE:String = "none";
    public static inline var ROMAN:String = "roman";

    private var _label:Label;
    private var _labelText:String = "";
    private var _knob:Sprite;
    private var _numChoices:Int = 2;
    private var _choice:Float = 0;
    private var _labels:Sprite;
    private var _labelMode:String = ALPHABETIC;


    /**
     * Constructor
     * @param parent The parent DisplayObjectContainer on which to add this CheckBox.
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
        setSize(60, 60);
    }

    /**
     * Creates the children for this component
     */
    override private function addChildren():Void {
        _knob = new Sprite();
        _knob.buttonMode = true;
        _knob.useHandCursor = true;
        addChild(_knob);

        _label = new Label();
        _label.autoSize = true;
        addChild(_label);

        _labels = new Sprite();
        addChild(_labels);

        _knob.addEventListener(MouseEvent.CLICK, onClick);
    }

    /**
     * Decrements the index of the current choice.
     */
    private function decrement():Void {
        if (_choice > 0) {
            _choice--;
            draw();
            dispatchEvent(new Event(Event.CHANGE));
        }
    }

    /**
     * Increments the index of the current choice.
     */
    private function increment():Void {
        if (_choice < _numChoices - 1) {
            _choice++;
            draw();
            dispatchEvent(new Event(Event.CHANGE));
        }
    }

    /**
     * Removes old labels.
     */
    private function resetLabels():Void {
        while (_labels.numChildren > 0) {
            _labels.removeChildAt(0);
        }
        _labels.x = _width / 2 - 5;
        _labels.y = _height / 2 - 10;
    }

    /**
     * Draw the knob at the specified radius.
     * @param radius The radius with which said knob will be drawn.
     */
    private function drawKnob(radius:Float):Void {
        _knob.graphics.clear();
        _knob.graphics.beginFill(Style.BACKGROUND);
        _knob.graphics.drawCircle(0, 0, radius);
        _knob.graphics.endFill();

        _knob.graphics.beginFill(Style.BUTTON_FACE);
        _knob.graphics.drawCircle(0, 0, radius - 2);

        _knob.x = _width / 2;
        _knob.y = _height / 2;
    }


    ///////////////////////////////////
    // public methods
    ///////////////////////////////////

    /**
     * Draws the visual ui of the component.
     */
    override public function draw():Void {
        super.draw();

        var radius:Float = Math.min(_width, _height) / 2;
        drawKnob(radius);
        resetLabels();

        var arc:Float = Math.PI * 1.5 / _numChoices; // the angle between each choice
        var start:Float = -Math.PI / 2 - arc * (_numChoices - 1) / 2; // the starting angle for choice 0
        var angle:Float;

        graphics.clear();
        graphics.lineStyle(4, Style.BACKGROUND, .5);
        for (i in 0 ... _numChoices) {
            angle = start + arc * i;
            var sin:Float = Math.sin(angle);
            var cos:Float = Math.cos(angle);

            graphics.moveTo(_knob.x, _knob.y);
            graphics.lineTo(_knob.x + cos * (radius + 2), _knob.y + sin * (radius + 2));

            var lab:Label = new Label(_labels, cos * (radius + 10), sin * (radius + 10));
            lab.mouseEnabled = true;
            lab.buttonMode = true;
            lab.useHandCursor = true;
            lab.addEventListener(MouseEvent.CLICK, onLabelClick);
            if (_labelMode == ALPHABETIC) {
                lab.text = String.fromCharCode(65 + i);
            }
            else if (_labelMode == NUMERIC) {
                lab.text = Std.string(i + 1);
            }
            else if (_labelMode == ROMAN) {
                var chars:Array<String> = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"];
                lab.text = chars[i];
            }
            if (i != _choice) {
                lab.alpha = 0.5;
            }
        }

        angle = start + arc * _choice;
        graphics.lineStyle(4, Style.LABEL_TEXT);
        graphics.moveTo(_knob.x, _knob.y);
        graphics.lineTo(_knob.x + Math.cos(angle) * (radius + 2), _knob.y + Math.sin(angle) * (radius + 2));


        _label.text = _labelText;
        _label.draw();
        _label.x = _width / 2 - _label.width / 2;
        _label.y = _height + 2;
    }


    ///////////////////////////////////
    // event handler
    ///////////////////////////////////

    /**
     * Internal click handler.
     * @param event The MouseEvent passed by the system.
     */
    private function onClick(event:MouseEvent):Void {
        if (mouseX < _width / 2) {
            decrement();
        }
        else {
            increment();
        }
    }

    private function onLabelClick(event:Event):Void {
        var lab:Label = cast(event.target, Label);
        choice = _labels.getChildIndex(lab);
    }


    ///////////////////////////////////
    // getter/setters
    ///////////////////////////////////

    /**
     * Gets / sets the number of available choices (maximum of 10).
     */
    public var numChoices(get, set):UInt;

    public function set_numChoices(value:UInt):UInt {
        _numChoices = Math.floor(Math.min(value, 10));
        draw();

        return _numChoices;
    }

    public function get_numChoices():UInt {
        return _numChoices;
    }

    /**
     * Gets / sets the current choice, keeping it in range of 0 to numChoices - 1.
     *
     * TODO: Verify UInt -> Float in original implementation
     */
    public var choice(get, set):Float;

    public function set_choice(value:Float):Float {
        _choice = Math.max(0, Math.min(_numChoices - 1, value));
        draw();
        dispatchEvent(new Event(Event.CHANGE));

        return _choice;
    }

    public function get_choice():Float {
        return _choice;
    }

    /**
     * Specifies what will be used as labels for each choice. Valid values are "alphabetic", "numeric", and "none".
     */
    public var labelMode(get, set):String;

    public function set_labelMode(value:String):String {
        _labelMode = value;
        draw();

        return _labelMode;
    }

    public function get_labelMode():String {
        return _labelMode;
    }
}
