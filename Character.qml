import QtQuick 2.0
import Box2D 2.0

InteractiveItem {
    id: character


    property double scale: 1.6
    property double bbScale: 1.0
    property int number: 0
    name: ""
    property var stash: parent

    x: stash.x + 10 + Math.random() * 0.5 * stash.width
    y: stash.y + 10 + Math.random() * 0.9 * stash.height

    width: scale * 2 * parent.height * sandbox.physicalCubeSize / sandbox.physicalMapWidth
    rotation: 0

    property double bbRadius: bbScale * character.width/2
    property point bbOrigin: Qt.point(character.width/2, character.height/2)

    property alias friction: bbpoly.friction
    property alias restitution: bbpoly.restitution
    property alias density: bbpoly.density
    property alias collidesWith: bbpoly.collidesWith


    boundingbox: Polygon {
                id:bbpoly
                vertices: [
                    Qt.point(bbOrigin.x + bbRadius, bbOrigin.y),
                    Qt.point(bbOrigin.x + 0.7 * bbRadius, bbOrigin.y + 0.7 * bbRadius),
                    Qt.point(bbOrigin.x, bbOrigin.y + bbRadius),
                    Qt.point(bbOrigin.x - 0.7 * bbRadius, bbOrigin.y + 0.7 * bbRadius),
                    Qt.point(bbOrigin.x - bbRadius, bbOrigin.y),
                    Qt.point(bbOrigin.x - 0.7 * bbRadius, bbOrigin.y - 0.7 * bbRadius),
                    Qt.point(bbOrigin.x, bbOrigin.y - bbRadius),
                    Qt.point(bbOrigin.x + 0.7 * bbRadius, bbOrigin.y - 0.7 * bbRadius)
                ]
                density: 1
                friction: 1
                restitution: 0.1
            }

    onRotationChanged: {rotation = 0}
    function pressed(){
        updateDestination.stop()
    }

    function released(){
        updateDestination.start()
    }
    Timer{
        id: updateDestination
        interval: 100
        onTriggered: {
            var under=caseLists.childAt(x+width/2,y+height/2)
            if(under === null){
                console.log("nothing")
                return
            }
            if(under.number == number){
                under.image = "res/"+name+".png"
                x= map.width/2-width/2
                y= map.height/2-height/2
                if(number == -maps.targets.length){
                    maps.endMap()
                }
                else{
                    console.log("normal")
                    maps.currentId += 1
                    under.name=name
                }
            }
        }
    }
}
