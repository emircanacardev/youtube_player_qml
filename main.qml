import QtQuick 2.15
import QtQuick.Controls 2.15
import QtWebEngine 1.10

ApplicationWindow
{
    visible: true
    width:  720
    height:  420
    title: "YouTube Player"

    onWidthChanged: setShowVideoElements()

    property bool isPlaying: false



    property string mainColor: "#151515"
    property string secondColor: "#59D5E0"
    property string thirdColor: "#ffffff"
    property int currentIndex: -1
    property int counter: 0
    property int loadingCounter: 0
    property bool isFirstRun: true
    property bool isSetShowVideoElements: false

    function setVideoUrl(videoId)
    {
        webView.url = "https://www.youtube.com/watch?v=" + videoId
        currentVideoText.text = playlistModel.get(currentIndex).title
        videoThumbnail.source = playlistModel.get(currentIndex).thumbnail
        // showVideo.checked = false
        // showVideo.enabled = false
        isSetShowVideoElements = false
        busyIndicatorBackground.visible = true
        playPauseButton.enabled = false
    }

    function detectAd()
    {
        webView.runJavaScript("let adButtonIcon = document.querySelector('span.ytp-ad-button-icon');adButtonIcon === null;", function(result)
        {
            if (result)
            {
                console.log("Add not detect!");
                loadingCounter = 0
                loadingProcess()
            }
            else
            {
                console.log("Add detected!");
                webView.reload()
            }
        })
    }

    function loadingProcess()
    {
        webView.runJavaScript("document.querySelector('video').duration;", function(duration)
        {
            if (typeof duration === 'undefined') {
                console.log("DURATION ERROR");
                if  (loadingCounter < 10)
                {
                    Qt.callLater(function()
                    {
                        loadingCounter ++
                        loadingProcess()
                        return
                    })
                }
                else
                {
                    cantPlayVideo()
                    return
                }
            }


            console.log("Video element found!")

            slider.updating = true
            slider.to = duration;
            timer.running = true
            isPlaying = true
            playPauseButton.enabled = true

        })
    }

    function cantPlayVideo()
    {
        currentVideoText.text = "Sorry! We cant play this video."
        playPauseButton.enabled = false
    }


    function setShowVideoElements()
    {
        console.log("Video Elements Setting!")
        webView.runJavaScript
                ("
                document.querySelector('video').style.position = 'fixed'
                document.querySelector('video').style.height = '100%'
                document.querySelector('video').style.width = 'auto'
                document.querySelector('video').style.visibility = 'visible'
                document.querySelector('body').style.visibility = 'hidden'
                ")

        // showVideo.enabled = true

        busyIndicatorBackground.visible = false

        console.log("Video Elements Set!")

    }


    function nextVideo()
    {
        currentIndex++

        Qt.callLater(function()
        {
            setVideoUrl(playlistModel.get(currentIndex).videoId)
        })
    }

    function previousVideo()
    {
        currentIndex--
        Qt.callLater(function()
        {
            setVideoUrl(playlistModel.get(currentIndex).videoId)
        })
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
                nextVideo()
                isFirstRun = false
                webView.reload()
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
            anchors.bottomMargin: 5
            width: parent.width
            spacing: 5


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
        anchors.topMargin: -50
        // anchors.leftMargin: -100
        // anchors.rightMargin: -100
        anchors.bottomMargin: -50
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: bottomBackgroundLine.top

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
        id: busyIndicatorBackground
        anchors.fill: webView
        color: mainColor

        BusyIndicator
        {
            id: busyIndicator
            anchors.centerIn: parent
            running: true
            visible: true
            width: 100
            height: 100
            palette.dark: secondColor
        }
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
        anchors.bottom: bottomBackgroundLine.top
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
        width: 110
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
        height: 105
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

    Rectangle
    {
        width: currentVideoText.width + 15
        height: currentVideoText.height + 10
        anchors.bottom: slider.top
        anchors.horizontalCenter: parent.horizontalCenter
        border.color: secondColor
        radius: 5
        color: secondColor

        Text {
            id: currentVideoText
            anchors.centerIn: parent
            color: mainColor
            font.pixelSize: 13
        }
    }

    Button
    {
        id: playPauseButton
        icon.source: isPlaying ? "assets/pause.svg" : "assets/play.svg"
        icon.color: secondColor
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 5

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

        background: Rectangle
        {
            border.color: secondColor
            radius: 10
            color: mainColor
        }

        onClicked:
        {
            if(currentIndex < playlistView.model.count - 1)
            {
                nextVideo()
            }
            else
            {
                currentIndex = -1
                nextVideo()
            }
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

        background: Rectangle
        {
            border.color: secondColor
            radius: 10
            color: mainColor
        }

        onClicked:
        {
            if (slider.value < 10 && currentIndex > 0)
            {
                previousVideo()
            }
            else
            {
                slider.value = 0
            }
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
