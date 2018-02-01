# Minimal Components

OpenFL port of Minimal Components by Keith Peters.

[API Documentation](http://jasonsturges.com/minimalcomps-openfl)

[MinimalComps OpenFL Designer](https://github.com/jasonsturges/minimalcomps-openfl-designer) is a compendium project enabling exploration of available components.

![designer](http://labs.jasonsturges.com/haxe/openfl/minimalcomps-designer/screenshot.png)

Launch demo: http://labs.jasonsturges.com/haxe/openfl/minimalcomps-designer/



## Installation

This library can be installed through any of the following ways.  

To use the latest release from haxelib:

    $ haxelib install minimalcomps
    
To use the latest development from GitHub:

    $ haxelib git minimalcomps https://github.com/jasonsturges/minimalcomps-openfl.git

To use a local copy as a development haxelib, clone this repo and link the source directory by executing:
 
    $ git clone https://github.com/jasonsturges/minimalcomps-openfl.git
    $ haxelib dev minimalcomps ./minimalcomps-openfl

     
## Project Setup

For inclusion into a Haxe project, add this library by updating your project.xml:

    <project>
        ...
        <haxelib name="minimalcomps" />
        ...
    </project>


## Themes, fonts, and color styles

Two color themes are included, which setup both colors and the default [pf_ronda_seven.ttf](https://github.com/jasonsturges/minimalcomps-openfl/blob/master/Assets/Fonts/pf_ronda_seven.ttf) font for your project; however, additional configuration of colors and fonts are possible.


### Themes

There are two themes included: Light and Dark.

When using these themes, call `Style.setStyle()` before creating any components:

    import minimalcomps.components.Style;
    
    Style.setStyle(Style.DARK);
    Style.setStyle(Style.LIGHT);


### Colors

For additional configuration of custom styles, update properties of the `Style` class.

    import minimalcomps.components.Style;
    
    Style.BACKGROUND = 0xCCCCCC;
    Style.BUTTON_FACE = 0xFFFFFF;
    Style.BUTTON_DOWN = 0xEEEEEE;
    Style.INPUT_TEXT = 0x333333;
    Style.LABEL_TEXT = 0x666666;
    Style.PANEL = 0xF3F3F3;
    Style.PROGRESS_BAR = 0xFFFFFF;
    Style.TEXT_BACKGROUND = 0xFFFFFF;
    Style.LIST_DEFAULT = 0xFFFFFF;
    Style.LIST_ALTERNATE = 0xF3F3F3;
    Style.LIST_SELECTED = 0xCCCCCC;
    Style.LIST_ROLLOVER = 0xDDDDDD;


### Fonts

To use a custom font in your project, place the font within your project's Assets/Fonts folder:

    [project root]/Assets/Fonts/my-font.ttf

Update your project.xml to include the font definition:

    <project>
        ...
        <assets path="Assets/Fonts" rename="fonts" if="html5">
            <font path="my-font.ttf" id="my-font" />
        </assets>
        ...
    </project>

In your project's source code, embed the font using the following class definition:

    import openfl.text.Font;
    
    @:font("Assets/Fonts/my-font.ttf") private class MyFont extends Font {}

Finally, add the following code to register the font and set the `Style` class `fontName`:

    import openfl.Assets;
    import openfl.text.Font;
    import minimalcomps.components.Style;
    
    #if js
        Style.fontName = Assets.getFont("my-font").fontName;
    #else
        Font.registerFont(MyFont);
        Style.fontName = (new MyFont()).fontName;
    #end


## Generating Dox Documentation

To generate documentation using dox, execute:

    haxe documentation.hxml
    
    
## License

This project is free, open-source software under the [MIT license](LICENSE.md).

Copyright (c) 2017 [Jason Sturges](http://jasonsturges.com)

Copyright (c) 2011 Keith Peters
