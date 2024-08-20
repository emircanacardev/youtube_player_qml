import QtQuick 2.15
import QtQuick.Controls 2.15
import QtWebEngine 1.10

ApplicationWindow {
    visible: true
    width: 630
    height: 350
    title: "YouTube Player"

    WebEngineView {
        id: webView
        visible: true
        anchors.top: parent.top
        anchors.topMargin: -80 //56(navbar) + 24(padding)
        anchors.leftMargin: -30
        anchors.rightMargin: -45
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        url: "https://www.youtube.com/watch?v=xfpOlwrvpdI?autoplay=1&playsinline=1"
        // url: "https://www.youtube.com/embed/ridWIGhsJIM?autoplay=1"

        function setVideoUrl(videoId) {
            webView.url = "https://www.youtube.com/watch?v=" + videoId + "?autoplay=1&playsinline=1"
        }

        settings {
            playbackRequiresUserGesture: false
            javascriptCanAccessClipboard: false
            autoLoadImages: false
            // allowRunningInsecureContent: false
            // javascriptCanOpenWindows: true
            // webGLEnabled: true
            // localStorageEnabled: false
            // fullScreenSupportEnabled: false
            // javascriptEnabled: true
        }
    }

    property int currentIndex: 0

    Drawer {
       id: playlistDrawer
       width: parent.width/3
       height: parent.height
       edge: Qt.LeftEdge

       Button {
           id: closeDrawer
           anchors.top: parent.top
           anchors.left: parent.left
           text: "Close Drawer"
           onClicked: playlistDrawer.close()
       }

       ListView {
           id: playlistView
           anchors.top: closeDrawer.bottom
           anchors.bottom: parent.bottom
           width: parent.width


           model: ListModel {
               id: playlistModel // Burasını API olayını çözdükten sonra güncelliycem.
               ListElement { trackIndex: 0; trackName: "Duman - Kolay Değildir"; trackUrl: "xfpOlwrvpdI"; nowPlaying: true}
               ListElement { trackIndex: 1; trackName: "Duman - İyi De Banane"; trackUrl: "7Ys30vi4cnI"; nowPlaying: false}
               ListElement { trackIndex: 2; trackName: "Duman - Sor Bana"; trackUrl: "yzRIhUjAO28"; nowPlaying: false}
               ListElement { trackIndex: 3; trackName: "Duman - Öyle Dertli"; trackUrl: "P_hLDSDv0iU"; nowPlaying: false}
               ListElement { trackIndex: 4; trackName: "Duman - Dibine Kadar"; trackUrl: "4ZPuGxdDf_4"; nowPlaying: false}
           }


           delegate: Item {
               width: parent.width
               height: 60

                Row {
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                       text: title
                       font.pixelSize: 16
                       color: nowPlaying ? "blue" :"black"
                    }
                }
            }
        }
    }


    Button {
        id: openDrawer
        anchors.top: parent.top
        anchors.left: parent.left
        text: "Open Drawer"
        onClicked: playlistDrawer.open()
    }

    Button {
        id: nextButton
        text: "Next"
        anchors.bottom: parent.bottom
        anchors.left: playPauseButton.right
        enabled: currentIndex < playlistView.model.count - 1
        onClicked: {

            playlistModel.set(currentIndex, {"nowPlaying": false})
            currentIndex++
            playlistModel.set(currentIndex, {"nowPlaying": true})
            webView.setVideoUrl(playlistModel.get(currentIndex).trackUrl)

        }
    }

    Button {
        id: previousButton
        text: "Previous"
        anchors.bottom: parent.bottom
        anchors.right: playPauseButton.left
        enabled: currentIndex > 0
        onClicked: {

            playlistModel.set(currentIndex, {"nowPlaying": false})
            currentIndex--
            playlistModel.set(currentIndex, {"nowPlaying": true})
            webView.setVideoUrl(playlistModel.get(currentIndex).trackUrl)
        }
    }

    Button {
        id: playPauseButton
        text: "Pause"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: {
            webView.runJavaScript("var video = document.querySelector('video'); if (video.paused) { video.play(); } else { video.pause(); }", function(result) {
                playPauseButton.text = result ? "Pause" : "Play";
            });
            // playPauseButton.text = webView.runJavaScript("playPause()")
        }
    }

}
