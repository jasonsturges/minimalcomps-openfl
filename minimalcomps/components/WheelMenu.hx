/**
 * WheelMenu.as
 * Keith Peters
 * version 0.9.10
 * 
 * A radial menu that pops up around the mouse.
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
 * 
 * 
 * 
 * Components with text make use of the font PF Ronda Seven by Yuusuke Kamiyamane
 * This is a free font obtained from http://www.dafont.com/pf-ronda-seven.font
 */

package minimalcomps.components;

import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.filters.DropShadowFilter;


/**
 *  A radial menu that pops up around the mouse.
 */
class WheelMenu extends Component {
    private var _borderColor:UInt = 0xcccccc;
    private var _buttons:Array<ArcButton>;
    private var _color:UInt = 0xffffff;
    private var _highlightColor:UInt = 0xeeeeee;
    private var _iconRadius:Float;
    private var _innerRadius:Float;
    private var _items:Array<Dynamic>;
    private var _numButtons:Int;
    private var _outerRadius:Float;
    private var _selectedIndex:Int = -1;
    private var _startingAngle:Float = -90;


    /**
     * Constructor
     * @param parent The parent DisplayObjectContainer on which to add this component.
     * @param numButtons The number of segments in the menu
     * @param outerRadius The radius of the menu as a whole.
     * @parem innerRadius The radius of the inner circle at the center of the menu.
     * @param defaultHandler The event handling function to handle the default event for this component (select in this case).
     */
    public function new(parent:DisplayObjectContainer, numButtons:Int, outerRadius:Float = 80.0, iconRadius:Float = 60.0, innerRadius:Float = 10.0, defaultHandler:Dynamic = null) {
        _numButtons = numButtons;
        _outerRadius = outerRadius;
        _iconRadius = iconRadius;
        _innerRadius = innerRadius;
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        super(parent);

        if (defaultHandler != null) {
            addEventListener(Event.SELECT, defaultHandler);
        }
    }


    ///////////////////////////////////
    // private methods
    ///////////////////////////////////

    /**
     * Initializes the component.
     */
    override private function init():Void {
        super.init();
        _items = [];
        makeButtons();

        filters = [new DropShadowFilter(4, 45, 0, 1, 4, 4, .2, 4)];
    }

    /**
     * Creates the buttons that make up the wheel menu.
     */
    private function makeButtons():Void {
        _buttons = [];
        for (i in 0 ... _numButtons) {
            var btn:ArcButton = new ArcButton(Math.PI * 2 / _numButtons, _outerRadius, _iconRadius, _innerRadius);
            btn.id = i;
            btn.rotation = _startingAngle + 360 / _numButtons * i;
            btn.addEventListener(Event.SELECT, onSelect);
            addChild(btn);
            _buttons.push(btn);
        }
    }


    ///////////////////////////////////
    // public methods
    ///////////////////////////////////

    /**
     * Hides the menu.
     */
    public function hide():Void {
        visible = false;
        if (stage != null) {
            stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
        }
    }

    /**
     * Sets the icon / text and data for a specific menu item.
     * @param index The index of the item to set icon/text and data for.
     * @iconOrLabel Either a display object instance, a class that extends DisplayObject, or text to show in a label.
     * @data Any data to associate with the item.
     */
    public function setItem(index:Int, iconOrLabel:Dynamic, data:Dynamic = null):Void {
        _buttons[index].setIcon(iconOrLabel);
        _items[index] = data;
    }

    /**
     * Shows the menu - placing it on top level of parent and centering around mouse.
     */
    public function show():Void {
        parent.addChild(this);
        x = Math.round(parent.mouseX);
        y = Math.round(parent.mouseY);
        _selectedIndex = -1;
        visible = true;
        stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp, true);
    }


    ///////////////////////////////////
    // event handlers
    ///////////////////////////////////

    /**
     * Called when the component is added to the stage. Adds mouse listeners to the stage.
     */
    private function onAddedToStage(event:Event):Void {
        hide();
        addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
    }

    /**
     * Called when the component is removed from the stage. Removes mouse listeners from stage.
     */
    private function onRemovedFromStage(event:Event):Void {
        stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
        removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
    }

    /**
     * Called when one of the buttons is selected. Sets selected index and dispatches select event.
     */
    private function onSelect(event:Event):Void {
        _selectedIndex = cast(event.target, ArcButton).id;
        dispatchEvent(new Event(Event.SELECT));
    }

    /**
     * Called when mouse is released. Hides menu.
     */
    private function onStageMouseUp(event:MouseEvent):Void {
        hide();
    }


    ///////////////////////////////////
    // getter / setters
    ///////////////////////////////////

    /**
     * Gets / sets the color of the border around buttons.
     */
    public var borderColor(get, set):UInt;

    public function set_borderColor(value:UInt):UInt {
        _borderColor = value;
        for (i in 0 ... _numButtons) {
            _buttons[i].borderColor = _borderColor;
        }

        return _borderColor;
    }

    public function get_borderColor():UInt {
        return _borderColor;
    }

    /**
     * Gets / sets the base color of buttons.
     */
    public var color(get, set):UInt;

    public function set_color(value:UInt):UInt {
        _color = value;
        for (i in 0 ... _numButtons) {
            _buttons[i].color = _color;
        }

        return _color;
    }

    public function get_color():UInt {
        return _color;
    }

    /**
     * Gets / sets the highlighted color of buttons.
     */
    public var highlightColor(get, set):UInt;

    public function set_highlightColor(value:UInt):UInt {
        _highlightColor = value;

        for (i in 0 ... _numButtons) {
            _buttons[i].highlightColor = _highlightColor;
        }

        return _highlightColor;
    }

    public function get_highlightColor():UInt {
        return _highlightColor;
    }

    /**
     * Gets the selected index.
     */
    public var selectedIndex(get, never):Int;

    public function get_selectedIndex():Int {
        return _selectedIndex;
    }

    /**
     * Gets the selected item.
     */
    public var selectedItem(get, never):Dynamic;

    public function get_selectedItem():Dynamic {
        return _items[_selectedIndex];
    }

}
