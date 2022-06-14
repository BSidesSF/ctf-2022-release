console.log("Loading the Frida script");
Java.perform(function x() {
    // Class to hook into 
    var targetClass = Java.use("com.bsidessf.bridgekeeper.ThirdFragment");
    var stringClass = Java.use("java.lang.String");
    // function to hook into 
    targetClass.getSign.overload("java.lang.String").implementation = function (x) {
        // flag url 
        var data = stringClass.$new('{"Level_1":"egg","Level_2":"darkness","Level_3":"cold"}');
        // print the original url 
        console.log("Original data: " + x);
        // pass our string 
        console.log("Updated data:" + data);
        var ret = this.getSign(data);
        console.log("Return from Frida script");
        return ret;
    };
    targetClass.getPrefs.overload().implementation = function (x) {
        var data = stringClass.$new('{"Level_1":"egg","Level_2":"darkness","Level_3":"cold"}');
        return data; 
    };
});