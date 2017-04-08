/**
 * Component.as
 * Keith Peters
 * version 0.9.10
 * 
 * Base class for all components
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
import openfl.display.Sprite;
import openfl.display.StageScaleMode;
import openfl.display.Stage;
import openfl.display.StageAlign;
import openfl.events.Event;
import openfl.filters.DropShadowFilter;


class Component extends Sprite {
    private var _width:Float = 0.0;
    private var _height:Float = 0.0;
    private var _tag:Int = -1;
    private var _enabled:Bool = true;
    private var _invalidated:Bool = false;

    public static inline var DRAW:String = "draw";


    /**
     * Constructor
     * @param parent The parent DisplayObjectContainer on which to add this component.
     * @param xpos The x position to place this component.
     * @param ypos The y position to place this component.
     */
    public function new(parent:DisplayObjectContainer = null, xpos:Float = 0.0, ypos:Float = 0.0) {
        super();

        move(xpos, ypos);
        init();
        if (parent != null) {
            parent.addChild(this);
        }
    }

    /**
     * Initilizes the component.
     */
    private function init():Void {
        addChildren();
        invalidate();
    }

    /**
     * Overriden in subclasses to create child display objects.
     */
    private function addChildren():Void {
    }

    /**
     * DropShadowFilter factory method, used in many of the components.
     * @param dist The distance of the shadow.
     * @param knockout Whether or not to create a knocked out shadow.
     */
    private function getShadow(dist:Float, knockout:Bool = false):DropShadowFilter {
        return new DropShadowFilter(dist, 45, Style.DROPSHADOW, 1, dist, dist, .3, 1, knockout);
    }

    /**
     * Marks the component to be redrawn on the next frame.
     */
    private function invalidate():Void {
        if (_invalidated) 
            return;

        _invalidated = true;
        addEventListener(Event.ENTER_FRAME, onInvalidate);
    }


    ///////////////////////////////////
    // public methods
    ///////////////////////////////////

    /**
     * Utility method to set up usual stage align and scaling.
     */
    public static function initStage(stage:Stage):Void {
        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
    }

    /**
     * Moves the component to the specified position.
     * @param xpos the x position to move the component
     * @param ypos the y position to move the component
     */
    public function move(xpos:Float, ypos:Float):Void {
        x = Math.round(xpos);
        y = Math.round(ypos);
    }

    /**
     * Sets the size of the component.
     * @param w The width of the component.
     * @param h The height of the component.
     */
    public function setSize(w:Float, h:Float):Void {
        _width = w;
        _height = h;
        dispatchEvent(new Event(Event.RESIZE));
        invalidate();
    }

    /**
     * Abstract draw function.
     */
    public function draw():Void {
        dispatchEvent(new Event(Component.DRAW));
    }


    ///////////////////////////////////
    // event handlers
    ///////////////////////////////////

    /**
		 * Called one frame after invalidate is called.
		 */
    private function onInvalidate(event:Event):Void {
        removeEventListener(Event.ENTER_FRAME, onInvalidate);
        _invalidated = false;

        draw();
    }


    ///////////////////////////////////
    // getter/setters
    ///////////////////////////////////

    /**
     * Sets/gets the width of the component.
     */
    #if flash @:setter(width) #else override #end
    public function set_width(value:Float): #if flash Void #else Float #end {
        _width = value;
        invalidate();
        dispatchEvent(new Event(Event.RESIZE));

        #if !flash return _width; #end
    }

    #if flash @:getter(width) #else override #end
    public function get_width():Float {
        return _width;
    }

    /**
     * Sets/gets the height of the component.
     */
    #if flash @:setter(height) #else override #end
    public function set_height(value:Float): #if flash Void #else Float #end {
        _height = value;
        invalidate();
        dispatchEvent(new Event(Event.RESIZE));

        #if !flash return _height; #end
    }

    #if flash @:getter(height) #else override #end
    public function get_height():Float {
        return _height;
    }

    /**
     * Sets/gets in integer that can identify the component.
     */
    public var tag(get, set):Int;

    public function set_tag(value:Int):Int {
        return _tag = value;
    }

    public function get_tag():Int {
        return _tag;
    }

    /**
     * Overrides the setter for x to always place the component on a whole pixel.
     */
    #if flash @:setter(x) #else override #end
    public function set_x(value:Float): #if flash Void #else Float #end {
        super.x = Math.round(value);
        #if !flash return super.x; #end
    }

    /**
     * Overrides the setter for y to always place the component on a whole pixel.
     */
    #if flash @:setter(y) #else override #end
    public function set_y(value:Float): #if flash Void #else Float #end {
        super.y = Math.round(value);
        #if !flash return super.y; #end
    }

    /**
     * Sets/gets whether this component is enabled or not.
     */
    public var enabled(get, set):Bool;

    public function set_enabled(value:Bool):Bool {
        _enabled = value;
        mouseEnabled = mouseChildren = _enabled;
        tabEnabled = value;
        alpha = _enabled ? 1.0 : 0.5;

        return _enabled;
    }

    public function get_enabled():Bool {
        return _enabled;
    }
}
