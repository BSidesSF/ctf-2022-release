package com.bsidessf.bridgekeeper.models;
import androidx.annotation.Keep;

import com.google.firebase.firestore.Exclude;
import com.google.firebase.firestore.IgnoreExtraProperties;

import java.io.Serializable;
import java.security.PublicKey;
import java.util.HashMap;
import java.util.Map;
@Keep
@IgnoreExtraProperties
public class User  implements Serializable {
    private String key;
    private String data;
    private String signature;
    public User() {
        // Default constructor required for calls to DataSnapshot.getValue(Post.class)
    }
    public User(String key) {
        this.key = key;
    }
    public User(String key, String data, String signature) {
        this.key = key;
        this.data = data;
        this.signature = signature;
    }
    @Exclude
    public Map<String, Object> toMap() {
        HashMap<String, Object> result = new HashMap<>();
        result.put("key", key);
        result.put("data", data);
        result.put("signature",signature);
        return result;
    }
}