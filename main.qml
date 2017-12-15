import QtQuick 2.2
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import Box2D 2.0
import QtTest 1.1

import Ros 1.0

Window {

    id: window

    visible: true
    visibility: Window.FullScreen
    width:800
    height: 600

    property int prevWidth:800
    property int prevHeight:600

    property string  qlogfilename: ""
    property int rounds: 0
    property int maxRounds: 4
    property double totalPoints: 0
    property int animalLimit: 7
    property bool inGame: false
    property double hungerRate: 0.0075

    onWidthChanged: {
        prevWidth=width;
    }
    onHeightChanged: {
        prevHeight=height;
    }
    color: "black"
    title: qsTr("Free-play sandbox")

    StateGroup {
        id: globalStates
        states: [
            State {
                name: "demoQuestion"
                PropertyChanges { target: questions; visible: true}
                PropertyChanges { target: genderquestion; visible: true}
                PropertyChanges { target: informationScreen; visible: false}
                PropertyChanges { target: drawingarea; visible: false}
                StateChangeScript{
                    script: {
                        blockingSpeech.text = "Please enter information about yourself."
                    }
                }
            },
            State {
                    name: "midtest"
            },
            State {
                    name: "posttest"
            },
            State {
                    name: "game"
                    PropertyChanges { target: informationScreen; visible: false}
            },
            State {
                    name: "endRound"
                    StateChangeScript{
                        script: {
                            if(robot_hand.visible){
                                releasetimer.interval = 500
                                releasetimer.start()
                            }
                        }
                    }
            },
            State {
                    name: "intro"
                    StateChangeScript{
                        script: {
                            informationScreen.visible = true
                            informationScreen.text = "Today we will practice and learn about food chains, discovering what animals eat."
                            buttonStart.show()
                        }
                    }
            },
            State {
                    name: "prepareGame"
                    PropertyChanges { target: informationScreen; visible: true}
                    PropertyChanges { target: instructionScreen; visible: false}
                    PropertyChanges { target: informationScreen; text: "You have to keep all the animals alive as long as possible! \n\n Now feed them!"}
                    StateChangeScript{
                        script: buttonStart.show()
                    }
            },
            State {
                    name: "tutorialIntro"
                    PropertyChanges { target: informationScreen; visible: true}
                    PropertyChanges { target: informationScreen; text: "Let's practise the game now."}
                    PropertyChanges { target: buttonStart; text: "Start"}
                    StateChangeScript{
                        script: buttonStart.show()
                    }
            },
            State {
                    name: "tutorial"
                    PropertyChanges { target: informationScreen; visible: false}
            },
            State {
                    name: "endGame"
                    StateChangeScript{
                        script: buttonStart.show()
                    }
            },
            State {
                    name: "end"
                    PropertyChanges { target: informationScreen; visible: "true"}
                    PropertyChanges { target: informationScreen; text: "Thank you for playing the game!"}
                    PropertyChanges { target: buttonStart; visible: "false"}
                    StateChangeScript{
                        script: interactionEventsPub.text = "stoprecord"
                    }
            }

        ]
        onStateChanged: {
            switch (globalStates.state){
                case "pretest":
                    informationScreen.visible = true
                    informationScreen.text = "Animals will appear, could you tell me what their food is."
                    buttonStart.show()
                    break
                case "midtest":
                    console.log("in")
                    informationScreen.text = "Let's connect the animals to their food again."
                    buttonStart.show()
                    console.log(informationScreen.text)
                    break
                case "posttest":
                    informationScreen.text = "Let's connect the animals to their food one last time."
                    buttonStart.show()
                    break
                case "endGame":
                    buttonStart.text = "Continue"
                    break
                case "endRound":
                    if(rounds == maxRounds/2)
                        buttonStart.text = "Continue"
                    else
                        buttonStart.text = "Try again"
                    break
                case "endGame":
                    buttonStart.text = "Continue"
                    break
            }
        }
    }

    Item {
        id: sandbox
        anchors.fill:parent
        visible: true

        //property double physicalMapWidth: 553 //mm (desktop acer monitor)
        property double physicalMapWidth: 600 //mm (sandtray)
        property double physicalCubeSize: 30 //mm
        //property double pixel2meter: (physicalMapWidth / 1000) / drawingarea.paintedWidth
        property double pixel2meter: (physicalMapWidth / 1000) / parent.width
        property int livingAnimals: 0 //eagle.alife + wolf.alife + mouse.alife + snake.alife + bird.alife + frog.alife + dragonfly.alife + fly.alife + butterfly.alife + grasshopper.alife
        property double totalLife: eagle.life + wolf.life + mouse.life + snake.life + bird.life + frog.life + dragonfly.life + fly.life + butterfly.life + grasshopper.life
        property double points: 0
        property var startingTime: 0

        onLivingAnimalsChanged: {
            if(livingAnimals == animalLimit && globalStates.state == "game"){
                endRound()
            }
        }
        DrawingArea {
            id: drawingarea
            height: parent.height
            width: parent.width
            anchors.left: parent.left
            anchors.top: parent.top
            visible: true

            pixelscale: sandbox.pixel2meter

            Item {
                // this item sticks to the 'visual' origin of the map, taking into account
                // possible margins appearing when resizing
                id: mapOrigin
                property string name: "sandtray"
                rotation: parent.rotation
                x: parent.x // + (parent.width - parent.paintedWidth)/2
                y: parent.y //+ (parent.height - parent.paintedHeight)/2
            }

            RosSignal {
                id: backgrounddrawing
                topic: "sandtray/signals/background_drawing"
            }
            onDrawEnabledChanged: backgrounddrawing.signal()
        }

        Item {
            id: interactiveitems
            anchors.fill: parent
            visible: true
            z:5

            property var collisionCategories: Box.Category2
            property bool showRobotChild: false
            property bool publishRobotChild: false

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                }
            }

            MouseJoint {
                id: externalJoint
                bodyA: anchor
                dampingRatio: 1
                maxForce: 1
            }

            MultiPointTouchArea {
                id: touchArea
                anchors.fill: parent

                touchPoints: [
                    TouchJoint {id:touch1;name:"touch1"},
                    TouchJoint {id:touch2;name:"touch2"},
                    TouchJoint {id:touch3;name:"touch3"},
                    TouchJoint {id:touch4;name:"touch4"},
                    TouchJoint {id:touch5;name:"touch5"},
                    TouchJoint {id:touch6;name:"touch6"}
                ]
            }

            TFListener {
                id: robotLocation
                frame: "torso"
                origin: mapOrigin
                parentframe: mapOrigin.name
                pixelscale: sandbox.pixel2meter
            }

            RosPoseSubscriber {
                id: rostouch
                x: 0
                y: 0
                topic: "poses"

                Image {
                    id:robot_hand
                    source: "res/nao_hand.svg"
                    y: - 10
                    x: - 30
                    width: 120
                    fillMode: Image.PreserveAspectFit
                    // tracks the position of the robot
                    transform: Rotation {origin.x: 15;origin.y: 5;angle: 180/Math.PI * (-Math.PI/2 + Math.atan2(robotLocation.y - rostouch.y, robotLocation.x - rostouch.x))}
                    visible: false
                }

                z:100
                property var target: null
                property string draggedObject: ""
                origin: mapOrigin
                pixelscale: sandbox.pixel2meter

                onPositionChanged: {
                    if(!interactiveitems.visible){
                        releasetimer.restart()
                        return;
                    }

                    robot_hand.visible=true;
                    if (target === null) {
                        var obj = interactiveitems.childAt(x, y);
                        if (obj.objectName === "interactive") {
                            draggedObject = obj.name;
                            //console.log("ROS controller touched object: " + obj.name);
                            interactionEventsPub.text = "robottouch_" + draggedObject;

                            target = obj.body
                            externalJoint.maxForce = target.getMass() * 500;
                            externalJoint.target = Qt.point(x,y);
                            externalJoint.bodyB = target;
                        }
                    }
                    if (target != null) {
                        externalJoint.target = Qt.point(x, y);
                        releasetimer.restart();
                    }
                }

                Timer {
                    id: releasetimer
                    interval: 2000
                    running: false
                    onTriggered: {
                        //console.log("Auto-releasing ROS contact with " + parent.draggedObject);
                        interactionEventsPub.text = "robotrelease_" + parent.draggedObject;
                        /*var items = interactiveitems.getActiveItems()
                        for(var i = 0;i<items.length;i++){
                            if(items[i].name === parent.draggedObject){
                                items[i].testCloseImages()
                            }
                        }*/
                        parent.draggedObject = "";
                        parent.target = null;
                        externalJoint.bodyB = null;
                        robot_hand.visible=false;
                        interval = 2000
                    }
                }
            }

            World {
                id: physicsWorld
                gravity: Qt.point(0.0, 0.0);

            }

            RectangleBoxBody {
                id: rightwall
                color: "#000000FF"
                width: 20
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                    top: parent.top
                }
                world: physicsWorld
                friction: 1
                density: 1
                categories: Box.Category2
            }
            RectangleBoxBody {
                id: leftwall
                color: "#000000FF"
                width: 20
                anchors {
                    left: parent.left
                    bottom: parent.bottom
                    top: parent.top
                }
                world: physicsWorld
                friction: 1
                density: 1
                categories: Box.Category2
            }
            RectangleBoxBody {
                id: top
                color: "#000000FF"
                height: 20
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
                world: physicsWorld
                friction: 1
                density: 1
                categories: Box.Category2
            }
            RectangleBoxBody {
                id: ground
                color: "#000000FF"
                height: 20
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                world: physicsWorld
                friction: 1
                density: 1
                categories: Box.Category2
            }

            Body {
                id: anchor
                world: physicsWorld
            }

            StaticImage{
                id: flower1
                name: "flower-1"
            }
            StaticImage{
                id: flower2
                name: "flower-2"
            }
            StaticImage{
                id: flower3
                name: "flower-3"
            }
            StaticImage{
                id: apple1
                name: "apple-1"
            }
            StaticImage{
                id: apple2
                name: "apple-2"
            }
            StaticImage{
                id: apple3
                name: "apple-3"
            }
            StaticImage{
                id: apple4
                name: "apple-4"
            }
            StaticImage{
                id: wheat1
                name: "wheat-1"
                scale:1.5
            }
            StaticImage{
                id: wheat2
                name: "wheat-2"
                scale:1.5
            }
            StaticImage{
                id: wheat3
                name: "wheat-3"
                scale:1.5
            }
            StaticImage{
                id: wheat4
                name: "wheat-4"
                scale:1.5
            }

            Character {
                id: grasshopper
                name: "grasshopper"
                food: "wheat"
                initialScale:.8
                collidesWith: interactiveitems.collisionCategories
            }
            Character {
                id: butterfly
                name: "butterfly"
                food: ["flower"]
                initialScale:.8
                collidesWith: interactiveitems.collisionCategories
            }
            Character {
                id: fly
                name: "fly"
                food: "apple"
                initialScale: 0.5
                collidesWith: interactiveitems.collisionCategories
            }
            Character {
                id: bird
                name: "bird"
                food: ["dragonfly","wheat","fly","grasshopper","apple"]
                initialScale:.9
                predatorLevel: 1
                collidesWith: interactiveitems.collisionCategories
            }
            Character {
                id: dragonfly
                name: "dragonfly"
                food: ["butterfly","fly"]
                initialScale:.8
                collidesWith: interactiveitems.collisionCategories
            }
            Character {
                id: frog
                name: "frog"
                predatorLevel: 1
                food: ["grasshopper","butterfly","dragonfly","fly"]
                collidesWith: interactiveitems.collisionCategories
            }
            Character {
                id: eagle
                name: "eagle"
                food: ["snake","mouse","frog","bird"]
                initialScale:1.5
                predatorLevel: 5
                collidesWith: interactiveitems.collisionCategories
            }
            Character {
                id: mouse
                name: "mouse"
                food: ["wheat", "apple"]
                predatorLevel: 1
                collidesWith: interactiveitems.collisionCategories
            }
            Character {
                id: wolf
                name: "wolf"
                food: ["mouse","bird"]
                initialScale:1.5
                predatorLevel: 3
                collidesWith: interactiveitems.collisionCategories
            }
            Character {
                id: snake
                name: "snake"
                food: ["mouse","frog","bird"]
                initialScale:1.5
                predatorLevel: 3
                collidesWith: interactiveitems.collisionCategories
            }

            FootprintsPublisher {
                id:footprints
                pixelscale: sandbox.pixel2meter

                // wait a bit before publishing the footprints to leave Box2D the time to settle
                Timer {
                    interval: 1000; running: true; repeat: false
                    onTriggered: parent.targets=interactiveitems.getAllItems()
                }
            }

            function getActiveItems() {
                return [eagle, wolf, mouse, snake,bird,frog,dragonfly,fly,butterfly,grasshopper]
            }
            function getStaticItems() {
                return [flower1, flower2, flower3, apple1, apple2, apple3, apple4, wheat1, wheat2, wheat3, wheat4]
            }
            function getAllItems() {
                return [eagle, wolf, mouse, snake,bird,frog,dragonfly,fly,butterfly,grasshopper,flower1, flower2, flower3, apple1, apple2, apple3, apple4, wheat1, wheat2, wheat3, wheat4]
            }

            function hideItems(items) {
                for (var i = 0; i < items.length; i++) {
                    items[i].visible = false;
                    items[i].x = -100
                    items[i].y = -100
                }
            }

            function shuffleItems() {
                var items = getActiveItems();
                for(var i = 0; i < items.length; i++) {
                    var item = items[i]
                    item.x = interactiveitems.x + interactiveitems.width * 0.1 + Math.random() * 0.8 * interactiveitems.width;
                    item.y = interactiveitems.y + interactiveitems.height * 0.1 + Math.random() * 0.8 * interactiveitems.height;
                    //item.rotation = Math.random() * 360;
                 }
            }

            function itemsToRandom(items) {
                for(var i = 0; i < items.length; i++) {
                    items[i].relocate()
               }
            }

            function itemsToRandomByName(items) {
                var currentType = ""
                var initialItem
                for(var i = 0; i < items.length; i++) {
                    if(items[i].type !== currentType){
                        currentType = items[i].type
                        items[i].relocate()
                        initialItem = items[i]
                    }
                    else{
                        items[i].locateCloseTo(initialItem)
                        initialItem = items[i]
                    }
               }

            }

            function initiate(items) {
                for(var i = 0; i < items.length; i++)
                    items[i].initiate()
             }

            function prepareGame(){
                var items = getActiveItems()
                for(var i = 0; i < items.length; i++)
                    items[i].initiate()
                items = getStaticItems()
                for(var i = 0; i < items.length; i++)
                    items[i].initiate()
                itemsToRandomByName(items);
                sandbox.livingAnimals = 10
            }
        }

        Item {
            id: instructionScreen
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: parent.height/10
            width: 2 * parent.width / 3
            height: parent.height / 3
            visible: false
            property string text: ""
            z: 4

            Rectangle {
                anchors.fill: parent
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
        Button {
            id: endTutoButton
            z:5
            width: instructionScreen.width/3
            height: instructionScreen.height/6
            anchors.horizontalCenter: instructionScreen.horizontalCenter
            anchors.verticalCenter: instructionScreen.verticalCenter
            anchors.verticalCenterOffset: instructionScreen.height/3
            visible: false
            text: "Continue to the game"
            style: ButtonStyle {
                label: Text {
                    font.family: "Helvetica"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: 30
                    text: endTutoButton.text
                }
            }
            function show(){
                timerShowEndTutoButton.restart()
            }

            Timer{
                id: timerShowEndTutoButton
                interval: 3000
                repeat: false
                onTriggered: endTutoButton.visible = true
            }

            onClicked: {
                if(tutoStates.state === "endTuto")
                    tutorial.finishTuto()
            }
        }

        RosPoseSubscriber {
            id: gazeFocus
            x: window.width/2
            y: window.height/2
            z:100

            visible: false

            topic: "/gazepose_0"
            origin: mapOrigin
            pixelscale: sandbox.pixel2meter

            Rectangle {
                anchors.centerIn: parent
                width: 10
                height: width
                radius: width/2
                color: "red"
            }
            Rectangle {
                anchors.centerIn: parent
                width: parent.zvalue * 2 / sandbox.pixel2meter
                height: width
                radius: width/2
                color: "transparent"
                border.color: "orange"
            }
        }
        RosPosePublisher {
            id: gazeSimulator
            topic: "/gazepose_0"
            target: gazeSimulator
            visible: false
            origin: sandbox
            frame: "sandtray"
            pixelscale: sandbox.pixel2meter
            x: sandbox.width/2
            y: sandbox.height/2
            z:101
            Rectangle {
                anchors.centerIn: parent
                width:40
                height: width
                radius: width/2

                MouseArea {
                    id: dragArea
                    anchors.fill: parent
                    drag.target: gazeSimulator
                }
            }
            onXChanged: if(visible) publish()
        }
        Timer {
            id: initTimer
            interval: 1000; running: true; repeat: false
            onTriggered: {
                initSandtray()
            }
        }
    }

    RosStringPublisher {
        id: interactionEventsPub
        topic: "sandtray/interaction_events"
    }
    RosStringSubscriber {
        id: interactionEventsSub
        topic: "sandtray/interaction_events"
        onTextChanged: {
            if(text === "supervisor_ready" || text === "analyser_ready")
                initSandtray();
        }
    }

    function startFoodChain() {
        instructionScreen.visible = false
        interactiveitems.prepareGame()

        var d = new Date()
        sandbox.startingTime = d.getTime()
        inGame = true
        sandbox.points = 0
        hunger.start()
        interactionEventsPub.text = "start_"+rounds+"_"+maxRounds

        globalStates.state = "game"
        instructionScreen.visible = false
    }

    Item {
        id: informationScreen
        anchors.fill: parent
        visible: true
        property string text: "Welcome to the food chain game. \n We will start with some questions."
        z: 10
        onTextChanged: {
            if (visible)
                blockingSpeech.text = text
        }

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
                id: informationText
                width: parent.width*.9
                font.pixelSize: 50
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
                text: informationScreen.text
                wrapMode: Text.WordWrap
            }
            Button {
                id: buttonStart
                width: parent.width/5
                height: parent.height/8
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: parent.height/3
                text: "Start"
                visible: true
                style: ButtonStyle {
                    label: Text {
                        font.family: "Helvetica"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 30
                        text: buttonStart.text
                    }
                }
                function show(){
                    timerShow.restart()
                }
                Timer{
                    id: timerShow
                    interval: 3000
                    repeat: false
                    onTriggered: buttonStart.visible=true
                }

                onClicked: {
                    visible = false
                    //if(globalStates.state == "")
                    //    tutorial.practice()
                    //else
                    switch (globalStates.state){
                    case "intro":
                        globalStates.state = "pretest"
                        break
                    case "pretest":
                        informationScreen.visible = false
                        graph.start()
                        graph.nextState = "tutorialIntro"
                        break
                    case "midtest":
                        informationScreen.visible = false
                        graph.start()
                        graph.nextState = "prepareGame"
                        break
                    case "posttest":
                        informationScreen.visible = false
                        graph.start()
                        graph.nextState = "end"
                        break
                    case "endGame":
                        globalStates.state = "posttest"
                        break
                    case "tutorialIntro":
                        tutoStates.state = "intro"
                        break
                    case "endRound":
                        if(rounds==maxRounds/2){
                            globalStates.state = "midtest"
                            buttonStart.text = "Continue"
                        }
                        else{
                            if(rounds == maxRounds){
                                console.log("end game")
                                globalStates.state = "endGame"
                                interactionEventsPub.text = "endGame"
                                informationScreen.visible = true
                                informationScreen.text = "This is the end of the game. \nYou achieved a total " + Math.round(totalPoints) +" points. \nIt's impressive!"
                            }
                            else{
                                blockingSpeech.text = "Let's try again!"
                                startFoodChain()
                            }
                        }
                        break
                    case "end":
                        finish()
                        break
                    case "":
                        start()
                        break
                    default:startFoodChain()
                    }

                    //else{
                    //    globalStates.state = "demoQuestion"  //Change if needed to ask questions
                    //}
                }

            }
        }
    }

    Graph {
        id: graph
        visible: false
    }

    ColumnLayout {
            id: questions
            y: 191
            spacing: 80
            width: 900
            height: 300
            anchors.verticalCenter: parent.verticalCenter
            visible: false
            anchors.horizontalCenter: parent.horizontalCenter

            Column {
                    id: genderquestion
                    width: 900
                    visible: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 50

                    function gender() {
                        if (isFemale.checked) return "female";
                        if (isMale.checked) return "male";
                        return "notspecified";
                    }

                    function reset(){
                            isFemale.checked = false;
                            isMale.checked = false;
                    }

                    Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            color: "#ffffff"
                            text: "I am a"
                            font.pixelSize: 50
                    }

                    Row {
                            id: row1
                            width: childrenRect.width
                            height: childrenRect.height
                            spacing: 50
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.leftMargin: 50
                            ExclusiveGroup { id: tabPositionGroup }
                            Text {
                                    color: "#b4b4b4"
                                    text: "Girl"
                                    font.pixelSize: 40
                            }

                            RadioButton {
                                    id: isFemale
                                    exclusiveGroup: tabPositionGroup
                                    style: RadioButtonStyle {
                                            indicator: Rectangle {
                                                    width: 60
                                                    height: width
                                                    radius: width/2
                                                    color: "#fff"
                                                    Rectangle {
                                                            anchors.fill:parent
                                                            visible: control.checked
                                                            color: "#555"
                                                            width:parent.width - 8
                                                            radius:width/2
                                                            height:width
                                                            anchors.margins: 4
                                                    }
                                            }
                                    }
                            }
                            Text {
                                    color: "#b4b4b4"
                                    text: "Boy"
                                    font.pixelSize: 40
                            }

                            RadioButton {
                                    id: isMale
                                    exclusiveGroup: tabPositionGroup
                                    style: isFemale.style
                            }
                    }
            }

            Column {
                    id: agequestion
                    width: 900
                    visible: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 12

                    property int age: age.value

                    function reset(){
                            age.value = 5;
                    }

                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                            id: agelabel
                            color: "#ffffff"
                            text: "My age"
                            font.pixelSize: 50
                    }
                    Row {
                            spacing:40
                            Slider {
                                    id: age
                                    width: 1000
                                    tickmarksEnabled: false
                                    minimumValue: 6
                                    value: 8
                                    stepSize: 1
                                    maximumValue: 10
                                    style: SliderStyle {
                                            handle: Rectangle {
                                                    width: 60
                                                    height: width
                                                    radius: width/2
                                                    color: "#fff"
                                            }
                                            groove: Rectangle {
                                                    color: "#777"
                                                    width: parent.width
                                                    height:10
                                                    radius: height/2
                                            }
                                    }

                            }

                            Text {
                                    text: age.value
                                    color: "#aaa"
                                    font.pixelSize: 40
                            }
                    }

            }
            Button {
                    id: nextquestionsButton
                    opacity:1.0
                    text: qsTr("Continue")
                    anchors.horizontalCenter: parent.horizontalCenter
                    style: ButtonStyle {
                            label: Text {
                                    renderType: Text.NativeRendering
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pointSize: 30
                                    text: nextquestionsButton.text
                            }
                    }
                    onClicked:{
                        var log=["demo",genderquestion.gender(),age.value]
                        fileio.write(window.qlogfilename, log.join(","));
                        globalStates.state = "intro"
                    }
            }
    }

    Rectangle {
        id: fiducialmarker
        color:"white"
        opacity:0.8
        visible: false
        anchors.fill:parent
        z:10

        Image {
            // set the actual size of the SVG page
            width: 0.60 / sandbox.pixel2meter
            height: 0.33 / sandbox.pixel2meter
            // make sure the image is in the corner ie, the sandtray origin
            x: 0
            y: 0
            fillMode: Image.PreserveAspectCrop
            source: "res/tags/markers.svg"

        }

        RosSignal {
            id: localising
            topic: "sandtray/signals/robot_localising"
            onTriggered: {
                    fiducialmarker.visible=true;
                    hide_fiducial_markers.start();
            }
        }

        Timer {
            id: hide_fiducial_markers
            interval: 5000; running: false; repeat: false
            onTriggered: {
                fiducialmarker.visible = false;
            }
        }
    }

    MouseArea {
        width:30
        height:width
        z: 100
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        property int clicks: 0
        onClicked: {
            clicks += 1;
            if (clicks === 3) {
                localising.signal();
                fiducialmarker.visible = true;
                clicks = 0;
                //endRound()
            }
        }
    }

    MouseArea {
        width:30
        height:width
        z: 100
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        property int clicks: 0
        onClicked: {
            clicks += 1;
            if (clicks === 3) {
                //debugToolbar.visible=true;
                globalStates.state = "question1"
                clicks = 0;
                //timerHideDebug.start();
            }
        }

        Timer {
            id: timerHideDebug
            interval: 5000; running: false; repeat: false
            onTriggered: {
                debugToolbar.visible = false;
            }

        }
    }

    Timer {
        id: hunger
        interval: 1000; running: false; repeat: true
        onTriggered: {
            var items = interactiveitems.getActiveItems()
            for(var i = 0; i < items.length; i++){
                if(items[i].life>0)
                    items[i].life -= hungerRate
            }
            publishLife()
            sandbox.points += sandbox.totalLife
        }
    }

    RosListFloatPublisher{
        id: lifePub
        topic: "sparc/life"
    }

    function publishLife(){
        var items = interactiveitems.getStaticItems()
        var list=[]
        for(var i = 0; i < items.length; i++){
            list.push(items[i].life/items[i].initialLife)
        }
        items = interactiveitems.getActiveItems()
        for(var i = 0; i < items.length; i++){
            list.push(items[i].life/items[i].initialLife)
        }
        lifePub.list = list
        lifePub.publish()
    }

    function initSandtray(){
        //drawingarea.publish()
        var message = "characters"
        var items = interactiveitems.getActiveItems()
        for(var i = 0; i < items.length; i++)
            message += "_"+items[i].name + "," + items[i].initialScale
        interactionEventsPub.text = message
        sleep(100)

        message = "targets"
        items = interactiveitems.getStaticItems()
        for(var i = 0; i < items.length; i++)
            message += "_"+items[i].name + "," + items[i].initialScale
        interactionEventsPub.text = message
        sleep(100)

        publishLife()

        sleep(100)
        if(globalStates.state === "game")
            interactionEventsPub.text = "running_"+rounds+"_"+maxRounds
    }

    function sleep(milliseconds) {
      var start = new Date().getTime();
      for (var i = 0; i < 1e7; i++) {
        if ((new Date().getTime() - start) > milliseconds){
          break;
        }
      }
    }

    function endRound(){
        inGame = false
        hunger.running = false
        rounds++

        var finished = false
        var items = interactiveitems.getActiveItems()
        var lifes=[]
        for(var i = 0; i < items.length; i++)
            lifes[i]=items[i].life

        while(!finished){
            finished = true
            for(var i = 0; i < lifes.length; i++){
                if(lifes[i]>0){
                    lifes[i] -= hungerRate
                    finished = false
                    sandbox.points += lifes[i]
                }
            }
        }
        totalPoints += sandbox.points

        globalStates.state = "endRound"
        interactionEventsPub.text = "endround"
        informationScreen.visible = true
        informationScreen.text="Three animals ran out of energy, so the game stops."
        buttonStart.text="Continue"
        interactiveitems.hideItems(interactiveitems.getStaticItems())
        interactiveitems.hideItems(interactiveitems.getActiveItems())
        var d = new Date()
        var n = d.getTime() - sandbox.startingTime
        var log=["Round"+rounds,n,sandbox.points]
        fileio.write(window.qlogfilename, log.join(","));
        timerScore.start()
    }

    Timer{
        id: timerScore
        interval: 5000
        onTriggered: {
            var congratulation=["Excellent", "Good job", "Well played", "Bravo"]
            informationScreen.text="You finished with " + Math.round(sandbox.points) +" points. \n "+congratulation[rounds%4]+"!"
            if(rounds == maxRounds || maxRounds == 2*rounds)
                buttonStart.text="Continue"
            else
                buttonStart.text="Try again"
            buttonStart.show()
        }
    }

    Item{
        id: tutorial
        property bool flyFed: false
        property bool deadFrog: false
        property bool introduced: false
        property string sentence: ""

        StateGroup {
            id: tutoStates
            states: [
                State {
                    name: "default"
                },
                State {
                    name: "intro"
                },
                State {
                    name: "goal"
                },
                State {
                    name: "feedFly"
                    PropertyChanges {target: repeatInstructions; sentence: "Touch the fly and drag it to the apple."}
                },
                State {
                    name: "feedFrog"
                    PropertyChanges {target: repeatInstructions; sentence: "Touch the frog and drag it to the fly."}
                },
                State {
                    name: "deadAnimal"
                },
                State {
                    name: "endTuto"
                },
                State {
                    name: "done"
                }

            ]
            onStateChanged: {
                console.log("Current state "+tutoStates.state)
                repeatInstructions.running = false
                switch (tutoStates.state){
                    case "intro":
                        tutorial.setupTutorial()
                        tutorial.sentence = "Welcome to the game. The goal is to keep all the animals alive as long as possible."
                        tutorial.introduced = true
                        break
                    case "goal":
                        hunger.running = true
                        tutorial.sentence = "Animals have energy which decreases as time goes by, and they have to eat to stay alive."
                        break
                    case "feedFly":
                        hunger.running = true
                        tutorial.sentence = "Now, feed the fly by moving it to the apple."
                        fly.movable = true
                        break
                    case "feedFrog":
                        hunger.running = true
                        tutorial.flyFed = true
                        if(tutorial.deadFrog == false){
                            tutorial.sentence = "Well done! Now move the frog to the fly to feed the frog."
                        }
                        else{
                            tutorial.sentence = "Now move the frog to the fly to feed the frog."
                        }
                        frog.movable = true
                        fly.movable = true
                        break
                    case "deadAnimal":
                        tutorial.sentence = "One animal ran out of energy, let's try again."
                        hunger.running = false
                        break
                    case "endTuto":
                        tutorial.sentence = "Excellent! But be careful, when an animal has no energy, it disappears. Let's start the game when you are ready."
                        endTutoButton.show()
                        break
                }
            }
        }

        onSentenceChanged: {
            if(sentence != ""){
                instructionScreen.text = sentence
                blockingSpeech.text = sentence
                defaultSay.restart()
            }
        }
        Timer {
            id: defaultSay
            interval: 6000
            running: false
            repeat: false
            onTriggered: {
                tutorial.sentenceIn(tutorial.sentence)
            }
        }

        Timer {
            id: repeatInstructions
            interval: 6000
            running: false
            repeat: true
            property string sentence: ""
            onTriggered: {
                instructionScreen.text = sentence
                blockingSpeech.text = sentence
            }
        }

        function setupTutorial (){
            informationScreen.visible = false
            instructionScreen.visible = true
            interactiveitems.initiate([frog,fly])
            frog.x = sandbox.width/4
            frog.y = sandbox.height/2
            fly.x = 2 * sandbox.width/4
            fly.y = sandbox.height/2
            frog.movable = false
            fly.visible = true
            fly.movable = false
            apple1.visible = true
            apple1.x = 3*sandbox.width/4
            apple1.y = sandbox.height/2
        }

        function sentenceIn(str) {
            if(str === tutorial.sentence){
                defaultSay.stop()
                switch (tutoStates.state){
                    case "intro":
                        tutoStates.state = "goal"
                        break
                    case "goal":
                        tutoStates.state = "feedFly"
                        break
                    case "feedFly":
                        repeatInstructions.restart()
                        break
                    case "feedFrog":
                        repeatInstructions.restart()
                        break
                    //case "endTuto":
                    //    interactiveitems.hideItems(interactiveitems.getStaticItems())
                    //    interactiveitems.hideItems(interactiveitems.getActiveItems())
                    //    globalStates.state = "prepareGame"
                    //    break
                    case "deadAnimal":
                        setupTutorial()
                        if(tutorial.flyFed)
                            tutoStates.state = "feedFrog"
                        else
                            tutoStates.state = "feedFly"
                        break
                }
            }
        }
        function finishTuto(){
            interactiveitems.hideItems(interactiveitems.getStaticItems())
            interactiveitems.hideItems(interactiveitems.getActiveItems())
            hunger.running = false
            globalStates.state = "prepareGame"
            tutoStates.state = "done"
            endTutoButton.visible = false
        }
    }

    function animalDying(name){
        if(tutoStates.state !== "" && tutoStates.state !== "endTuto" && tutoStates.state !== "done" && tutoStates.state !== "deadAnimal" &&  (name === "frog" || name === "fly")){
            tutoStates.state = "deadAnimal"
            if(tutorial.flyFed && name === "frog")
                tutorial.deadFrog = true
        }
        if(tutoStates.state === "endTuto"){
            tutorial.sentence = "For the tutorial, animals revive, but not for the real game, be careful."
            tutorial.setupTutorial()
            frog.movable = true
            fly.movable = true
        }
        if(globalStates.state === "game")
            interactionEventsPub.text = "animaldead_"+name
    }

    function targetDying(name){
        if(globalStates.state === "game")
            interactionEventsPub.text = "targetdead_"+name
    }

    function animalEating(name){
        if(tutoStates.state === "feedFly" && name === "fly")
            tutoStates.state = "feedFrog"
        if(tutoStates.state === "feedFrog" && name === "frog")
            tutoStates.state = "endTuto"
        if(globalStates.state === "game")
            interactionEventsPub.text = "animaleats_"+name
    }

    function failInteraction(name){
        if(globalStates.state === "game")
            interactionEventsPub.text = "failinteraction_"+name
    }

    RosStringPublisher {
        id: blockingSpeech
        topic: "nao/blocking_speech"
    }

    RosStringSubscriber {
        id: naoEventsSub
        signal speechFinished()
        topic: "nao/events"
        onTextChanged: {
            if(text.split("-")[0] === "blocking_speech_finished"){
                tutorial.sentenceIn(text.split("-")[1])
            }
        }
    }

    function start(){
        interactionEventsPub.text = "record"
        initTimer.start()
        var d = new Date()
        qlogfilename = "foodchain-data/logs/" + d.toISOString().split(".")[0] + ".csv"

        //globalStates.state = "pretest"
        //tutoStates.state = "intro"
        //globalStates.state = "demoQuestion"
        startFoodChain()
    }
}
