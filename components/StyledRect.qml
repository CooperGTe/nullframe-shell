import QtQuick
import qs.config

Rectangle {
    id: root
    property string style: "container"
    radius: 20
    anchors {
        fill:parent
    }
    color: root.style === "container" ? Colors.container :
        (root.style === "highcontainer" ? Colors.container_high : "white") 
}
