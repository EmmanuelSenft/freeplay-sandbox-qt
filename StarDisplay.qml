import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1


Item {
    id: starDisplay
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter

    Grid{
        anchors.fill: parent
        columns: 5
        property int cellSize: (width-(columns-1)*columnSpacing)/columns
        Image{
            id: star1
            width: parent.cellSize
            height: parent.height/2
            fillMode: Image.PreserveAspectFit
            source: "res/halfstar.png"
        }
        Image{
            id: star2
            width: parent.cellSize
            height: parent.height/2
            fillMode: Image.PreserveAspectFit
            source: "res/emptystar.png"
        }
        Image{
            id: star3
            width: parent.cellSize
            height: parent.height/2
            fillMode: Image.PreserveAspectFit
            source: "res/fullstar.png"
        }
        Image{
            id: star4
            width: parent.cellSize
            height: parent.height/2
            fillMode: Image.PreserveAspectFit
            source: "res/emptystar.png"
        }
        Image{
            id: star5
            width: parent.cellSize
            height: parent.height/2
            fillMode: Image.PreserveAspectFit
            source: "res/halfstar.png"
        }
    }

    function showStars(nStar){
        nStar = Math.ceil((nStar)*2)/2
        var stars=[star1,star2,star3,star4,star5]
        for(var i=0;i<stars.length;i++){
            if(nStar>=i+1)
                stars[i].source="/res/fullstar.png"
            else if(nStar==i+.5)
                stars[i].source="/res/halfstar.png"
            else
                stars[i].source="/res/emptystar.png"
        }
        visible = true
    }
}
