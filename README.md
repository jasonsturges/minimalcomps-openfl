# minimalcomps

OpenFL port of Keith Peters Minimal Components.

[API Documentation](http://jasonsturges.com/minimalcomps-openfl)


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

To use the default [pf_ronda_seven.ttf](https://github.com/jasonsturges/minimalcomps-openfl/blob/master/Assets/Fonts/pf_ronda_seven.ttf) font in your project, download the font and place it within your project's Assets/Fonts folder:

    [project root]/Assets/Fonts/pf_ronda_seven.ttf

Update your project.xml to include the font definition:

    <project>
        ...
        <assets path="Assets/Fonts" rename="fonts" if="html5">
            <font path="pf_ronda_seven.ttf" id="pf_ronda_seven" />
        </assets>
        ...
    </project>

In your project's source code, embed the font using the following class definition:

    @:font("Assets/Fonts/pf_ronda_seven.ttf") private class RondaSevenFont extends Font {}

Finally, add the following code to register the font and set the `Style` class `fontName`:

    import openfl.Assets;
    import openfl.text.Font;
    import minimalcomps.components.Style;
    
    #if js
        Style.fontName = Assets.getFont("pf_ronda_seven").fontName;
    #else
        Font.registerFont(RondaSevenFont);
        Style.fontName = (new RondaSevenFont()).fontName;
    #end
    

## Themes

There are two themes included: Light and Dark.

To set either theme, call `setStyle()`:

    import minimalcomps.components.Style;
    
    Style.setStyle(Style.DARK);
    Style.setStyle(Style.LIGHT);

For additional configuration of custom styles, update properties of the `Style` class.


## Generating Dox Documentation

To generate documentation using dox, execute:

    haxe documentation.hxml
    
    
## License

This project is free, open-source software under the [MIT license](LICENSE.md).

Copyright (c) 2017 [Jason Sturges](http://jasonsturges.com)

Copyright (c) 2011 Keith Peters
