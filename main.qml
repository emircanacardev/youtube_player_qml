import QtQuick 2.15
import QtQuick.Controls 2.15
import QtWebEngine 1.10
import "scripts.js" as Scripts
ApplicationWindow {
    visible: true
    width: 560
    height: 315
    title: "YouTube Player"

    WebEngineView {
        id: webView
        visible: true
        anchors.top: search.bottom
        anchors.topMargin: -80 //56(navbar) + 24(padding)
        anchors.leftMargin: -24
        anchors.rightMargin: -24
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        url: "https://www.youtube.com/watch?v=lEwslGCDsSI?autoplay=1&playsinline=1"
        // url: "https://www.youtube.com/embed/ridWIGhsJIM?autoplay=1"

        function setVideoUrl(videoId) {
            webView.url = "https://www.youtube.com/watch?v=" + videoId + "?autoplay=1&playsinline=1"

        }
        settings {
            playbackRequiresUserGesture: false
            javascriptCanAccessClipboard: false
            autoLoadImages: false
            // allowRunningInsecureContent: false
            // javascriptCanOpenWindows: false
            // webGLEnabled: false
            // localStorageEnabled: false
            // fullScreenSupportEnabled: false
            // javascriptEnabled: false


            }

    }


    TextField {
        id: urlInput
        anchors.top: parent.top
        anchors.left: search.right
        anchors.right: parent.right
        placeholderText: "Enter YouTube Video ID"
        text: ""
    }
    Button {
        id: search
        anchors.top: parent.top
        anchors.left: parent.left
        text: "Search"
        onClicked: {
            webView.setVideoUrl(urlInput.text)
        }

    }
    Button {
        id: playPauseButton
        text: "Pause"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: {
            // webView.runJavaScript("var video = document.querySelector('video'); if (video.paused) { video.play(); } else { video.pause(); }", function(result) {
            //     playPauseButton.text = result ? "Pause" : "Play";
            // });

            playPauseButton.text = Scripts.playPause()
            // webView.runJavaScript("alert(document)");
        }
    }
}
