/**
 * Created by IntelliJ IDEA.
 * User: lex
 * Date: 16.06.11
 * Time: 9:07
 * To change this template use File | Settings | File Templates.
 */
package {
import flash.geom.Point;

public class CheckPossiblePoint {
    public function CheckPossiblePoint(x:Number=0,y:Number=0) {
        this.checkedPoint=new Point(x,y);
    }
    public var possible:Boolean=false;
    public var checkedPoint:Point;
    public var barrierPoint:Point;
    public var barierName:String=new String('');
}
}
