console.log(window.screen.width)
if (window.screen.width <= 1080) {
    console.log("made it")
    document.getElementsByClassName("sidebar-left")[0].style.display = "none";
    document.getElementsByClassName("sidebar-right")[0].style.display = "none";
    const dividers = document.getElementsByClassName("content-divider");
    for (let d of dividers) {
        d.style.display = "none";
    }
}

