/**
 * Label.as
 * Keith Peters
 * version 0.9.10
 * 
 * A Label component for displaying a single line of text.
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
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;


/**
 *  A Label component for displaying a single line of text.
 */
class Label extends Component {
    private var _autoSize:Bool = true;
    private var _text:String = "";
    private var _tf:TextField;

    /**
     * Constructor
     * @param parent The parent DisplayObjectContainer on which to add this Label.
     * @param xpos The x position to place this component.
     * @param ypos The y position to place this component.
     * @param text The string to use as the initial text in this component.
     */
    public function new(parent:DisplayObjectContainer = null, xpos:Float = 0.0, ypos:Float = 0.0, text:String = "") {
        this.text = text;
        super(parent, xpos, ypos);
    }

    /**
     * Initializes the component.
     */
    override private function init():Void {
        super.init();
        mouseEnabled = false;
        mouseChildren = false;
    }

    /**
     * Creates and adds the child display objects of this component.
     */
    override private function addChildren():Void {
        _height = 18;
        _tf = new TextField();
        _tf.height = _height;
        _tf.embedFonts = Style.embedFonts;
        _tf.selectable = false;
        _tf.mouseEnabled = false;
        _tf.defaultTextFormat = new TextFormat(Style.fontName, Style.fontSize, Style.LABEL_TEXT);
        _tf.text = _text;
        addChild(_tf);
        draw();
    }


    ///////////////////////////////////
    // public methods
    ///////////////////////////////////

    /**
     * Draws the visual ui of the component.
     */
    override public function draw():Void {
        super.draw();
        _tf.text = _text;
        if (_autoSize) {
            _tf.autoSize = TextFieldAutoSize.LEFT;
            _width = _tf.width;
            dispatchEvent(new Event(Event.RESIZE));
        }
        else {
            _tf.autoSize = TextFieldAutoSize.NONE;
            _tf.width = _width;
        }
        _height = _tf.height = 18;
    }

    ///////////////////////////////////
    // event handlers
    ///////////////////////////////////

    ///////////////////////////////////
    // getter/setters
    ///////////////////////////////////

    /**
     * Gets / sets the text of this Label.
     */
    public var text(get, set):String;

    public function set_text(value:String):String {
        _text = value;
        if (_text == null) _text = "";
        invalidate();

        return _text;
    }

    public function get_text():String {
        return _text;
    }

    /**
     * Gets / sets whether or not this Label will autosize.
     */
    public var autoSize(get, set):Bool;

    public function set_autoSize(value:Bool):Bool {
        _autoSize = value;

        return _autoSize;
    }

    public function get_autoSize():Bool {
        return _autoSize;
    }

    /**
     * Gets the internal TextField of the label if you need to do further customization of it.
     */
    public var textField(get, never):TextField;

    public function get_textField():TextField {
        return _tf;
    }
}
