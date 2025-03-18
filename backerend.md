# Deploy headless server for catching the cameras rtmp stream, then do the overlay and restream it
## Catching RTMP Stream
We need to set up nginx with the nginx-mod-rtmp module
`yay -S nginx nginx-mod-rtmp`
*Be aware that of March 2025 the nginx-mod-rtmp package doesnt update that frequently and therefor needs an old nginx version.*
Then install/configure the rtmp server and the http server, which will host the frontend site with `make js backer-install`
## glue rtmp and website together and restream it
Install Dependencies:
TODO gstreamer has to be compiled manually probably. Find alternative?
Then just run the backerend script.
`backerend <RTMP Output Stream>`
