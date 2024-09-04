import QtQuick 2.15
import QtQuick.Controls 2.15
import QtWebEngine 1.10

ApplicationWindow
{
    visible: true
    width:  1024
    height:  768
    title: "YouTube Player"

    property bool isPlaying: false
    property string mainColor: "#151515"
    property string secondColor: "#59D5E0"
    property string thirdColor: "#ffffff"
    property int currentVideoIndex: -1
    property bool currentAction: true
    property int counter: 0
    property int loadingCounter: 0
    property int reloadCounter: 0
    property bool isFirstRun: true

    function setVideoUrl(videoId)
    {
        webView.url = "https://www.youtube.com/watch?v=" + videoId
        currentVideoText.text = videoModel.get(currentVideoIndex).title
        videoThumbnail.source = videoModel.get(currentVideoIndex).thumbnail
        busyIndicatorBackground.visible = true
        playPauseButton.enabled = false
    }

    function detectAd()
    {
        webView.runJavaScript("document.querySelector('video');", function(result)
        {
            console.log(result)
            reloadTimer.running = false

            if (result)
            {
                console.log("Video element found!")

                webView.runJavaScript("var adButtonIcon = document.querySelector('span.ytp-ad-button-icon');adButtonIcon === null;", function(result)
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
            else
            {
                reloadTimer.running = true
            }
        })
    }

    function handleLoadError()
    {
        console.log("Somethings went wrong! Reloading...")



        if (reloadCounter > 3)
        {
            console.log("Playlist refreshed!")
            currentVideoIndex = 0
            reloadCounter = 0
            isFirstRun = true
            youtubeFetcher.fetchVideoData();
        }
        else
        {
            Qt.callLater(function()
            {
                webView.reload()
            })
        }
    }

    function loadingProcess()
    {
        nextButton.enabled = true
        previousButton.enabled = true

        webView.runJavaScript("document.querySelector('video').duration;", function(duration)
        {
            if (typeof duration === 'undefined') {
                console.log("DURATION ERROR");
                if  (loadingCounter < 50)
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
            else
            {
                sliderTimer.running = true
                slider.updating = true
                slider.to = duration;
                isPlaying = true
                playPauseButton.enabled = true
                setVideoElementStyles()
            }
        })

    }

    function cantPlayVideo()
    {
        console.log("------------------------"+ videoModel.get(currentVideoIndex).canPlay + "---------------")
        currentVideoText.text = "Sorry! We cant play this video."
        if (videoModel.get(currentVideoIndex).canPlay === true)
        {
            videoModel.get(currentVideoIndex).canPlay = false
            videoModel.get(currentVideoIndex).title = " × " + videoModel.get(currentVideoIndex).title
        }

        if(currentAction)
        {
            nextVideo()
        }
        else
        {
            previousVideo()
        }
    }


    function setVideoElementStyles()
    {
        console.log("Video Elements Setting!")
        webView.runJavaScript
                ("
                var video = document.querySelector('video')
                video.style.position = 'fixed'
                video.style.height = '100%'
                video.style.width = '100%'
                document.querySelector('html').style.visibility = 'hidden'
                video.style.visibility = 'visible'
                video.volume = '1'
                ")

        console.log("Video Elements Set!")

    }


    function nextVideo()
    {
        sliderTimer.running = false
        currentAction = true // true for next

        if(currentVideoIndex < playlistView.model.count - 1)
        {
            currentVideoIndex++

            if (videoModel.get(currentVideoIndex).canPlay === false)
            {
                nextVideo()
                return
            }

            Qt.callLater(function()
            {
                setVideoUrl(videoModel.get(currentVideoIndex).videoId)
            })
        }
        else
        {
            currentVideoIndex = -1
            nextVideo()
        }
    }

    function previousVideo()
    {
        sliderTimer.running = false
        currentAction = false // false for previous

        if(currentVideoIndex > 0)
        {
            currentVideoIndex--

            if (videoModel.get(currentVideoIndex).canPlay === false)
            {
                previousVideo()
                return
            }

            Qt.callLater(function()
            {
                setVideoUrl(videoModel.get(currentVideoIndex).videoId)
            })
        }
        else
        {
            currentVideoIndex = playlistView.model.count
            previousVideo()
        }
    }

    function playPauseVideo()
    {
        webView.runJavaScript("var video = document.querySelector('video'); if (video.paused) { video.play(); } else { video.pause(); }", function(result)
        {
            if (result)
            {

                isPlaying = true
                sliderTimer.running = true

            }
            else
            {
                isPlaying = false
                sliderTimer.running = false
            }
        })
    }

    Connections
    {
        target: youtubeFetcher
        function onVideoDataFetched()
        {
            videoModel.clear()

            for (var i = 0; i < youtubeFetcher.videoList.length; i++)
            {
                var videoItem = youtubeFetcher.videoList[i];
                videoModel.append({title: videoItem.title, videoId: videoItem.videoId, thumbnail: videoItem.thumbnail, canPlay: videoItem.canPlay});
            }
            if (isFirstRun){
                nextVideo()
                isFirstRun = false
                webView.reload()
            }
        }
    }

    Connections
    {
        target: youtubeFetcher
        function onPlaylistDataFetched()
        {
            playlistModel.clear()

            for (var j = 0; j < youtubeFetcher.playlistIdList.length; j++)
            {
                var playlistIdItem = youtubeFetcher.playlistIdList[j]
                if (playlistIdItem.playlistTitle !== "")
                {
                    playlistModel.append({playlistTitle: playlistIdItem.playlistTitle, playlistId: playlistIdItem.playlistId })
                    playlistInput.text = ""
                    playlistInput.placeholderText = "Playlist added!"
                }
                else
                {
                    playlistInput.placeholderText = "Playlist not found!"
                }
            }

            currentPlaylistText.text = playlistModel.get(playlistIdView.model.count - 1).playlistTitle
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

        onClosed:
        {
            playlistIdListDrawer.close()
        }

        Rectangle{
            id: drawerButtonArea
            anchors.top: parent.top
            anchors.left: parent.left
            width: parent.width
            height: 45
            color: secondColor

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
                    youtubeFetcher.fetchVideoData();
                }
            }

            Popup
            {
                id: playlistIdListDrawer
                x: playlistInput.x
                y: playlistInput.height + 5
                width: playlistInput.width
                height: 150

                background: Rectangle {
                    anchors.fill: parent
                    border.color: secondColor
                    radius: 10
                    color: mainColor
                }

                ListView
                {
                    id: playlistIdView
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width
                    spacing: 5
                    clip: true


                    model: ListModel
                    {
                        id: playlistModel
                    }

                    delegate: Item
                    {
                        width: playlistIdView.width
                        height: playlistInput.height

                        Button
                        {
                            id: playlistIdButton
                            width: parent.width
                            anchors.horizontalCenter: parent.horizontalCenter

                            contentItem: Text
                            {
                                width: parent.width
                                text: model.playlistTitle
                                color: youtubeFetcher.playlistId === model.playlistId ? secondColor : mainColor
                                elide: Text.ElideRight
                                font.pixelSize: 13
                            }

                            onClicked:
                            {
                                console.log("Playlist refreshed!")
                                isFirstRun = true
                                currentVideoIndex = -1
                                currentPlaylistText.text = model.playlistTitle
                                youtubeFetcher.setPlaylistId(model.playlistId)
                                youtubeFetcher.fetchVideoData()
                            }

                            background: Rectangle
                            {
                                height: 30
                                border.width: 2
                                border.color: youtubeFetcher.playlistId === model.playlistId ? secondColor : mainColor
                                radius: 10
                                color: youtubeFetcher.playlistId === model.playlistId ? mainColor : secondColor
                            }
                        }
                    }
                }
            }

            TextField {
                id: playlistInput
                placeholderText: "Enter Playlist URL"
                anchors.left: playlistIdListOpenButton.right
                anchors.right: autoRefresh.left
                anchors.top: parent.top
                anchors.rightMargin: 5
                anchors.topMargin: 5
                anchors.leftMargin: -1
                height: closeDrawerButton.height
                color: secondColor

                background: Rectangle
                {
                    border.color: secondColor
                    radius: 10
                    color: mainColor
                }

                Button
                {
                    id: addPlaylistButton
                    icon.source: "assets/plus.svg"
                    icon.color: secondColor
                    anchors.top: parent.top
                    anchors.right: parent.right

                    background: Rectangle
                    {
                        border.color: secondColor
                        radius: 10
                        color: mainColor
                    }

                    onClicked:
                    {
                        if(playlistInput.text !== "")
                        {
                            console.log("Playlist refreshed!")
                            isFirstRun = true
                            currentVideoIndex = -1
                            youtubeFetcher.fetchPlaylistData(playlistInput.text.trim())
                            youtubeFetcher.fetchVideoData()
                        }
                    }
                }
            }

            Button
            {
                id: playlistIdListOpenButton
                anchors.left: closeDrawerButton.right
                anchors.top: parent.top
                anchors.leftMargin: 5
                anchors.topMargin: 5
                height: closeDrawerButton.height
                icon.source: playlistIdListDrawer.opened ? "assets/arrow-down.svg" : "assets/arrow-right.svg"
                icon.color: secondColor
                enabled: playlistIdListDrawer.opened ? false : true

                background: Rectangle
                {
                    border.color: secondColor
                    radius: 10
                    color: mainColor
                }

                onClicked:
                {
                    playlistIdListDrawer.open()
                }
            }
        }

        Rectangle
        {
            id: currentPlaylistTextBackground
            width: currentPlaylistText.width + 25
            height: currentPlaylistText.height + 20
            anchors.top: drawerButtonArea.bottom
            anchors.left: parent.left
            anchors.leftMargin: 5
            color: secondColor
            border.color: mainColor
            border.width: 5
            radius: 10

            Text {
                id: currentPlaylistText
                anchors.centerIn: parent
                color: mainColor
                font.pixelSize: 15
            }
        }

        ListView
        {
            id: playlistView
            anchors.top: currentPlaylistTextBackground.bottom
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
            anchors.topMargin: 5
            width: parent.width
            spacing: 5
            clip: true



            model: ListModel
            {
                id: videoModel
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

                    contentItem: Text
                    {
                        width: parent.width
                        text: model.title
                        color: model.index === currentVideoIndex ? mainColor : secondColor
                        elide: Text.ElideRight
                        font.pixelSize: 13
                    }

                    onClicked:
                    {
                        currentVideoIndex = index
                        setVideoUrl(model.videoId)
                        videoThumbnail.source = model.thumbnail

                    }

                    background: Rectangle
                    {
                        height: 30
                        border.width: model.index === currentVideoIndex ? 5 : 2
                        border.color: model.index === currentVideoIndex ? mainColor : secondColor
                        radius: 10
                        color: model.index === currentVideoIndex ? secondColor : mainColor
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
        visible: true
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
            playlistInput.placeholderText = "Enter Playlist URL"
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
        icon.color: secondColor
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
            nextButton.enabled = false
            nextVideo()
        }
    }

    Button
    {
        id: previousButton
        icon.source: "assets/previous.svg"
        icon.color: secondColor
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
            previousButton.enabled = false

            if (slider.value < 10)
            {
                previousVideo()
            }
            else
            {
                slider.value = 0
            }
        }
    }

    Slider {
        id: slider
        value: 0
        from: 0
        to: 200
        width: parent.width - 200
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

    Rectangle
    {
        width: currentVideoTime.width + 15
        height: currentVideoTime.height + 10
        anchors.top: slider.top
        anchors.bottom: slider.bottom
        anchors.right: slider.left
        border.color: secondColor
        radius: 5
        color: secondColor

        Text {
            id: currentVideoTime
            anchors.centerIn: parent
            text:
            {
                var minutes = Math.floor(slider.value);
                var hours = Math.floor(minutes / 60);
                var remainingMinutes = minutes % 60;
                return hours + ":" + (remainingMinutes < 10 ? "0" : "") + remainingMinutes;
            }
            color: mainColor
            font.pixelSize: 13
        }
    }

    Rectangle
    {
        width: 50
        height: 10
        anchors.top: slider.top
        anchors.bottom: slider.bottom
        anchors.left: slider.right
        border.color: secondColor
        radius: 5
        color: secondColor

        Text {
            id: totalVideoTime
            anchors.centerIn: parent
            text:
            {
                var minutes = Math.floor(slider.to);
                var hours = Math.floor(minutes / 60);
                var remainingMinutes = minutes % 60;
                return hours + ":" + (remainingMinutes < 10 ? "0" : "") + remainingMinutes;
            }
            color: mainColor
            font.pixelSize: 13
        }
    }

    Timer
    {
        id: autoRefreshTimer
        interval: 1000*10 //(1000 ms = 1 s)
        repeat: true
        running: true

        onTriggered:
        {
            if (autoRefresh.checked)
            {
                isFirstRun = false
                youtubeFetcher.fetchVideoData()
                console.log("Playlist Refreshed!")
            }


        }
    }

    Timer
    {
        id: sliderTimer
        interval: 1000 //(1000 ms = 1 s)
        repeat: true

        onTriggered:
        {
            slider.updating = false
            slider.value ++
            slider.updating = true

            if (slider.value < 5)
            {
                try
                {
                    setVideoElementStyles()
                }
                catch (error)
                {
                    console.log("setShow Error: " + error)
                }
            }

            if (slider.value > 2)
            {
                busyIndicatorBackground.visible = false
            }


       }
    }

    Timer
    {
        id: reloadTimer
        interval: 1000 //(1000 ms = 1 s)
        repeat: true

        onTriggered:
        {
            handleLoadError()
            reloadCounter ++
        }
    }

    Timer
    {
        id: timer
        interval: 1000 //(1000 ms = 1 s)
        repeat: true
        running: true
        onTriggered:
        {

            if (slider.value === slider.to)
            {
                if (currentVideoIndex < playlistView.model.count - 1)
                {
                    nextVideo()
                }
                else
                {
                    currentVideoIndex = 0
                    Qt.callLater(function()
                    {
                        setVideoUrl(videoModel.get(currentVideoIndex).videoId)
                    })
                    videoThumbnail.source = videoModel.get(currentVideoIndex).thumbnail
                }
            }
        }
    }

    // Dialog {
    //     id: warningDialog
    //     modal: true

    //     Text {
    //         text: "Sorry! We can not open this video. Next video opening!"
    //         font.pixelSize: 18
    //         anchors.centerIn: parent
    //     }
    // }

    // Button
    // {
    //     anchors.centerIn: parent
    //     width: 50
    //     height: 50
    //     visible: true


    //     onClicked:
    //     {
    //         warningDialog.open()
    //     }
    // }
}
