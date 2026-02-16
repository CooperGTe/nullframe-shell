import QtQuick
import qs.config

Rectangle {
    id: root
    property string style: "container"
    radius: 20
    anchors {
        fill:parent
    }
    color: root.style === "container" ? Color.container :
        (root.style === "highcontainer" ? Color.container_high : "white") 
}
