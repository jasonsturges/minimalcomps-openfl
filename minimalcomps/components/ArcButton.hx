/**
 * ArcButton.as
 * Keith Peters
 * version 0.9.10
 * 
 * Essentially a VBox full of Windows. Only one Window will be expanded at any time.
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

import openfl.display.DisplayObject;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;


class ArcButton extends Sprite {
    public var id:Int;

    private var _arc:Float;
    private var _bg:Shape;
    private var _borderColor:UInt = 0xcccccc;
    private var _color:UInt = 0xffffff;
    private var _highlightColor:UInt = 0xeeeeee;
    private var _icon:DisplayObject;
    private var _iconHolder:Sprite;
    private var _iconRadius:Float;
    private var _innerRadius:Float;
    private var _outerRadius:Float;

    /**
	 * Constructor.
	 * @param arc The radians of the arc to draw.
	 * @param outerRadius The outer radius of the arc.
	 * @param innerRadius The inner radius of the arc.
	 */
    public function new(arc:Float, outerRadius:Float, iconRadius:Float, innerRadius:Float) {
        super();

        _arc = arc;
        _outerRadius = outerRadius;
        _iconRadius = iconRadius;
        _innerRadius = innerRadius;

        _bg = new Shape();
        addChild(_bg);

        _iconHolder = new Sprite();
        addChild(_iconHolder);

        drawArc(0xffffff);
        addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
        addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        addEventListener(MouseEvent.MOUSE_UP, onMouseGoUp);
    }


    ///////////////////////////////////
    // private methods
    ///////////////////////////////////

    /**
	 * Draws an arc of the specified color.
	 * @param color The color to draw the arc.
	 */
    private function drawArc(color:UInt):Void {
        _bg.graphics.clear();
        _bg.graphics.lineStyle(2, _borderColor);
        _bg.graphics.beginFill(color);
        _bg.graphics.moveTo(_innerRadius, 0);
        _bg.graphics.lineTo(_outerRadius, 0);

        var i:Float = 0;

        while (i < _arc) {
            _bg.graphics.lineTo(Math.cos(i) * _outerRadius, Math.sin(i) * _outerRadius);
            i += 0.05;
        }
        _bg.graphics.lineTo(Math.cos(_arc) * _outerRadius, Math.sin(_arc) * _outerRadius);
        _bg.graphics.lineTo(Math.cos(_arc) * _innerRadius, Math.sin(_arc) * _innerRadius);

        i = _arc;
        while (i > 0) {
            _bg.graphics.lineTo(Math.cos(i) * _innerRadius, Math.sin(i) * _innerRadius);
            i -= 0.05;
        }
        _bg.graphics.lineTo(_innerRadius, 0);

        graphics.endFill();
    }


    ///////////////////////////////////
    // public methods
    ///////////////////////////////////

    /**
	 * Sets the icon or label of this button.
	 * @param iconOrLabel Either a display object instance, a class that extends DisplayObject, or text to show in a label.
	 */
    public function setIcon(iconOrLabel:Dynamic):Void {
        if (iconOrLabel == null) return;
        while (_iconHolder.numChildren > 0)
            _iconHolder.removeChildAt(0);

        if (Std.is(iconOrLabel, Class)) {
            _icon = Type.createInstance(iconOrLabel, []);
        }
        else if (Std.is(iconOrLabel, DisplayObject)) {
            _icon = cast(iconOrLabel, DisplayObject);
        }
        else if (Std.is(iconOrLabel, String)) {
            _icon = new Label(null, 0, 0, cast(iconOrLabel, String));
            cast(_icon, Label).draw();
        }
        if (_icon != null) {
            var angle:Float = _bg.rotation * Math.PI / 180;
            _icon.x = Math.round(-_icon.width / 2);
            _icon.y = Math.round(-_icon.height / 2);
            _iconHolder.addChild(_icon);
            _iconHolder.x = Math.round(Math.cos(angle + _arc / 2) * _iconRadius);
            _iconHolder.y = Math.round(Math.sin(angle + _arc / 2) * _iconRadius);
        }
    }


    ///////////////////////////////////
    // event handlers
    ///////////////////////////////////

    /**
	 * Called when mouse moves over this button. Draws highlight.
	 */
    private function onMouseOver(event:MouseEvent):Void {
        drawArc(_highlightColor);
    }

    /**
	 * Called when mouse moves out of this button. Draw base color.
	 */
    private function onMouseOut(event:MouseEvent):Void {
        drawArc(_color);
    }

    /**
	 * Called when mouse is released over this button. Dispatches select event.
	 */
    private function onMouseGoUp(event:MouseEvent):Void {
        dispatchEvent(new Event(Event.SELECT));
    }


    ///////////////////////////////////
    // getter / setters
    ///////////////////////////////////

    /**
	 * Sets / gets border color.
	 */
    public var borderColor(get, set):UInt;

    public function set_borderColor(value:UInt):UInt {
        _borderColor = value;
        drawArc(_color);

        return _borderColor;
    }

    public function get_borderColor():UInt {
        return _borderColor;
    }

    /**
	 * Sets / gets base color.
	 */
    public var color(get, set):UInt;

    public function set_color(value:UInt):UInt {
        _color = value;
        drawArc(_color);

        return _color;
    }

    public function get_color():UInt {
        return _color;
    }

    /**
	 * Sets / gets highlight color.
	 */
    public var highlightColor(get, set):UInt;

    public function set_highlightColor(value:UInt):UInt {
        _highlightColor = value;

        return _highlightColor;
    }

    public function get_highlightColor():UInt {
        return _highlightColor;
    }

    /**
	 * Overrides rotation by rotating arc only, allowing label / icon to be unrotated.
	 */
    #if flash @:setter(rotation) #else override #end
    public function set_rotation(value:Float): #if flash Void #else Float #end {
        _bg.rotation = value;

        #if !flash return _bg.rotation; #end
    }

    #if flash @:getter(rotation) #else override #end
    public function get_rotation():Float {
        return _bg.rotation;
    }
}