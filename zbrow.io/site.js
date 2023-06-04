console.log(window.screen.width)

function setSmolScreenContent() {

    if (window.screen.width <= 601) {
        console.log("smol device")
        document.getElementsByClassName("sidebar-left")[0].style.display = "none";
        document.getElementsByClassName("sidebar-right")[0].style.display = "none";
        const dividers = document.getElementsByClassName("content-divider");
        for (let d of dividers) {
            d.style.display = "none";
        }
        const menubarCenteredItems = document.querySelectorAll("div.site-menubar");
        for (let i of menubarCenteredItems) {
            i.style.display = "none";
        }

        const siteLogoLink = document.createElement("a");
        siteLogoLink.href = "/";

        const siteLogo = document.createElement("img");
        siteLogo.src = "img/site-logo.jpeg";
        siteLogo.style.display = "block";
        siteLogo.style.margin = "0 auto";
        siteLogo.setAttribute("width", "50px");
        siteLogo.setAttribute("height", "50px");

        siteLogoLink.appendChild(siteLogo);

        const seeDesktopPageBanner = document.createElement("p");
        seeDesktopPageBanner.innerHTML = "Rotate your screen and refresh the page to see more content!";
        seeDesktopPageBanner.style.cssText = "text-align: center"

        document.body.prepend(seeDesktopPageBanner);
        document.body.prepend(siteLogoLink);

    }
}

setSmolScreenContent()
