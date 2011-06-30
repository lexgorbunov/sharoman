package {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.net.URLRequest;
import flash.sampler.pauseSampling;
import flash.system.Security;
import flash.system.SecurityDomain;
import flash.text.TextField;
import flash.events.KeyboardEvent;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.display.StageDisplayState;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import flash.utils.Timer;

import mx.controls.Alert;
import mx.controls.Text;


public class T2 extends Sprite {
    var ball:Sprite;
    var gun:Sprite = new Sprite();
    var gunPlatform:Sprite = new Sprite();
    var title:TextField = new TextField();
    var wallLeft:Sprite=new Sprite();
    var wallRight:Sprite=new Sprite();
    var gameOver:Boolean=false;
    var gameStart:Boolean=false;
    var firstFinish:Boolean=true;
    var gameOverHover:Sprite=new Sprite();
    var gameOverText:TextField=new TextField();
    var btnRestart:Sprite=new Sprite();
    var fsButton:Sprite=new Sprite();
    var loaderText:TextField;
    var values:Object={
    scrinState: 0,
    gunShotPower: 5,
    horizontalSpeed: 0,
    verticalSpeed: 0,

    horizontalGrowth: 1.11,
    keyShift: 3,
    keyShiftAcceleration: 1,
    gunAngle: 0,
    bottomLine:stage.stageHeight,
    topLine:-500
}
    var driftLeft:Boolean = false;
    var driftRight:Boolean = false;
    var pause:Boolean=false;
    protected var stageBackGround:Sprite=new Sprite();
    var colors:Object={
    backGround: 0xFFFFFF,
    wall: 0x003153,
    gun: 0x3d2b1f,
    ball: 0xe28b00,
    barrierBall: 0x082567
}
    var sizes:Object={
    wallWidth: 5,
    ballRadius: 18,
    gunHeight:100,
    gunWidth: 25
}
    var allCoords:Object={
    gunTrunk:Point
}
    var barrierBalls:Array=new Array();
    var imgLoader:Loader=new Loader();
    var images:Object={
        ball:null as BitmapData,
        barierBall:null as BitmapData
    }

    protected function run(firstRun:Boolean=true) {
        gameOver=false;
        gameStart=false;
        values.bottomLine=stage.stageHeight-sizes.gunHeight*2;
        gunPlatform.rotation=0;
        if(firstRun)
        {
            // Рисуем фон
            redrawBackGround(colors.backGround);
            stage.addChild(stageBackGround);
            // Масштабирование и выравнивание
            stage.scaleMode=StageScaleMode.NO_SCALE;
            stage.align=StageAlign.TOP_LEFT;

            allCoords.gunTrunk=new Point(stage.stageWidth/2, stage.stageHeight-sizes.gunHeight+sizes.gunWidth);
            // Добавляем текстовое поле
            title.autoSize=TextFieldAutoSize.CENTER;
            var titleFormat:TextFormat=new TextFormat();
            titleFormat.size=20;
            title.defaultTextFormat=titleFormat;
            stage.addChild(title);
            // Рисуем пушку
            gunPlatform.addChild(gun);
        }
        else
        {
            stage.removeChild(gameOverHover);
        }
        gunRedraw();
        if(firstRun)
        {
            gun.graphics.beginFill(colors.gun);
            gun.graphics.drawRoundRect(0, 0, sizes.gunWidth, sizes.gunHeight,25);
            gun.graphics.endFill();
        }
        stage.addChild(gunPlatform);
        gun.x=0-sizes.gunWidth/2;
        gun.y=0-sizes.gunHeight;
        // Рисуем стены
        if(firstRun)
        {
            wallLeft.graphics.beginFill(colors.wall);
            wallLeft.graphics.drawRect(0,0,sizes.wallWidth,stage.stageHeight);
            wallLeft.graphics.endFill();
            wallRight.graphics.beginFill(colors.wall);
            wallRight.graphics.drawRect(0,0,sizes.wallWidth,stage.stageHeight);
            wallRight.x=stage.stageWidth-sizes.wallWidth;
            wallRight.graphics.endFill();
            stage.addChild(wallLeft);
            stage.addChild(wallRight);
            // Рисуем кнопку на весь экран
            fsButton.graphics.beginFill(0x000000);
            fsButton.graphics.drawRoundRect(0,0,110,25,10);
            fsButton.graphics.endFill();
            var fsbText:TextField=new TextField();
            var txtFormat:TextFormat=new TextFormat();
            txtFormat.size=15;
            txtFormat.color=0xFFFFFF;
            txtFormat.bold=true;
            fsbText.defaultTextFormat=txtFormat;
            fsbText.autoSize=TextFieldAutoSize.LEFT;
            fsbText.x = 5;
            fsbText.y = 2;
            fsbText.text = 'На весь экран';
            fsButton.addChild(fsbText);
            stage.addChild(fsButton);
        }
        redrawFsButton();

        // Назначаем события
        if(firstRun){
            stage.addEventListener(Event.ENTER_FRAME, onEveryCadr);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
            stage.addEventListener(Event.RESIZE, onResize);

            fsButton.addEventListener(MouseEvent.CLICK, setFullScreen);
        }
        onResize(new Event(Event.RESIZE));
        stage.focus = stage;
    }

    function onLoad(img:BitmapData, url:String, id:String){
        switch(id){
            case 'ball':
                if(!images.ball)
                    images.ball=img;
            break;
            case 'barrierBall':
                if(!images.barrierBall)
                    images.barrierBall=img;
            break;
        }
    }

    public function T2() {
        loaderText=new TextField();
        var lftFormat:TextFormat=new TextFormat(null,20,0,true);
        loaderText.defaultTextFormat=lftFormat;
        loaderText.text='Идет загрузка изображений,\nпожалуста подождите...';
        loaderText.autoSize=TextFieldAutoSize.CENTER;
        loaderText.x=stage.stageWidth/2-loaderText.textWidth/2;
        loaderText.y=stage.stageHeight/2-loaderText.textHeight/2;
        stage.addChild(loaderText);
//        new LexImageLoader('img/ball.png',onLoad,'ball');
//        new LexImageLoader('img/barrierBall.jpeg',onLoad,'barrierBall');
        new LexImageLoader('http://lglab.ru/static/img/ball.png',onLoad,'ball');
        new LexImageLoader('http://lglab.ru/static/img/barrierBall.jpeg',onLoad,'barrierBall');
        // Ожидаем завершения загрузки всех текстур
        var t:Timer=new Timer(100);
        t.addEventListener(TimerEvent.TIMER, function(e:TimerEvent){
            if(images.ball==null || images.barrierBall==null)
                return;
            e.currentTarget.stop();
            stage.removeChild(loaderText);
            if(stage)
                run();
            else
                stage.addEventListener(Event.ADDED_TO_STAGE,run);
        });
        t.start();
    }

    function redrawBackGround(color:uint):void{
        stageBackGround.graphics.beginFill(color);
        stageBackGround.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
        stageBackGround.graphics.endFill();
    }
    public function gunRedraw(){
        gunPlatform.x = stage.stageWidth/2;
        gunPlatform.y = stage.stageHeight+sizes.gunWidth/2;
    }
    function finishGame(firstFinish:Boolean):void{
        values.horizontalSpeed=0;
        values.verticalSpeed=0;
        reMathGunTrunk();
        if(ball)
        {
            stage.removeChild(ball);
            ball=null;
        }
        this.firstFinish=false;
        killBarrierBall();
        if(firstFinish)
        {
            gameOverText.autoSize=TextFieldAutoSize.CENTER;
            gameOverText.text = 'Доигрался !!!';
            var etFormat=new TextFormat();
            etFormat.size=30;
            gameOverText.setTextFormat(etFormat);
            gameOverText.textColor=0xFFFFFF;
            gameOverHover.x=0;
            gameOverHover.y=0;
            gameOverHover.addChild(gameOverText);
        }
        redrawGameOverHover();
        if(firstFinish){
            btnRestart.graphics.beginFill(0xFFFFFF);
            btnRestart.graphics.drawRoundRect(0,0,100,25,10);
            btnRestart.graphics.endFill();
            var txtRestart:TextField=new TextField();
            var txtRestartFormat=new TextFormat(null,15,0x000000);
            txtRestart.defaultTextFormat=txtRestartFormat;
            txtRestart.autoSize=TextFieldAutoSize.LEFT;
            txtRestart.x=5;
            txtRestart.y=2;
            txtRestart.text = 'Начать заново';
            btnRestart.addChild(txtRestart);
            btnRestart.addEventListener(MouseEvent.CLICK,onBtnRestartClick)
            gameOverHover.addChild(btnRestart);
        }
        stage.addChild(gameOverHover);
    }
    function onBtnRestartClick(e:MouseEvent){
        run(false);
    }
    function redrawGameOverHover():void{
        gameOverHover.graphics.beginFill(0x000000);
        gameOverHover.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
        gameOverHover.graphics.endFill();
        gameOverText.x = stage.stageWidth/2-gameOverText.textWidth/2;
        gameOverText.y = stage.stageHeight/2-gameOverText.textHeight;
        btnRestart.x = stage.stageWidth/2-60;
        btnRestart.y = gameOverText.x+gameOverText.textHeight+5;
    }

    public function setFullScreen(e:MouseEvent){
        if(values.scrinState==0)
        {
            stage.displayState=StageDisplayState.FULL_SCREEN;
            values.scrinState=1;
        }
        else
        {
            stage.displayState=StageDisplayState.NORMAL;
            values.scrinState=0;
        }
    }

    function redrawFsButton(){
        fsButton.x = stage.stageWidth-100  - 20;
        fsButton.y = stage.stageHeight-25  - 5;
    }

    function reFillByBarrierBalls(topLine:Number,bottomLine:Number)
    {
        killBarrierBall();
        // Стряпаем барьерные шарики
        fillByBarrierBalls(topLine,bottomLine);
    }

    function fillByBarrierBalls(topLine:Number,bottomLine:Number){
        if(gameOver) return;
        for(var i=topLine;i<=bottomLine;i++){
            if( rangeRand(1,10) % 5 == 0 )
            {
                var bbx = rangeRand(sizes.wallWidth,stage.stageWidth-sizes.wallWidth);
                if(images.barrierBall!=null)
                {
                    var barrierBall = new BarrierBalls(bbx,i,rangeRand(4,15),images.barrierBall);//colors.barrierBall
                    barrierBalls.push(barrierBall);
                    stage.addChild(barrierBall.essence);
                }
            }
        }
    }

    function rangeRand(min,max:Number):Number{
        return Math.floor(Math.random() * (max-min)) + min;
    }

    function moveBarrierBalls(py:Number, bottomLine:Number):void{
        var i=0;
        for each (var bbal:BarrierBalls in barrierBalls) // Сдвигаем злые барьерные шары
        {
            if(bbal.essence==null) continue;
            bbal.essence.y+=py;
            if(bbal.essence.y>bottomLine)
            {
                stage.removeChild(bbal.essence);
                bbal.essence=null;
                bbal=null;
            }
            i++;
        }
        values.topLine+=py;
        if(values.topLine>0)
        {
            values.topLine=-500;
            fillByBarrierBalls(values.topLine,0);
        }
    }

    function hideGun(){
        stage.removeChild(gunPlatform);
    }

    function checkPossiblePoint(x,y:Number):CheckPossiblePoint {
        var res=new CheckPossiblePoint(x,y);
        res.possible = true;
        if(y+sizes.ballRadius>stage.stageHeight) // Улетел в низ [конец игры]
        {
            gameOver=true;
            res.possible=false;
            finishGame(this.firstFinish);
            return res;
        }
        if(x-sizes.ballRadius<wallLeft.x+sizes.wallWidth) // Левая стена
        {
            res.possible=false;
            res.barierName+=' левая стена ';
            res.barrierPoint=new Point(wallLeft.x+sizes.wallWidth+sizes.ballRadius,y);
            values.horizontalSpeed=Math.abs(values.horizontalSpeed);
        }
        if(x+sizes.ballRadius>wallRight.x) // Правая стена
        {
            res.possible=false;
            res.barierName+=' правая стена ';
            res.barrierPoint=new Point(wallRight.x-sizes.ballRadius,y);
            values.horizontalSpeed=Math.abs(values.horizontalSpeed)*(-1);
        }
        for each (var bbal:BarrierBalls in barrierBalls) // Злые барьерные шары
        {
            if(bbal.essence==null)continue;
            var x0=bbal.essence.x;
            var y0=bbal.essence.y;

            var r=bbal.radius+sizes.ballRadius;
            if( Math.pow(x-x0, 2)+Math.pow(y-y0, 2) < Math.pow(r,2) )
            {
                res.possible=false;
                res.barrierPoint = new Point(x-values.horizontalSpeed,y-values.verticalSpeed);
                res.barierName+=' шар ';
    //                // Вычисление угла м/у осью ОХ и касательной к окружности в точке столкновения
                var angleK=Math.atan((x-x0)/(y-y0))*180/Math.PI;
                if(((x-x0)<0)&&((y-y0)>=0))
                    angleK=(angleK)*(-1);
                else if(((x-x0)<=0)&&((y-y0)<0))
                    angleK=(180-angleK);
                else if(((x-x0)>=0)&&((y-y0)<0))
                    angleK=angleK*(-1)+180;
                else if(((x-x0)>0)&&((y-y0)>=0))
                    angleK=(90-angleK)+270;

//                bbal.essence.graphics.lineStyle(2,0x000000);
//                bbal.essence.graphics.moveTo(0,0);
//                bbal.essence.graphics.lineTo(-Math.cos(angleK*Math.PI/180)*30,-Math.sin(angleK*Math.PI/180)*30);
                
//                title.text = (Math.cos(angleK*Math.PI/180)*30).toString();
                var angleA:Number;

                var rot:Point;
                var vx=values.horizontalSpeed;
                var vy=values.verticalSpeed*(-1);
                rot = coordRotate(-angleK,new Point(vx,vy));
                vx=rot.x;
                vy=rot.y;
                vy*=-1;
                rot = coordRotate(angleK,new Point(vx,vy));
                vx=rot.x;
                vy=rot.y;
                values.horizontalSpeed=vx;
                values.verticalSpeed=-vy;
                break;
            }
        }
        return res;
    }

    // Поворот системы координат
    function coordRotate(angle:Number,p:Point):Point{
        var rAngle = angle*Math.PI/180;
        return new Point(p.x*Math.cos(rAngle)+p.y*Math.sin(rAngle),p.x*Math.sin(rAngle)*(-1)+p.y*Math.cos(rAngle));
    }

    protected function shot():void {
        if(gameStart)
            return;
        // Расчет параметров выстрела
        var h=values.gunShotPower*(-1);
        var w=Math.tan((gunPlatform.rotation+180)*Math.PI/180)*h;
        values.horizontalSpeed=-w;
        values.verticalSpeed=h;
        // Запуск ядра
        if(this.ball != null)
            return;
        // Рисуем ядро
        reMathGunTrunk();
        ball = new Sprite();
        var b:Bitmap = new Bitmap(images.ball);
        b.x=-sizes.ballRadius;
        b.y=-sizes.ballRadius;
        ball.x = allCoords.gunTrunk.x;
        ball.y = allCoords.gunTrunk.y;
        
        b.width=sizes.ballRadius*2;
        b.height=sizes.ballRadius*2;
        ball.addChild(b);
        
//        ball.graphics.beginFill(colors.ball);
//        ball.graphics.drawCircle(0,0,sizes.ballRadius);
//        ball.graphics.endFill();

        stage.addChild(ball);
        hideGun();
        gameStart=true;
    }
    function reMathGunTrunk():void{
        var px=Math.sin((gunPlatform.rotation+180)*Math.PI/180)*sizes.gunHeight;
        var py=Math.cos((gunPlatform.rotation+180)*Math.PI/180)*sizes.gunHeight;
        allCoords.gunTrunk.x=stage.stageWidth/2-px;
        allCoords.gunTrunk.y=gunPlatform.y+py;//stage.stageHeight-sizes.gunHeight+sizes.gunWidth+py;
    }
    protected function killBall() {
        if(this.ball == null) return;
        stage.removeChild(ball);
        ball = null;
    }

    function killBarrierBall(){
        var b:BarrierBalls;
        while(b = barrierBalls.pop())
        {
            if(b.essence)
                stage.removeChild(b.essence);
            b.essence = null;
            b = null;
        }
    }

    protected function ballRedraw() {
        if(this.ball == null) return;
        var newPosX:Number;
        var newPosY:Number;
        if( (ball.y+values.verticalSpeed-sizes.ballRadius<stage.stageHeight/4) && values.verticalSpeed<0 ) // Верхняя часть экрана
        {
            moveBarrierBalls(Math.abs(values.verticalSpeed),values.bottomLine);
            newPosY = ball.y;
        }
        else
        {
            newPosY = ball.y+values.verticalSpeed;
        }
        newPosX = ball.x+values.horizontalSpeed;
        var checkRes = checkPossiblePoint(newPosX,newPosY);
        if(checkRes.possible)
        {
            ball.x=newPosX;
            ball.y=newPosY;
        }
        else
        {
            if(checkRes.barrierPoint)
            {
                ball.x=checkRes.barrierPoint.x;
                ball.y=checkRes.barrierPoint.y;
            }
        }
    }

    protected function onEveryCadr(e:Event):void {
        if(gameOver || pause)
            return;
        if(driftLeft)
        {
            if(!gameStart)
            {
                // Поворот пушки
                if(gunPlatform.rotation>-72)
                    gunPlatform.rotation-=4;
            }
            // Смещение ядра
            if(this.ball == null || !gameStart || gameOver) return;
            var snos = (values.keyShift+values.keyShiftAcceleration)*(-1);
            var newPos:Number = (ball.x + snos);
            var checkRes = checkPossiblePoint(newPos,ball.y);
            if(checkRes.possible)
            {
                ball.x = newPos;
                values.keyShiftAcceleration*=values.horizontalGrowth;
            }
            else
            {
                if(checkRes.barrierPoint){
                    ball.x=checkRes.barrierPoint.x+sizes.ballRadius;}
            }
            if( (snos>0 && values.horizontalSpeed<0) || (snos<0 && values.horizontalSpeed>0) )
                values.horizontalSpeed*=(-1);
        }
        if(driftRight)
        {
            if(!gameStart)
            {
                // Поворот пушки
                if(gunPlatform.rotation<72)
                    gunPlatform.rotation+=4;
            }
            // Смещение ядра
            if(this.ball == null) return;
            var snos = values.keyShift+values.keyShiftAcceleration;
            var newPos:Number = (ball.x + snos);
            var checkRes = checkPossiblePoint(newPos,ball.y);
            if(checkRes.possible)
            {
                ball.x = newPos;
                values.keyShiftAcceleration*=values.horizontalGrowth;
            }
            else
            {
                if(checkRes.barrierPoint){
                    ball.x=checkRes.barrierPoint.x-sizes.ballRadius;}
            }
            if( (snos>0 && values.horizontalSpeed<0) || (snos<0 && values.horizontalSpeed>0) )
                values.horizontalSpeed*=(-1);
        }
        ballRedraw();
    }

    protected function onKeyDown(e:KeyboardEvent):void {trace(1);
        switch(e.keyCode){
            case 37://<=
                driftLeft=true;
                break;
            case 39://=>
                driftRight=true;
                break;
            case 38:
                this.shot();
                break;
        }
        if(e.altKey && e.keyCode==13)
            stage.displayState=StageDisplayState.FULL_SCREEN;
    }

    protected function onKeyUp(e:KeyboardEvent):void {
        switch(e.keyCode){
            case 37://<=
//                values.horizontalSpeed+=values.keyShiftAcceleration;
                values.keyShiftAcceleration=1;
                driftLeft=false;
                break;
            case 39://=>
//                values.horizontalSpeed-=values.keyShiftAcceleration;
                values.keyShiftAcceleration=1;
                driftRight=false;
                break;
            case 9://=>
//                pause = !pause;
                break;
        }
    }

    protected function onResize(e:Event){
        values.topLine=-500;
        values.bottomLine=stage.stageHeight-sizes.gunHeight*2;
        title.x = stage.stageWidth/2-title.textWidth/2;
        if(gameOver)
        {
            redrawGameOverHover();
            return;
        }
        redrawBackGround(colors.backGround);
        // Перемещение шара в границы окна
        if(ball!=null)
        {
            if(ball.x+sizes.ballRadius>stage.stageWidth-sizes.wallWidth) ball.x=stage.stageWidth-sizes.wallWidth-sizes.ballRadius;
            if(ball.y+sizes.ballRadius>stage.stageHeight) ball.y=stage.stageHeight-sizes.ballRadius*2;
        }
        // Перемещение пушки
        gunRedraw();
        reMathGunTrunk();
        // Перерисовка стен
        wallLeft.graphics.beginFill(colors.wall);
        wallLeft.graphics.drawRect(0,0,sizes.wallWidth,stage.stageHeight);
        wallLeft.graphics.endFill();
        wallRight.x = stage.stageWidth-sizes.wallWidth;
        wallRight.graphics.beginFill(colors.wall);
        wallRight.graphics.drawRect(0,0,sizes.wallWidth,stage.stageHeight);
        wallRight.graphics.endFill();
        reFillByBarrierBalls(values.topLine,values.bottomLine);

        redrawFsButton();
    }

//    public function checkPos(x:Number,y:Number):Boolean
//    {
//        if(x-sizes.ballRadius<=wallLeft.x+sizes.wallWidth) return false;
//        if(x+sizes.ballRadius>=wallRight.x) return false;
//        if(y-sizes.ballRadius<=0) return false;
//
//        return true;
//    }
    override public function set buttonMode(value:Boolean):void {
        super.buttonMode = value;
    }

    override public function get graphics():Graphics {
        return super.graphics;
    }
}
}
