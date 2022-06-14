Use Frida to hook into signData() function and modify the function arg to ``{"Level_1":"egg","Level_2":"darkness","Level_3":"cold"}``. 
* The app creates a keypair during registration and sends it to the server 
* When you press the ``Get Flag`` button, it fetches your progress from the Shared preferences, signs it and send it to the server
* The server will calculate the sign of the data and compare it with the sign of the completed progress string - ``{"Level_1":"egg","Level_2":"darkness","Level_3":"cold"}``
* You can solve the challenge by using Frida to hook into signData() function and modify the function arg to ``{"Level_1":"egg","Level_2":"darkness","Level_3":"cold"}``.
* You'll also need to modify the getPrefs() function to return the string - ``{"Level_1":"egg","Level_2":"darkness","Level_3":"cold"}``
* Run this command to deploy your Frida script, ``frida -U -f com.bsidessf.arboretum -l solution.js --no-pause``
* You'll see the flag in logcat 
* Alternative solution: you can modify com.bsidessf.bridgekeeper.xml to the following, this solution is a bit flaky since the app might overwrite the file. 
```
	<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
	<map>
    <string name="Level_3">cold</string>
    <string name="Level_2">darkness</string>
    <string name="Level_1">egg</string>
	</map>
```