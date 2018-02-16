import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1

import Ros 1.0

Item {
    property string text: ""
    property var imageNames: ['class','bored','confused','game']
    id: activityType
    anchors.fill:parent
    visible: false
    Rectangle{
        id: background
        property string name: "background"
        anchors.fill:parent
        color: "ghostwhite"
    }


    Item {
        id: instructionScreen
        anchors.top: parent.top
        anchors.topMargin: height/8
        anchors.horizontalCenter: parent.horizontalCenter
        visible: true
        height: parent.height*.2
        width: parent.width*2./3
        property string text: "Please, select which image you think describes the activity we've just done together."
        z: 0

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: parent.height
            color: "AliceBlue"
            border.color: "black"
            border.width: width/100
            radius: width / 10
            Label {
                id: instructionText
                width: parent.width * .8
                font.pixelSize: 50
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
                text: instructionScreen.text
                wrapMode: Text.WordWrap
            }
        }
        onVisibleChanged: {
            if (visible)
                blockingSpeech.text = text
        }
    }

    Rectangle{
        id: rec0
        width: parent.width/6
        height: width
        radius: width/2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: parent.width/4
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: parent.height/4
        property bool selected: false
        property string imageName: imageNames[0]
        color: "transparent"
        border.width: width/20
        border.color:"transparent"
        Image {
            id: image0
            visible: true
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: .8*parent.width
            source: "res/"+parent.imageName+".png"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: parent.selected=!parent.selected
        }
        onSelectedChanged: {
            if(selected){
                border.color="green"
                rec1.selected=false
                rec2.selected=false
                rec3.selected=false
            }
            else
                border.color="transparent"
        }
    }
    Rectangle{
        id: rec1
        width: parent.width/6
        height: width
        radius: width/2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: -parent.width/4
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: parent.height/4
        property bool selected: false
        property string imageName: imageNames[1]
        color: "transparent"
        border.width: width/20
        border.color:"transparent"
        Image {
            id: image1
            visible: true
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: .8*parent.width
            source: "res/"+parent.imageName+".png"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: parent.selected=!parent.selected
        }
        onSelectedChanged: {
            if(selected){
                border.color="green"
                rec0.selected=false
                rec2.selected=false
                rec3.selected=false
            }
            else
                border.color="transparent"
        }
    }
    Rectangle{
        id: rec2
        width: parent.width/6
        height: width
        radius: width/2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: -parent.width/4
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -parent.height/8
        property bool selected: false
        property string imageName: imageNames[2]
        color: "transparent"
        border.width: width/20
        border.color:"transparent"
        Image {
            id: image2
            visible: true
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: .8*parent.width
            source: "res/"+parent.imageName+".png"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: parent.selected=!parent.selected
        }
        onSelectedChanged: {
            if(selected){
                border.color="green"
                rec1.selected=false
                rec0.selected=false
                rec3.selected=false
            }
            else
                border.color="transparent"
        }
    }
    Rectangle{
        id: rec3
        width: parent.width/6
        height: width
        radius: width/2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: parent.width/4
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -parent.height/8
        property bool selected: false
        property string imageName: imageNames[3]
        color: "transparent"
        border.width: width/20
        border.color:"transparent"
        Image {
            id: image3
            visible: true
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: .8*parent.width
            source: "res/"+parent.imageName+".png"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: parent.selected=!parent.selected
        }
        onSelectedChanged: {
            if(selected){
                border.color="green"
                rec1.selected=false
                rec2.selected=false
                rec0.selected=false
            }
            else
                border.color="transparent"
        }
    }

    Rectangle{
        id: continueButton
        anchors.right: parent.right
        anchors.rightMargin: parent.width/40
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.width/40
        width: parent.width/15
        height: width
        radius: width/2
        color: "green"
        border.color: "black"
        border.width: width / 10
        visible: true
        Label{
            anchors.fill: parent
            horizontalAlignment: Label.AlignHCenter
            verticalAlignment: Label.AlignVCenter
            font.pixelSize: 20
            font.bold: true
            text: "Continue"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                activityType.visible = false
                interactionEventsPub.text = "stoprecord"
                informationScreen.text = "Thank you for playing the game!"
                var log=[]
                if(rec0.selected){
                    log=["activityType", imageNames[0]]
                    fileio.write(window.qlogfilename, log.join(","));
                }
                if(rec1.selected){
                    log=["activityType", imageNames[1]]
                    fileio.write(window.qlogfilename, log.join(","));
                }
                if(rec2.selected){
                    log=["activityType", imageNames[2]]
                    fileio.write(window.qlogfilename, log.join(","));
                }
                if(rec3.selected){
                    log=["activityType", imageNames[3]]
                    fileio.write(window.qlogfilename, log.join(","));
                }
                init()
            }
        }
    }

    function init(){
        rec0.selected=false
        rec1.selected=false
        rec2.selected=false
        rec3.selected=false
    }

    /*
    Item {
        id: instructionScreen
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        visible: true
        height: parent.height*.1
        property string text: "Please, connect each animal to their food \n (Keep in mind that one animal can eat multiple things)."
        z: 0

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width / 2
            height: parent.height / 2
            color: "AliceBlue"
            border.color: "black"
            border.width: width/100
            radius: width / 10
            Label {
                id: instructionText
                width: parent.width * .8
                font.pixelSize: 50
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
                text: instructionScreen.text
                wrapMode: Text.WordWrap
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        property var lastArrow: null

        onPressed: {
            var obj = images.childAt(mouseX, mouseY)
            if (obj !== null){
                if(obj.target)
                    return
                var component = Qt.createComponent("Arrow.qml")
                lastArrow = component.createObject(arrows,{"origin":obj, "end":Qt.point(mouseX,mouseY)})
                moving = true
                events.text = "touched_"+obj.name
            }
        }
        onPositionChanged: {
            if(moving){
                lastArrow.end = Qt.point(mouseX, mouseY)
                lastArrow.paint()
            }
        }
        onReleased: {
            if(moving){
                moving = false
                var obj = images.childAt(mouseX, mouseY)
                if (obj !== null && obj.name !== lastArrow.origin.name){
                    for(var i=arrows.children.length-2;i>=0;i--){
                        if(arrows.children[i].origin.name === lastArrow.origin.name && arrows.children[i].end.name === obj.name){
                            lastArrow.destroy()
                            events.text = "double"
                            return
                        }
                    }
                    lastArrow.end=obj
                    lastArrow.paint()
                    lastArrow.buttonVisible=true
                    lastArrow.origin.arrows += 1
                    testReady()
                    events.text = "create_"+lastArrow.origin.name+"_"+obj.name
                }
                else{
                    lastArrow.destroy()
                    events.text = "cancel"
                }
            }
        }
    }


    Item {
        id:arrows
        visible: true
        anchors.fill:parent
    }

    Rectangle {
        id: informationScreen
        anchors.fill: parent
        visible: false
        property string text: "Are you sure that all the animals are connected to their food?"
        z: 10
        color: "grey"
        opacity: .8
        onVisibleChanged: {
            if (visible)
                blockingSpeech.text = text
        }
        onTextChanged: {
            if (visible)
                blockingSpeech.text = text
        }

        MouseArea{
            anchors.fill: parent
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width / 1.8
            height: parent.height / 1.8
            color: "AliceBlue"
            border.color: "black"
            border.width: width/100
            radius: width / 10
            Label {
                id: informationText
                width: parent.width*.8
                font.pixelSize: 50
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -parent.height/4
                horizontalAlignment: Text.AlignHCenter
                text: informationScreen.text
                wrapMode: Text.WordWrap
            }
            StarDisplay{
                id: starDisplay
                width: parent.width/2
                height: parent.height/4
                visible: false
            }
            Button {
                id: buttonReturn
                width: parent.width/3
                height: parent.height/5
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: -parent.height/3
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: parent.height/4
                text: "Keep connecting"
                visible: true
                style: ButtonStyle {
                    background: Rectangle {
                                border.width: width/40
                                border.color: "black"
                                radius: 2*border.width
                                color: "orange"
                            }
                    label: Text {
                        font.family: "Helvetica"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                        font.pointSize: 30
                        text: buttonReturn.text
                    }
                }
                onClicked: {
                    events.text = "keep_connect"
                    informationScreen.visible=false
                }

            }
            Button {
                id: buttonContinue
                width: parent.width/3
                height: parent.height/5
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: parent.height/3
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: parent.height/4
                text: "I connected all I know"
                visible: false
                style: ButtonStyle {
                    background: Rectangle {
                                border.width: width/40
                                border.color: "black"
                                radius: 2*border.width
                                color: "green"
                            }
                    label: Text {
                        font.family: "Helvetica"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                        font.pointSize: 30
                        text: buttonContinue.text
                    }
                }
                onClicked: {
                    showstars()
                }
            }

            Button {
                id: buttonFinish
                width: parent.width/3
                height: parent.height/5
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: parent.height/4
                text: "Continue"
                visible: false
                style: ButtonStyle {
                    background: Rectangle {
                                border.width: width/40
                                border.color: "black"
                                radius: 2*border.width
                                color: "green"
                            }
                    label: Text {
                        font.family: "Helvetica"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                        font.pointSize: 30
                        text: buttonFinish.text
                    }
                }
                onClicked: {
                    //informationScreen.visible=false
                    stop()
                }
            }
            onVisibleChanged: {
                if(visible){
                    buttonContinue.visible = false
                    buttonReturn.visible = false
                    buttonFinish.visible = false
                    starDisplay.visible = false
                    showButtonTimer.start()
                }
            }
            Timer{
                id:showButtonTimer
                interval: 2000
                onTriggered: {
                    buttonContinue.visible = true
                    buttonReturn.visible = true
                }
            }
        }
    }


    Rectangle{
        id: continueButton
        anchors.right: parent.right
        anchors.rightMargin: parent.width/40
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.width/40
        width: parent.width/15
        height: width
        radius: width/2
        color: "green"
        border.color: "black"
        border.width: width / 10
        visible: true
        Label{
            anchors.fill: parent
            horizontalAlignment: Label.AlignHCenter
            verticalAlignment: Label.AlignVCenter
            font.pixelSize: 20
            font.bold: true
            text: "Continue"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                events.text = "continue"
                console.log(window.onlyGraph)
                if(window.onlyGraph){
                    var d = new Date()
                    var log = ["retention-test"+"-time", startingTime,d.getTime()]
                    var filename = "foodchain-data/post-test/"+d.toISOString().split(".")[0] + ".csv"
                    fileio.write(filename, log.join(","));
                    for(var i=arrows.children.length-1;i>=0;i--){
                        var log=[globalStates.state,arrows.children[i].origin.name, arrows.children[i].end.name]
                        arrows.children[i].destroy()
                        arrows.children[i].origin.arrows -= 1
                        fileio.write(filename, log.join(","));
                    }
                    return
                }

                if(testReady()){
                    if(arrows.children.length>imageNames.length-targets.length+1){
                        events.text = "good"
                        informationScreen.text = "Are you sure that all the animals are connected to their food?"
                    }
                    else{
                        informationScreen.text = "Are you sure that all the animals are connected to their food? Some animals eat many things."
                        events.text = "low_arrow"

                    }
                }
                else{
                    informationScreen.text = "Some animals don't have food, are you sure you want to continue?\nBy connecting more animals you could have more stars!"
                    events.text = "no_food"
                }
                informationScreen.visible = true
            }
        }
    }

    function testReady(){
        for(var i=images.children.length-1;i>=0;i--){
            if(targets.indexOf(images.children[i].name)>=0)
                continue
            if(images.children[i].arrows === 0){
                return false
            }
        }
        return true
    }

    function prepare() {
        for(var i=images.children.length-1;i>=0;i--)
            images.children[i].destroy()
        var offset = 250
        //Parameters ellipse
        var b=(graph.height-instructionScreen.height-offset)/2
        var a=(graph.width-offset)/2
        var h = (a-b)*(a-b)/(a+b)*(a+b)
        var perimeter = Math.PI*(a+b)*3*h/((Math.sqrt(3*h+4)+10))
        for(var i=0; i<imageNames.length;i++){
            var component = Qt.createComponent("ImageGraph.qml")
            var obj = component.createObject(images,{"name":imageNames[i]})
            obj.height = offset-50
            obj.width = offset-50
            var theta = angleOnEllipse(i,imageNames.length,perimeter,a,b)
            obj.x = a*Math.cos(theta)+graph.width/2-offset/4
            obj.y = b*Math.sin(theta)+(graph.height+instructionScreen.height)/2-offset/2
            if(targets.indexOf(imageNames[i])>=0)
                obj.target = true
         }
         ready=true
    }

    function angleOnEllipse(n,N,p,a,b){
        var increments = 10000
        var theta = 0
        var dtheta = 2*Math.PI/increments
        var partialp = 0
        var target = 2*n/N*p
        for(var i = 0; i < increments ;i++){
            if(partialp>target){
                return theta
            }
            partialp += Math.sqrt(Math.pow(a*Math.sin(theta),2)+Math.pow(b*Math.cos(theta),2))
            theta+=dtheta
        }
    }

    function start() {
        naoInstructions.text = "look_forward"
        if(ready == false)
            prepare()
        else
            instructionScreen.text = "Please, connect each animal to their food. \n (Remember one animal can eat multiple things)"
        //blockingSpeech.text = instructionScreen.text
        graph.visible = true
        var d = new Date()
        startingTime = d.getTime()
        events.text = "start"
    }

    function showstars(){
        informationScreen.text = "Let's look how many stars you got!"
        buttonContinue.visible = false
        buttonReturn.visible = false
        timerStar.start()
    }

    function getPerf(){
        var good = 0
        for(var i=arrows.children.length-1;i>=0;i--){
            console.log(arrows.children[i].origin.name)
            var items = interactiveitems.getActiveItems()
            for(var j=0;j<items.length;j++)
                if(items[j].name === arrows.children[i].origin.name && items[j].food.indexOf(arrows.children[i].end.name)>-1){
                    good +=1
                    continue
                }
        }

        var bad = arrows.children.length - good
        var diff = good - bad/2
        if(diff<-3)
            diff = -3
        var perf = Math.ceil((Math.sqrt(.8*diff+3.8))*2)/2

        return perf
    }

    Timer{
        id: timerStar
        interval: 2500
        onTriggered: {
            var perf = getPerf()
            informationScreen.text = "You got "+perf+" stars."
            totalStarsTest += perf
            starDisplay.showStars(perf)
            buttonFinish.visible = true
        }

    }

    function stop() {
        events.text = "stop"
        var d = new Date()
        var log = [globalStates.state+"-time", startingTime,d.getTime()]
        fileio.write(window.qlogfilename, log.join(","));
        for(var i=arrows.children.length-1;i>=0;i--){
            var log=[globalStates.state,arrows.children[i].origin.name, arrows.children[i].end.name]
            arrows.children[i].destroy()
            arrows.children[i].origin.arrows -= 1
            fileio.write(window.qlogfilename, log.join(","));
        }
        globalStates.state = nextState
        graph.visible = false
        informationScreen.visible = false
    }


    RosStringPublisher {
        id: events
        topic: "graph"
    }

    onVisibleChanged: {
        testReady()
    }*/
}
