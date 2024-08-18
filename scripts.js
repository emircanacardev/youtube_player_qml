function playPause() {
    var video = document.querySelector('video')
    if (video.paused) {
        video.play()
        return "Pause"
    }
    else {
        video.pause()
        return "Play"
    }
}

//java script kodlarını ayrı dosyadan çekmeyi çözemedim. çözersem güncellenecek.

