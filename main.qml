import QtQuick 2.15
import QtQuick.Controls 2.15
import QtWebEngine 1.10

ApplicationWindow
{
    visible: true
    width:  630
    height:  350
    title: "YouTube Player"

    Connections
    {
        target: youtubeFetcher
        function onPlayListDataFetched()
        {
            playlistModel.clear()

            for (var i = 0; i < youtubeFetcher.videoList.length; i++)
            {
                var item = youtubeFetcher.videoList[i];
                playlistModel.append({ title: item.title, videoId: item.videoId, thumbnail: item.thumbnail});
            }
            webView.url =  "https://www.youtube.com/watch?v=" + youtubeFetcher.videoList[0].videoId
            videoThumbnail.source = youtubeFetcher.videoList[0].thumbnail
        }
    }

    property int currentIndex: 0

    Drawer
    {
        id: playlistDrawer
        width: parent.width/2
        height: parent.height
        edge: Qt.LeftEdge

        Rectangle{
            id: closeDrawer
            anchors.top: parent.top
            anchors.left: parent.left
            width: parent.width
            height: closeDrawerButton.height
            z: 1

            Button
            {
                id: closeDrawerButton
                anchors.top: parent.top
                anchors.left: parent.left
                text: "Close Drawer"
                onClicked: playlistDrawer.close()
            }
        }

        ListView
        {
            id: playlistView
            anchors.top: closeDrawer.bottom
            anchors.bottom: parent.bottom
            width: parent.width
            anchors.topMargin: 10
            spacing: 10

            model: ListModel
            {
                id: playlistModel
            }


            delegate: Item
            {
                width: playlistView.width
                height: listButton.height


                Button
                {
                    id: listButton
                    width: parent.width
                    font.pixelSize: 16
                    contentItem: Text
                    {
                        id: textItem
                        width: parent.width
                        text: model.title
                        color: model.index === currentIndex ? "red" : "black"
                        elide: Text.ElideRight
                    }
                    onClicked:

                    {
                        currentIndex = index
                        webView.setVideoUrl(model.videoId)
                        videoThumbnail.source = model.thumbnail

                    }
                }
            }
        }
    }

    WebEngineView
    {
        id: webView
        visible: false
        // anchors.top: parent.top
        // anchors.topMargin: -80 //56(navbar) + 24(padding)
        // anchors.leftMargin: -40
        // anchors.rightMargin: -45
        // anchors.left: parent.left
        // anchors.right: parent.right
        // anchors.bottom: parent.bottom
        height: 0
        width: 0

        function setVideoUrl(videoId)
        {
            webView.url = "https://www.youtube.com/watch?v=" + videoId /*+ "?autoplay=1&playsinline=1"*/
        }

        settings
        {
            autoLoadIconsForPage: false
            autoLoadImages: false
            javascriptCanOpenWindows: false
            localContentCanAccessFileUrls: false
            localStorageEnabled: false
            printElementBackgrounds: false
            showScrollBars: false
            unknownUrlSchemePolicy: WebEngineSettings.DisallowUnknownUrlSchemes
            webGLEnabled: false
            playbackRequiresUserGesture: false
        }
    }

    Image
    {
        id: videoThumbnail
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
    }

    Button
    {
        id: openDrawer
        anchors.top: parent.top
        anchors.left: parent.left
        text: "Open Drawer"
        onClicked:
        {
            playlistDrawer.open()
        }
    }

    Button
    {
        id: nextButton
        text: "Next"
        anchors.bottom: parent.bottom
        anchors.left: playPauseButton.right
        enabled: currentIndex < playlistView.model.count - 1
        onClicked:
        {
            currentIndex++
            webView.setVideoUrl(playlistModel.get(currentIndex).videoId)
            videoThumbnail.source = playlistModel.get(currentIndex).thumbnail
        }
    }

    Button
    {
        id: previousButton
        text: "Previous"
        anchors.bottom: parent.bottom
        anchors.right: playPauseButton.left
        enabled: currentIndex > 0
        onClicked:
        {
            currentIndex--
            webView.setVideoUrl(playlistModel.get(currentIndex).videoId)
            videoThumbnail.source = playlistModel.get(currentIndex).thumbnail
        }
    }

    Button
    {
        id: playPauseButton
        text: "Pause"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked:
        {
            webView.runJavaScript("var video = document.querySelector('video'); if (video.paused) { video.play(); } else { video.pause(); }", function(result)
            {
                playPauseButton.text = result ? "Pause" : "Play";
            });
        }
    }
}
