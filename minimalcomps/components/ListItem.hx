/**
 * ListItem.as
 * Keith Peters
 * version 0.9.10
 * 
 * A single item in a list. 
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

import openfl.events.MouseEvent;
import openfl.display.DisplayObjectContainer;


/**
 *  A single item in a list. 
 */
class ListItem extends Component {
    private var _data:Dynamic;
    private var _label:Label;
    private var _defaultColor:UInt = 0xffffff;
    private var _selectedColor:UInt = 0xdddddd;
    private var _rolloverColor:UInt = 0xeeeeee;
    private var _selected:Bool;
    private var _mouseOver:Bool = false;

    /**
     * Constructor
     * @param parent The parent DisplayObjectContainer on which to add this ListItem.
     * @param xpos The x position to place this component.
     * @param ypos The y position to place this component.
     * @param data The string to display as a label or object with a label property.
     */
    public function new(parent:DisplayObjectContainer = null, xpos:Float = 0.0, ypos:Float = 0.0, data:Dynamic = null) {
        _data = data;
        super(parent, xpos, ypos);
    }

    /**
     * Initilizes the component.
     */
    override private function init():Void {
        super.init();
        addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
        setSize(100, 20);
    }

    /**
     * Creates and adds the child display objects of this component.
     */
    override private function addChildren():Void {
        super.addChildren();
        _label = new Label(this, 5, 0);
        _label.draw();
    }


    ///////////////////////////////////
    // public methods
    ///////////////////////////////////

    /**
     * Draws the visual ui of the component.
     */
    override public function draw():Void {
        super.draw();
        graphics.clear();

        if (_selected) {
            graphics.beginFill(_selectedColor);
        }
        else if (_mouseOver) {
            graphics.beginFill(_rolloverColor);
        }
        else {
            graphics.beginFill(_defaultColor);
        }
        graphics.drawRect(0, 0, width, height);
        graphics.endFill();

        if (_data == null)
            return;

        if (Std.is(_data, String)) {
            _label.text = cast(_data, String);
        }
        else if (Reflect.hasField(_data, "label") && Std.is(_data.label, String)) {
            _label.text = _data.label;
        }
        else {
            _label.text = Std.string(_data);
        }
    }


    ///////////////////////////////////
    // event handlers
    ///////////////////////////////////

    /**
     * Called when the user rolls the mouse over the item. Changes the background color.
     */
    private function onMouseOver(event:MouseEvent):Void {
        addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        _mouseOver = true;
        invalidate();
    }

    /**
     * Called when the user rolls the mouse off the item. Changes the background color.
     */
    private function onMouseOut(event:MouseEvent):Void {
        removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        _mouseOver = false;
        invalidate();
    }


    ///////////////////////////////////
    // getter/setters
    ///////////////////////////////////

    /**
     * Sets/gets the string that appears in this item.
     */
    public var data(get, set):Dynamic;

    public function set_data(value:Dynamic):Dynamic {
        _data = value;
        invalidate();

        return _data;
    }

    public function get_data():Dynamic {
        return _data;
    }

    /**
     * Sets/gets whether or not this item is selected.
     */
    public var selected(get, set):Bool;

    public function set_selected(value:Bool):Bool {
        _selected = value;
        invalidate();

        return _selected;
    }

    public function get_selected():Bool {
        return _selected;
    }

    /**
     * Sets/gets the default background color of list items.
     */
    public var defaultColor(get, set):UInt;

    public function set_defaultColor(value:UInt):UInt {
        _defaultColor = value;
        invalidate();

        return _defaultColor;
    }

    public function get_defaultColor():UInt {
        return _defaultColor;
    }

    /**
     * Sets/gets the selected background color of list items.
     */
    public var selectedColor(get, set):UInt;

    public function set_selectedColor(value:UInt):UInt {
        _selectedColor = value;
        invalidate();

        return _selectedColor;
    }

    public function get_selectedColor():UInt {
        return _selectedColor;
    }

    /**
     * Sets/gets the rollover background color of list items.
     */
    public var rolloverColor(get, set):UInt;

    public function set_rolloverColor(value:UInt):UInt {
        _rolloverColor = value;
        invalidate();

        return _rolloverColor;
    }

    public function get_rolloverColor():UInt {
        return _rolloverColor;
    }
}
