/**
 * List.as
 * Keith Peters
 * version 0.9.10
 * 
 * A scrolling list of selectable items. 
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

import openfl.display.Sprite;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.events.MouseEvent;


// TODO: Evaluate List<T> implementation
class List extends Component {
    private var _items:Array<Dynamic>;
    private var _itemHolder:Sprite;
    private var _panel:Panel;
    private var _listItemHeight:Float = 20;
    private var _listItemClass:Class<ListItem> = ListItem;
    private var _scrollbar:VScrollBar;
    private var _selectedIndex:Int = -1;
    private var _defaultColor:UInt = Style.LIST_DEFAULT;
    private var _alternateColor:UInt = Style.LIST_ALTERNATE;
    private var _selectedColor:UInt = Style.LIST_SELECTED;
    private var _rolloverColor:UInt = Style.LIST_ROLLOVER;
    private var _alternateRows:Bool = false;

    /**
     * Constructor
     * @param parent The parent DisplayObjectContainer on which to add this List.
     * @param xpos The x position to place this component.
     * @param ypos The y position to place this component.
     * @param items An array of items to display in the list. Either strings or objects with label property.
     */
    public function new(parent:DisplayObjectContainer = null, xpos:Float = 0.0, ypos:Float = 0.0, items:Array<Dynamic> = null) {
        if (items != null) {
            _items = items;
        }
        else {
            _items = new Array();
        }
        super(parent, xpos, ypos);
    }

    /**
     * Initilizes the component.
     */
    private override function init():Void {
        super.init();
        setSize(100, 100);
        addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
        addEventListener(Event.RESIZE, onResize);
        makeListItems();
        fillItems();
    }

    /**
     * Creates and adds the child display objects of this component.
     */
    private override function addChildren():Void {
        super.addChildren();
        _panel = new Panel(this, 0, 0);
        _panel.color = _defaultColor;
        _itemHolder = new Sprite();
        _panel.content.addChild(_itemHolder);
        _scrollbar = new VScrollBar(this, 0, 0, onScroll);
        _scrollbar.setSliderParams(0, 0, 0);
    }

    /**
     * Creates all the list items based on data.
     */
    private function makeListItems():Void {
        var item:ListItem;
        while (_itemHolder.numChildren > 0) {
            item = cast(_itemHolder.getChildAt(0), ListItem);
            item.removeEventListener(MouseEvent.CLICK, onSelect);
            _itemHolder.removeChildAt(0);
        }

        var numItems:Int = Math.ceil(_height / _listItemHeight);
        numItems = Math.floor(Math.min(numItems, _items.length));
        numItems = Math.floor(Math.max(numItems, 1));
        for (i in 0 ... numItems) {
            item = Type.createInstance(_listItemClass, [_itemHolder, 0, i * _listItemHeight]);
            item.setSize(width, _listItemHeight);
            item.defaultColor = _defaultColor;

            item.selectedColor = _selectedColor;
            item.rolloverColor = _rolloverColor;
            item.addEventListener(MouseEvent.CLICK, onSelect);
        }
    }

    private function fillItems():Void {
        var offset:Int = Math.floor(_scrollbar.value);
        var numItems:Int = Math.ceil(_height / _listItemHeight);
        numItems = Math.floor(Math.min(numItems, _items.length));
        for (i in 0 ... numItems) {
            var item:ListItem = cast(_itemHolder.getChildAt(i), ListItem);
            if (offset + i < _items.length) {
                item.data = _items[offset + i];
            }
            else {
                item.data = "";
            }
            if (_alternateRows) {
                item.defaultColor = ((offset + i) % 2 == 0) ? _defaultColor : _alternateColor;
            }
            else {
                item.defaultColor = _defaultColor;
            }
            if (offset + i == _selectedIndex) {
                item.selected = true;
            }
            else {
                item.selected = false;
            }
        }
    }

    /**
     * If the selected item is not in view, scrolls the list to make the selected item appear in the view.
     */
    private function scrollToSelection():Void {
        var numItems:Int = Math.ceil(_height / _listItemHeight);
        if (_selectedIndex != -1) {
            if (_scrollbar.value > _selectedIndex) {
                //_scrollbar.value = _selectedIndex;
            }
            else if (_scrollbar.value + numItems < _selectedIndex) {
                _scrollbar.value = _selectedIndex - numItems + 1;
            }
        }
        else {
            _scrollbar.value = 0;
        }
        fillItems();
    }


    ///////////////////////////////////
    // public methods
    ///////////////////////////////////

    /**
     * Draws the visual ui of the component.
     */
    public override function draw():Void {
        super.draw();

        _selectedIndex = Math.floor(Math.min(_selectedIndex, _items.length - 1));

        // panel
        _panel.setSize(_width, _height);
        _panel.color = _defaultColor;
        _panel.draw();

        // scrollbar
        _scrollbar.x = _width - 10;
        var contentHeight:Float = _items.length * _listItemHeight;
        _scrollbar.setThumbPercent(_height / contentHeight);
        var pageSize:Int = Math.floor(_height / _listItemHeight);
        _scrollbar.maximum = Math.floor(Math.max(0, _items.length - pageSize));
        _scrollbar.pageSize = pageSize;
        _scrollbar.height = _height;
        _scrollbar.draw();
        scrollToSelection();
    }

    /**
     * Adds an item to the list.
     * @param item The item to add. Can be a string or an object containing a string property named label.
     */
    public function addItem(item:Dynamic):Void {
        _items.push(item);
        invalidate();
        makeListItems();
        fillItems();
    }

    /**
     * Adds an item to the list at the specified index.
     * @param item The item to add. Can be a string or an object containing a string property named label.
     * @param index The index at which to add the item.
     */
    public function addItemAt(item:Dynamic, index:Int):Void {
        index = Math.floor(Math.max(0, index));
        index = Math.floor(Math.min(_items.length, index));
        _items.insert(index, item);
        invalidate();
        makeListItems();
        fillItems();
    }

    /**
     * Removes the referenced item from the list.
     * @param item The item to remove. If a string, must match the item containing that string. If an object, must be a reference to the exact same object.
     */
    public function removeItem(item:Dynamic):Void {
        var index:Int = _items.indexOf(item);
        removeItemAt(index);
    }

    /**
     * Removes the item from the list at the specified index
     * @param index The index of the item to remove.
     */
    public function removeItemAt(index:Int):Void {
        if (index < 0 || index >= _items.length) return;
        _items.splice(index, 1);
        invalidate();
        makeListItems();
        fillItems();
    }

    /**
     * Removes all items from the list.
     */
    public function removeAll():Void {
        _items = [];
        invalidate();
        makeListItems();
        fillItems();
    }


    ///////////////////////////////////
    // event handlers
    ///////////////////////////////////

    /**
     * Called when a user selects an item in the list.
     */
    private function onSelect(event:Event):Void {
        if (!Std.is(event.target, ListItem))
            return;

        var offset:Int = Math.floor(_scrollbar.value);

        for (i in 0 ... _itemHolder.numChildren) {
            if (_itemHolder.getChildAt(i) == event.target) _selectedIndex = i + offset;
            cast(_itemHolder.getChildAt(i), ListItem).selected = false;
        }
        cast(event.target, ListItem).selected = true;
        dispatchEvent(new Event(Event.SELECT));
    }

    /**
     * Called when the user scrolls the scroll bar.
     */
    private function onScroll(event:Event):Void {
        fillItems();
    }

    /**
     * Called when the mouse wheel is scrolled over the component.
     */
    private function onMouseWheel(event:MouseEvent):Void {
        _scrollbar.value -= event.delta;
        fillItems();
    }

    private function onResize(event:Event):Void {
        makeListItems();
        fillItems();
    }


    ///////////////////////////////////
    // getter/setters
    ///////////////////////////////////

    /**
     * Sets / gets the index of the selected list item.
     */
    public var selectedIndex(get, set):Int;

    public function set_selectedIndex(value:Int):Int {
        if (value >= 0 && value < _items.length) {
            _selectedIndex = value;
//				_scrollbar.value = _selectedIndex;
        }
        else {
            _selectedIndex = -1;
        }
        invalidate();
        dispatchEvent(new Event(Event.SELECT));

        return _selectedIndex;
    }

    public function get_selectedIndex():Int {
        return _selectedIndex;
    }

    /**
     * Sets / gets the item in the list, if it exists.
     *
     * TODO: Rework selected item
     */
    public var selectedItem(get, set):Dynamic;

    public function set_selectedItem(item:Dynamic):Dynamic {
        var index:Int = _items.indexOf(item);
        selectedIndex = index;
        invalidate();
        dispatchEvent(new Event(Event.SELECT));

        return _items.indexOf(item);
    }

    public function get_selectedItem():Dynamic {
        if (_selectedIndex >= 0 && _selectedIndex < _items.length) {
            return _items[_selectedIndex];
        }
        return null;
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

    /**
     * Sets the height of each list item.
     */
    public var listItemHeight(get, set):Float;

    public function set_listItemHeight(value:Float):Float {
        _listItemHeight = value;
        makeListItems();
        invalidate();

        return _listItemHeight;
    }

    public function get_listItemHeight():Float {
        return _listItemHeight;
    }

    /**
     * Sets / gets the list of items to be shown.
     */
    public var items(get, set):Array<Dynamic>;

    public function set_items(value:Array<Dynamic>):Array<Dynamic> {
        _items = value;
        invalidate();

        return _items;
    }

    public function get_items():Array<Dynamic> {
        return _items;
    }

    /**
     * Sets / gets the class used to render list items. Must extend ListItem.
     */
    public var listItemClass(get, set):Class<ListItem>;

    public function set_listItemClass(value:Class<ListItem>):Class<ListItem> {
        _listItemClass = value;
        makeListItems();
        invalidate();

        return _listItemClass;
    }

    public function get_listItemClass():Class<ListItem> {
        return _listItemClass;
    }

    /**
     * Sets / gets the color for alternate rows if alternateRows is set to true.
     */
    public var alternateColor(get, set):UInt;

    public function set_alternateColor(value:UInt):UInt {
        _alternateColor = value;
        invalidate();

        return _alternateColor;
    }

    public function get_alternateColor():UInt {
        return _alternateColor;
    }

    /**
     * Sets / gets whether or not every other row will be colored with the alternate color.
     */
    public var alternateRows(get, set):Bool;

    public function set_alternateRows(value:Bool):Bool {
        _alternateRows = value;
        invalidate();

        return _alternateRows;
    }

    public function get_alternateRows():Bool {
        return _alternateRows;
    }

    /**
     * Sets / gets whether the scrollbar will auto hide when there is nothing to scroll.
    */
    public var autoHideScrollBar(get, set):Bool;

    public function set_autoHideScrollBar(value:Bool):Bool {
        _scrollbar.autoHide = value;

        return _scrollbar.autoHide;
    }

    public function get_autoHideScrollBar():Bool {
        return _scrollbar.autoHide;
    }
}
