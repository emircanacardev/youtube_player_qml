import QtQuick 2.15
import QtQuick.Controls 2.15
import QtWebEngine 1.10

ApplicationWindow
{
    visible: true
    width:  720
    height:  420
    title: "YouTube Player"

    property bool isPlaying: false



    property string mainColor: "#151515"
    property string secondColor: "#59D5E0"
    property string thirdColor: "#ffffff"
    property int currentIndex: 0
    property int counter: 0
    property bool isFirstRun: true
    property bool isSetShowVideoElements: false


    function loadingProcess()
    {
        webView.runJavaScript("document.querySelector('video').duration;", function(duration)
            {

            if (false) {
                console.log("DURATION ERROR:" + duration);
                Qt.callLater(function()
                {
                    loadingProcess()
                })
                return;
            }

            console.log("Video element found!");

                slider.updating = true
                slider.to = duration;
                timer.running = true
                isPlaying = true

                console.log(duration)
            })
    }

    function detectAd()
    {
        webView.runJavaScript("let adButtonIcon = document.querySelector('span.ytp-ad-button-icon');adButtonIcon === null;", function(result)
        {
            if (result)
            {
                console.log("Add not detect!");
                loadingProcess()
            }
            else
            {
                console.log("Add detected!");
                webView.reload()
            }
        })
    }

    function setShowVideoElements()
    {
        console.log("Video Elements Setting!")
        webView.runJavaScript
                ("
                document.querySelector('video').style.position = 'fixed'
                document.querySelector('video').style.height = '100%'
                document.querySelector('video').style.width = 'auto'
                document.querySelector('body > ytd-app').style.visibility = 'hidden'
                document.querySelector('video').style.visibility = 'visible'
                ")

        showVideo.enabled = true

        console.log("Video Elements Set!")

    }

    function setVideoUrl(videoId)
    {
        webView.url = "https://www.youtube.com/watch?v=" + videoId
        showVideo.checked = false
        showVideo.enabled = false
        isSetShowVideoElements = false


    }

    function nextVideo()
    {
        currentIndex++

        Qt.callLater(function()
        {
            setVideoUrl(playlistModel.get(currentIndex).videoId)
        })
        videoThumbnail.source = playlistModel.get(currentIndex).thumbnail
    }

    function previousVideo()
    {
        currentIndex--
        Qt.callLater(function()
        {
            setVideoUrl(playlistModel.get(currentIndex).videoId)
        })
        videoThumbnail.source = playlistModel.get(currentIndex).thumbnail
    }

    function playPauseVideo()
    {
        webView.runJavaScript("var video = document.querySelector('video'); if (video.paused) { video.play(); } else { video.pause(); }", function(result)
        {
            if (result)
            {

                isPlaying = true
                timer.running = true

            }
            else
            {
                isPlaying = false
                timer.running = false
            }
        })
    }

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
            if (isFirstRun){
                setVideoUrl(youtubeFetcher.videoList[0].videoId)
                videoThumbnail.source = youtubeFetcher.videoList[0].thumbnail
            }
        }
    }

    Drawer
    {
        id: playlistDrawer
        width: parent.width/2
        height: parent.height
        edge: Qt.LeftEdge

        background: Rectangle
        {
            anchors.fill: parent
            color: secondColor
        }

        Rectangle{
            id: drawerButtonArea
            anchors.top: parent.top
            anchors.left: parent.left
            width: parent.width
            height: 45
            color: secondColor
            z:1

            Button
            {
                id: closeDrawerButton
                icon.source: "assets/drawer.svg"
                icon.color: secondColor
                anchors.top: parent.top
                anchors.margins: 5
                anchors.left: parent.left
                onClicked: playlistDrawer.close()
                background: Rectangle
                {
                    border.color: secondColor
                    radius: 10
                    color: mainColor
                }
            }

            CheckBox
            {
                id: autoRefresh
                anchors.top: parent.top
                anchors.right: refreshPlayList.left
                anchors.margins: 5
                width: 115
                height: closeDrawerButton.height
                checked: false

                background: Rectangle
                {
                    border.color: secondColor
                    radius: 10
                    color: mainColor
                }

                indicator: Rectangle
                {
                    id: autoRefreshIndicator
                    implicitWidth: 20
                    implicitHeight: 20
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 5
                    border.color: secondColor

                    Text {
                        anchors.centerIn: parent
                        text: "✔"
                        font.pixelSize: 15
                        color: secondColor
                        visible: autoRefresh.checked
                    }

                    Text {
                        text: "Auto Refresh"
                        color: secondColor
                        font.pixelSize: 13

                        anchors.left: autoRefreshIndicator.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 5

                    }
                }

                onCheckedChanged:
                {
                    if (checked)
                    {
                        console.log("Auto refreshing enabled!")
                    }
                    else
                    {
                        console.log("Auto refreshing disabled!")
                    }
                }
            }

            Button
            {
                id: refreshPlayList
                icon.source: "assets/refresh.svg"
                icon.color: secondColor
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 5

                background: Rectangle
                {
                    border.color: secondColor
                    radius: 10
                    color: mainColor
                }

                onClicked:
                {
                    console.log("Playlist refreshed!")
                    isFirstRun = false
                    youtubeFetcher.fetchPlaylistData();
                }
            }
        }



        ListView
        {
            id: playlistView
            anchors.top: drawerButtonArea.bottom
            anchors.bottom: parent.bottom
            width: parent.width
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
                    width: parent.width - 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 15

                    contentItem: Text
                    {
                        id: textItem
                        width: parent.width
                        text: model.title
                        color: model.index === currentIndex ? mainColor : secondColor
                        elide: Text.ElideRight
                    }

                    onClicked:
                    {
                        currentIndex = index
                        setVideoUrl(model.videoId)
                        videoThumbnail.source = model.thumbnail

                    }

                    background: Rectangle
                    {
                        height: 30
                        border.width: model.index === currentIndex ? 5 : 2
                        border.color: model.index === currentIndex ? mainColor : secondColor
                        radius: 10
                        color: model.index === currentIndex ? secondColor : mainColor
                    }
                }
            }
        }
    }

    WebEngineView
    {
        id: webView
        anchors.top: parent.top
        anchors.topMargin: -80 //56(navbar) + 24(padding)
        anchors.leftMargin: -24
        anchors.rightMargin: -24
        // anchors.bottomMargin: -20
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: slider.top

        onLoadProgressChanged:
        {
            console.log(loadProgress)
            if (loadProgress === 100)
            {
                detectAd()
            }
            else
            {
                slider.updating = false
                slider.value = 0
            }
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

    MouseArea
    {
        anchors.fill: parent
        onClicked: {}
        onPositionChanged: {}
    }

    Rectangle
    {
        id: videoThumbnailBackground
        anchors.fill: parent
        color: mainColor
    }

    Image
    {
        id: videoThumbnail
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: slider.top
        fillMode: Image.PreserveAspectFit
    }

    Button
    {
        id: openDrawer

        icon.source: "assets/drawer.svg"
        icon.color: secondColor
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 5


        onClicked:
        {
            playlistDrawer.open()
        }

        background: Rectangle
        {
            border.color: secondColor
            radius: 10
            color: mainColor
        }
    }

    CheckBox
    {
        id: showVideo
        anchors.top: parent.top
        anchors.margins: 5
        anchors.right: parent.right
        width: 115
        height: openDrawer.height
        checked: false

        background: Rectangle
        {
            border.color: secondColor
            radius: 10
            color: mainColor
        }

        indicator: Rectangle
        {
            id: showVideoIndicator
            implicitWidth: 20
            implicitHeight: 20
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            radius: 5
            border.color: secondColor

            Text {
                anchors.centerIn: parent
                text: "✔"
                font.pixelSize: 15
                color: secondColor
                visible: showVideo.checked
            }

            Text {
                id: showVideoText
                text: "Show Video"
                font.pixelSize: 13

                color: showVideo.enabled ? secondColor : "red"
                anchors.left: showVideoIndicator.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 5

            }
        }

        onCheckedChanged:
        {
            if (checked)
            {
                videoThumbnail.visible = false
                videoThumbnailBackground.visible = false
            }
            else
            {
                videoThumbnail.visible = true
                videoThumbnailBackground.visible = true
            }
        }
    }

    Rectangle
    {
        id: bottomBackground
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 75
        color: mainColor
    }

    Rectangle
    {
        id: bottomBackgroundLine
        anchors.bottom: bottomBackground.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 5
        color: secondColor
    }


    Button
    {
        id: playPauseButton
        icon.source: isPlaying ? "assets/pause.svg" : "assets/play.svg"
        icon.color: enabled ? secondColor : thirdColor
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 5
        enabled: webView.loadProgress >= 100

        background: Rectangle
        {
            border.color: secondColor
            radius: 10
            color: mainColor
        }

        onClicked:
        {
            playPauseVideo()
        }
    }

    Button
    {
        id: nextButton
        icon.source: "assets/next.svg"
        icon.color: enabled ? secondColor : thirdColor
        anchors.bottom: parent.bottom
        anchors.left: playPauseButton.right
        anchors.leftMargin: 5
        anchors.bottomMargin: 5

        enabled: currentIndex < playlistView.model.count - 1

        background: Rectangle
        {
            border.color: secondColor
            radius: 10
            color: mainColor
        }

        onClicked:
        {
            nextVideo()
        }
    }

    Button
    {
        id: previousButton
        icon.source: "assets/previous.svg"
        icon.color: enabled ? secondColor : thirdColor
        anchors.bottom: parent.bottom
        anchors.right: playPauseButton.left
        anchors.rightMargin: 5
        anchors.bottomMargin: 5

        enabled: currentIndex > 0

        background: Rectangle
        {
            border.color: secondColor
            radius: 10
            color: mainColor
        }

        onClicked:
        {
            previousVideo()
        }
    }

    // Slider {
    //     id: volumeSlider
    //     anchors.bottom: bottomBackgroundLine.top
    //     anchors.horizontalCenter: parent.horizontalCenter
    //     from: 0
    //     to: 100
    //     value: 50 // Başlangıçta %50 ses seviyesi
    //     onValueChanged: {
    //         webView.runJavaScript("
    //         var video = document.querySelector('video');
    //         if (video) {
    //             video.volume = 0.3; // Ses seviyesini %30 yapar
    //         }
    //     ");
    //     }
    // }

    Slider {
        id: slider
        value: 0
        from: 0
        to: 200
        width: parent.width - 100
        anchors.bottom: playPauseButton.top
        anchors.horizontalCenter: parent.horizontalCenter
        property bool updating: false

        onValueChanged:
        {
            if (slider.updating)
            {
                webView.runJavaScript("document.querySelector('video').currentTime = " + value + ";");
            }
        }


        background: Rectangle
        {
           x: slider.leftPadding
           y: slider.topPadding + slider.availableHeight / 2 - height / 2
           implicitHeight: 15
           implicitWidth: parent.width
           width: slider.availableWidth
           height: implicitHeight
           radius: 10
           color: thirdColor

           Rectangle
           {
               id: sliderLeftArea
               width: slider.visualPosition * parent.width
               height: parent.height
               color: secondColor
               radius: 25
           }
        }

        handle: Rectangle
        {
            x: sliderLeftArea.width
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            implicitWidth: 20
            implicitHeight: 20
            radius: 13
            color: slider.pressed ? secondColor : thirdColor
            border.color: secondColor
            border.width: 2
        }
    }

    Timer
    {
        id: timer
        interval: 1000 //(1000 ms = 1 s)
        repeat: true

        onTriggered:
        {
            slider.updating = false
            slider.value ++
            slider.updating = true

            if (slider.value == slider.to)
            {
                if (currentIndex < playlistView.model.count - 1)
                {
                    nextVideo()
                }
                else
                {
                    currentIndex = 0
                    Qt.callLater(function()
                    {
                        setVideoUrl(playlistModel.get(currentIndex).videoId)
                    })
                    videoThumbnail.source = playlistModel.get(currentIndex).thumbnail
                }
            }

            if (autoRefresh.checked)
            {
                counter ++

                if (counter%10 == 0)
                {
                    isFirstRun = false
                    youtubeFetcher.fetchPlaylistData()
                    console.log("Playlist Refreshed!")
                }
            }


            if (slider.value >= 3 && isSetShowVideoElements != true)
            {
                try
                {
                    setShowVideoElements()
                }
                catch (error)
                {
                    console.log("setShow Error: " + error)
                }

                isSetShowVideoElements = true
            }
        }
    }
}
