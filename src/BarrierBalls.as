/**
 * Created by IntelliJ IDEA.
 * User: lex
 * Date: 16.06.11
 * Time: 11:45
 * To change this template use File | Settings | File Templates.
 */
package {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.utils.ByteArray;

public class BarrierBalls {
    var radius:Number;
    var essence:Sprite;
    function clone(source:Object):* {
        var copier:ByteArray = new ByteArray();
        copier.writeObject(source);
        copier.position = 0;
        return(copier.readObject());
    }

    public function BarrierBalls(x,y,r:Number, texture:BitmapData) {
        radius=r;
        essence = new Sprite();
        var b = new Bitmap(texture);
        b.x=-r;
        b.y=-r;
        b.smoothing=true;
        b.width=r*2
        b.height=r*2;
        essence.x = x;
        essence.y = y;

        var mask:Shape=new Shape();
        b.cacheAsBitmap=true;
        mask.cacheAsBitmap=true;
        mask.graphics.beginFill(0x000000);
        mask.graphics.drawCircle(0,0,r);
        mask.graphics.endFill();
        b.mask=mask;
        essence.addChild(b);
        essence.addChild(mask);
//        essence.graphics.beginFill(bColor);
//        essence.graphics.drawCircle(0,0,radius);
//        essence.graphics.endFill();
    }
}
}