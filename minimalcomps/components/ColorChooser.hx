/**
 * ColorChooser.as
 * Keith Peters
 * version 0.9.10
 *
 * A Color Chooser component, allowing textual input, a default gradient, or custom image.
 *
 * Copyright (c) 2011 Keith Peters
 *
 * popup color choosing code by Rashid Ghassempouri
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

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.GradientType;
import openfl.display.Graphics;
import openfl.display.InterpolationMethod;
import openfl.display.SpreadMethod;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Matrix;
import openfl.geom.Point;


/**
 *  A Color Chooser component, allowing textual input, a default gradient, or custom image.
 */
class ColorChooser extends Component {

    public static inline var TOP:String = "top";
    public static inline var BOTTOM:String = "bottom";

    private var _colors:BitmapData;
    private var _colorsContainer:Sprite;
    private var _defaultModelColors:Array<UInt> = [0xFF0000, 0xFFFF00, 0x00FF00, 0x00FFFF, 0x0000FF, 0xFF00FF, 0xFF0000, 0xFFFFFF, 0x000000];
    private var _input:InputText;
    private var _model:DisplayObject;
    private var _oldColorChoice:UInt = 0xff0000;
    private var _popupAlign:String = BOTTOM;
    private var _stage:Stage;
    private var _swatch:Sprite;
    private var _tmpColorChoice:UInt = 0xff0000;
    private var _usePopup:Bool = false;
    private var _value:UInt = 0xff0000;


    /**
     * Constructor
     * @param parent The parent DisplayObjectContainer on which to add this ColorChooser.
     * @param xpos The x position to place this component.
     * @param ypos The y position to place this component.
     * @param value The initial color value of this component.
     * @param defaultHandler The event handling function to handle the default event for this component (change in this case).
     */
    public function new(parent:DisplayObjectContainer = null, xpos:Float = 0, ypos:Float = 0, value:UInt = 0xff0000, defaultHandler:Dynamic = null) {
        _oldColorChoice = _tmpColorChoice = _value = value;

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

        _width = 65;
        _height = 15;
        value = _value;
    }

    override private function addChildren():Void {
        _input = new InputText();
        _input.width = 45;
        _input.restrict = "0123456789ABCDEFabcdef";
        _input.maxChars = 6;
        addChild(_input);
        _input.addEventListener(Event.CHANGE, onChange);

        _swatch = new Sprite();
        _swatch.x = 50;
        _swatch.filters = [getShadow(2, true)];
        addChild(_swatch);

        _colorsContainer = new Sprite();
        _colorsContainer.addEventListener(Event.ADDED_TO_STAGE, onColorsAddedToStage);
        _colorsContainer.addEventListener(Event.REMOVED_FROM_STAGE, onColorsRemovedFromStage);
        _model = getDefaultModel();
        drawColors(_model);
    }


    ///////////////////////////////////
    // public methods
    ///////////////////////////////////

    /**
     * Draws the visual ui of the component.
     */
    override public function draw():Void {
        super.draw();
        _swatch.graphics.clear();
        _swatch.graphics.beginFill(_value);
        _swatch.graphics.drawRect(0, 0, 16, 16);
        _swatch.graphics.endFill();
    }


    ///////////////////////////////////
    // event handlers
    ///////////////////////////////////

    /**
     * Internal change handler.
     * @param event The Event passed by the system.
     */
    private function onChange(event:Event):Void {
        event.stopImmediatePropagation();
        _value = Std.parseInt("0x" + _input.text);
        _input.text = _input.text.toUpperCase();
        _oldColorChoice = value;
        invalidate();
        dispatchEvent(new Event(Event.CHANGE));

    }


    ///////////////////////////////////
    // getter/setters
    ///////////////////////////////////

    /**
     * Gets / sets the color value of this ColorChooser.
     */
    public var value(get, set):UInt;

    public function set_value(value:UInt):UInt {
        var str:String = StringTools.hex(value, 6);
        _input.text = str;
        _value = Std.parseInt("0x" + _input.text);
        invalidate();

        return (_value);
    }

    public function get_value():UInt {
        return _value;
    }


    ///////////////////////////////////
    // COLOR PICKER MODE SUPPORT
    ///////////////////////////////////}

    public var model(get, set):DisplayObject;

    public function get_model():DisplayObject {
        return _model;
    }

    public function set_model(value:DisplayObject):DisplayObject {
        _model = value;
        if (_model != null) {
            drawColors(_model);
            if (!usePopup)
                usePopup = true;
        } else {
            _model = getDefaultModel();
            drawColors(_model);
            usePopup = false;
        }

        return _model;
    }

    private function drawColors(d:DisplayObject):Void {
        _colors = new BitmapData(Math.floor(d.width), Math.floor(d.height));
        _colors.draw(d);

        while (_colorsContainer.numChildren > 0)
            _colorsContainer.removeChildAt(0);

        _colorsContainer.addChild(new Bitmap(_colors));
        placeColors();
    }

    /**
     *
     */
    public var popupAlign(get, set):String;

    public function get_popupAlign():String { return _popupAlign; }

    public function set_popupAlign(value:String):String {
        _popupAlign = value;
        placeColors();

        return _popupAlign;
    }

    /**
     *
     */
    public var usePopup(get, set):Bool;

    public function get_usePopup():Bool { return _usePopup; }

    public function set_usePopup(value:Bool):Bool {
        _usePopup = value;

        _swatch.buttonMode = true;
        _colorsContainer.buttonMode = true;
        _colorsContainer.addEventListener(MouseEvent.MOUSE_MOVE, browseColorChoice);
        _colorsContainer.addEventListener(MouseEvent.MOUSE_OUT, backToColorChoice);
        _colorsContainer.addEventListener(MouseEvent.CLICK, setColorChoice);
        _swatch.addEventListener(MouseEvent.CLICK, onSwatchClick);

        if (!_usePopup) {
            _swatch.buttonMode = false;
            _colorsContainer.buttonMode = false;
            _colorsContainer.removeEventListener(MouseEvent.MOUSE_MOVE, browseColorChoice);
            _colorsContainer.removeEventListener(MouseEvent.MOUSE_OUT, backToColorChoice);
            _colorsContainer.removeEventListener(MouseEvent.CLICK, setColorChoice);
            _swatch.removeEventListener(MouseEvent.CLICK, onSwatchClick);
        }

        return _usePopup;
    }

    /**
     * The color picker mode Handlers
     */
    private function onColorsRemovedFromStage(e:Event):Void {
        _stage.removeEventListener(MouseEvent.CLICK, onStageClick);
    }

    private function onColorsAddedToStage(e:Event):Void {
        _stage = stage;
        _stage.addEventListener(MouseEvent.CLICK, onStageClick);
    }

    private function onStageClick(e:MouseEvent):Void {
        displayColors();
    }

    private function onSwatchClick(event:MouseEvent):Void {
        event.stopImmediatePropagation();
        displayColors();
    }

    private function backToColorChoice(e:MouseEvent):Void {
        value = _oldColorChoice;
    }

    private function setColorChoice(e:MouseEvent):Void {
        value = _colors.getPixel(Math.floor(_colorsContainer.mouseX), Math.floor(_colorsContainer.mouseY));
        _oldColorChoice = value;
        dispatchEvent(new Event(Event.CHANGE));
        displayColors();
    }

    private function browseColorChoice(e:MouseEvent):Void {
        _tmpColorChoice = _colors.getPixel(Math.floor(_colorsContainer.mouseX), Math.floor(_colorsContainer.mouseY));
        value = _tmpColorChoice;
    }

    /**
     * The color picker mode Display functions
     */
    private function displayColors():Void {
        placeColors();

        if (_colorsContainer.parent != null)
            _colorsContainer.parent.removeChild(_colorsContainer);
        else
            stage.addChild(_colorsContainer);
    }

    private function placeColors():Void {
        var point:Point = new Point(x, y);

        if (parent != null)
            point = parent.localToGlobal(point);

        switch (_popupAlign)
        {
            case TOP :
                _colorsContainer.x = point.x;
                _colorsContainer.y = point.y - _colorsContainer.height - 4;
            case BOTTOM :
                _colorsContainer.x = point.x;
                _colorsContainer.y = point.y + 22;
            default:
                _colorsContainer.x = point.x;
                _colorsContainer.y = point.y + 22;
        }
    }

    /**
     * Create the default gradient Model
     */
    private function getDefaultModel():Sprite {
        var w:Int = 100;
        var h:Int = 100;
        var bmd:BitmapData = new BitmapData(w, h);

        var g1:Sprite = getGradientSprite(w, h, _defaultModelColors);
        bmd.draw(g1);

        var blendmodes:Array<BlendMode> = [BlendMode.MULTIPLY, BlendMode.ADD];
        var nb:Int = blendmodes.length;
        var g2:Sprite = getGradientSprite(h / nb, w, [0xFFFFFF, 0x000000]);

        for (i in 0 ... nb) {
            var blendmode:String = blendmodes[i];
            var m:Matrix = new Matrix();
            m.rotate(-Math.PI / 2);
            m.translate(0, h / nb * i + h / nb);
            bmd.draw(g2, m, null, blendmode);
        }

        var s:Sprite = new Sprite();
        var bm:Bitmap = new Bitmap(bmd);
        s.addChild(bm);
        return(s);
    }

    private function getGradientSprite(w:Float, h:Float, gc:Array<UInt>):Sprite {
        var gs:Sprite = new Sprite();
        var g:Graphics = gs.graphics;
        var gn:Int = gc.length;
        var ga:Array<Float> = [];
        var gr:Array<Int> = [];
        var gm:Matrix = new Matrix();
        gm.createGradientBox(w, h, 0, 0, 0);
        for (i in 0 ... gn) {
            ga.push(1.0);
            gr.push(Math.floor(0x00 + 0xFF / (gn - 1) * i));
        }
        g.beginGradientFill(GradientType.LINEAR, gc, ga, gr, gm, SpreadMethod.PAD, InterpolationMethod.RGB);
        g.drawRect(0, 0, w, h);
        g.endFill();
        return(gs);
    }
}
