package com.bsidessf.bridgekeeper;

import android.content.Context;
import android.content.SharedPreferences;

public class Util {
    private static String answerOne = "656767";
    private static String answerTwo = "6461726b6e657373";
    private static String answerThree = "636f6c64";

    // From https://www.baeldung.com/java-convert-hex-to-ascii
    public static String asciiToHex(String asciiStr) {
        asciiStr = asciiStr.toLowerCase();
        char[] chars = asciiStr.toCharArray();
        StringBuilder hex = new StringBuilder();
        for (char ch : chars) {
            hex.append(Integer.toHexString((int) ch));
        }

        return hex.toString();
    }

    public static String hexToAscii(String hexStr) {
        StringBuilder output = new StringBuilder("");

        for (int i = 0; i < hexStr.length(); i += 2) {
            String str = hexStr.substring(i, i + 2);
            output.append((char) Integer.parseInt(str, 16));
        }

        return output.toString();
    }

    public static boolean validateAnswer(int question, String userAnswer){
        boolean validity = false;
        userAnswer = userAnswer.toLowerCase();
        switch(question){
            case 1:
                    if(userAnswer.equals(hexToAscii(answerOne))){
                        validity = true;
                }
                break;
            case 2:
                if(userAnswer.equals(hexToAscii(answerTwo))){
                validity = true;
            }
            break;
            case 3:
                if(userAnswer.equals(hexToAscii(answerThree))){
                validity = true;
            }
            break;
            default:
                validity = false;
                break;

        }
        return validity;

    }
}
