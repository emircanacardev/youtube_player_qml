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

// function playPause2(){
//     webView.runJavaScript("var video = document.querySelector('video');if (video.paused) { video.play(); } else { video.pause(); }; console.log(document) ")
// }
