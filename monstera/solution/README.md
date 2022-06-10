The flag is base 64 encoded and split across four locations, 
* Part 1 is in ``res/strings.xml`` - ``<string name="part1">Q1RGe1JldjNyczM=</string>``
	* Decodes to ``CTF{Rev3rs3``
* Part 2 is a string in ``FirstFragement.java`` - ``String part2 = "VGgzQXBw";``
	* Decodes to ``Th3App``
* Part 3 is in ``SecondFragment.java`` as an int array with the ascii code of the base64 encoded string - int ``part3[] = {84,106,66,51};``
	* Decodes to ``N0w``
* Part 4 is in ``ThirdFragment.java`` split across three parts, which results in ``WWF5fQ==``
	* ``String part4_1 = "W";``
	* ``String part4_2 = "F5fQ==";``
	* ``String part4 = part4_1 + part4_1 + part4_2;``
	* Decodes to ``Yay}``