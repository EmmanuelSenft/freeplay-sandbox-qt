import QtQuick 2.0

Item {
    id: item
    property string name:""
    property int arrows: 0
    property bool target: false

    Image{
        id:image
        anchors.fill: parent
        source: "/res/"+name+".png"
        fillMode: Image.PreserveAspectFit

    }
    Rectangle{
        id:background
        anchors.fill: parent
        z:-1
        radius: width/2
        opacity: .6
        color: "orangered"
    }
    onArrowsChanged: {
        if(target || arrows>0)
            background.color = "white"
        else
            background.color = "orangered"
    }
    onTargetChanged: {
        if(target)
            background.color = "white"
    }
 }
