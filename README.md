# SBXcodeDownloader

Downloading XCode and other developer tools from Apple's website is made hassel free.

* You dont have to download XCode again and again because your download got interrupted anymore.
* You dont have to worry about your flaky network connection or your mac's battery status while downloading humongous XCode.
* You dont have to use various chrome plugins to get `cookies.txt` to work with `wget`.
* You dont have to remember various command line arguments of `wget` just to download XCode once in a while.

# How to use it?
Simply download/clone the repo and run the code. Once Downloader app opens up follow the instructions

![instruction gif](https://s7.gifyu.com/images/ezgif.com-video-to-gif-1995af970310d3228.gif)

1. Choose the folder to download your xcode or any other developer tool.
1. Login to your developer account
1. Select the developer tool you wish to download

Thats it, now grab a cup of coffee and relax, while Downloader ensures safe downloading.

# Requirement 
Make sure you have `wget` installed in your mac. If you dont have `wget` simply run `brew install wget` to install it. If you still face issue with instlling `wget` follow [tutorial](https://www.fossmint.com/install-and-use-wget-on-mac/)

# Misc
Though the name of the product says Xcode Downloader, it can download any of the developer tool provided by apple on its official site.

Your file will be downloaded to selected folder. Along with the file you intend to download you will find `cookies.txt` and `logs.txt` files. You can use `cookies.txt` file to work with `wget` command if you decide to experiment with it yourself. You can always look at `logs.txt` to find what went wrong with your downloading. 

Because under the hood SBXcodeDownloader uses plain `wget` you can find help online help easily, if you happen to face any issue with your download.

Feel free to contribute to code
