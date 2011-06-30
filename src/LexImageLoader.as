/**
 * Created by IntelliJ IDEA.
 * User: lex
 * Date: 21.06.11
 * Time: 12:41
 * To change this template use File | Settings | File Templates.
 */
package {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.net.URLRequest;

public class LexImageLoader {
    protected var imgLoader:Loader=new Loader();

    public function LexImageLoader(url:String,callback:Function,id='') {
        imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(e:Event){
            callback(e.currentTarget.content.bitmapData,url,id);
        })
        imgLoader.load(new URLRequest(url));
    }
}
}
