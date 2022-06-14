console.log("Loading the Frida script");
Java.perform(function x() {
    // Class to hook into 
    var targetClass = Java.use("com.bsidessf.arboretum.MainActivity");
    var stringClass = Java.use("java.lang.String");
    // function to hook into 
    targetClass.createShortLink.overload("java.lang.String").implementation = function (x) {
        // flag url 
        var url = stringClass.$new("https://storage.cloud.google.com/arboretum-images-2022/flag.png");
        // print the original url 
        console.log("Original url: " + x);
        // pass our string 
        var ret = this.createShortLink(url);
        console.log("Return from Frida script");
        return ret;
    };
});