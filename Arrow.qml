import QtQuick 2.0

Item {

    id: arrow

    property var origin: null
    property var end: null
    property color color: "red"
    property bool buttonVisible: false
    z:10
    visible: true
    anchors.fill: parent

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        property var path: []
        property double angle: 0

        property int arrowHeadLength: 75 //px

        onPaint: {
            var i = 0;
            var p1 = {x: origin.x + origin.width/2,y:origin.y+origin.height/2}
            var p2 = {x: end.x,y:end.y}
            if(typeof end.name !== 'undefined')
                p2 = {x: end.x + end.width/2,y:end.y+end.height/2}
            else

            angle = -Math.atan2(p2.x-p1.x,p2.y-p1.y)+Math.PI/2
            p2.x -= (arrowHeadLength + 15) * Math.cos(angle);
            p2.y -= (arrowHeadLength + 15) * Math.sin(angle);
            deleteButton.x=(p1.x+p2.x)/2-deleteButton.radius
            deleteButton.y=(p1.y+p2.y)/2-deleteButton.radius

            mouth.rotation = angle / Math.PI * 180 - 45
            mouth.x=p2.x-mouth.width/2+mouth.width/2*Math.cos(angle)
            mouth.y=p2.y-mouth.width/2+mouth.width/2*Math.sin(angle)

            var ctx = canvas.getContext('2d');

            ctx.reset();
            ctx.lineJoin = "round"
            ctx.lineCap="round";

            ctx.lineWidth = 10;

            ctx.strokeStyle = arrow.color;
            ctx.fillStyle = arrow.color;


            ctx.beginPath();

            ctx.moveTo(p1.x, p1.y);

            ctx.lineTo(p2.x, p2.y);

            ctx.stroke();

            ctx.closePath();
            ctx.fill();
        }
    }
    Image{
        id: mouth
        fillMode: Image.PreserveAspectFit
        source: "res/mouth.png"
        width: 75
    }


    Rectangle{
        id: deleteButton
        width: 40
        height: width
        radius: width/2
        color: "red"
        border.color: "black"
        border.width: width / 10
        visible: buttonVisible
        Label{
            anchors.fill: parent
            horizontalAlignment: Label.AlignHCenter
            verticalAlignment: Label.AlignVCenter
            font.pixelSize: 20
            font.bold: true
            text: "X"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                origin.arrows -= 1
                arrow.destroy()
                testReady()
            }
        }
    }

    function paint(){
        canvas.requestPaint()
    }
}
