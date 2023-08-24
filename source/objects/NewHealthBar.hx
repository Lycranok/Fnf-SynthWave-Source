package objects;

import flixel.math.FlxPoint;
import flixel.math.FlxRect;

class NewHealthBar extends FlxSpriteGroup
{
    public var bars:FlxSprite;
    public var barsOutline:FlxSprite;
    public var outline:FlxSprite;

    public function new(x:Float, y:Float)
    {
        super(x, y);

        outline = new FlxSprite(x, y).loadGraphic(Paths.image('HealthBar/Outline'));
        outline.setGraphicSize(Std.int(outline.width * 0.58), Std.int(outline.height * 0.58));
        add(outline);

        bars = new FlxSprite(x, y).loadGraphic(Paths.image('HealthBar/Bars/4'));
        bars.setGraphicSize(Std.int(outline.width * 0.58), Std.int(outline.height * 0.58));
        add(bars);

        barsOutline = new FlxSprite(x, y);
        barsOutline.loadGraphic(Paths.image('HealthBar/Outlines/5'));
        barsOutline.setGraphicSize(Std.int(outline.width * 0.58), Std.int(outline.height * 0.58));
        add(barsOutline);

        outline.antialiasing = bars.antialiasing = barsOutline.antialiasing = ClientPrefs.data.antialiasing;
    }

    public function reloadHealthBar(number:Int = 0)
    {
        if(number == 0)
            bars.visible = false
        else
        {
            bars.visible = true;
            bars.loadGraphic(Paths.image('HealthBar/Bars/' + Std.int(number)));
        }

        barsOutline.loadGraphic(Paths.image('HealthBar/Outlines/' + Std.int(number + 1)));
    }
}