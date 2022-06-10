package com.bsidessf.bridgekeeper;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Build;
import android.os.Bundle;
import android.util.Base64;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;

import com.bsidessf.bridgekeeper.databinding.FragmentThirdBinding;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.GetTokenResult;
import com.google.firebase.firestore.FirebaseFirestore;

import org.jetbrains.annotations.NotNull;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.FormBody;
import okhttp3.HttpUrl;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import java.net.URL;
import java.security.InvalidKeyException;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.Signature;
import java.security.SignatureException;
import java.security.UnrecoverableEntryException;
import java.security.cert.CertificateException;
import java.util.HashMap;
import java.util.Map;


public class ThirdFragment extends Fragment {

    private FragmentThirdBinding binding;
    private FirebaseFirestore mDB;
    private static String dbPath = "users";
    private static String dbKey = "key";
    private static String dbData = "data";
    private static String dbSign = "signature";
    private  static String uid = null;
    final OkHttpClient client = new OkHttpClient();
    private String responseStr;

    @Override
    public View onCreateView(
            LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState
    ) {

        binding = FragmentThirdBinding.inflate(inflater, container, false);
        return binding.getRoot();

    }

    public void onViewCreated(@NonNull View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        binding.submitThreeButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                String progressData = getPrefs();
                byte[] progressSign = getSign(progressData);
                String progressSignStr =  Base64.encodeToString(progressSign,Base64.NO_WRAP);
                storeDb(progressData, progressSignStr);
                Log.d("Progress:",progressData);
                Log.d("Signature", progressSignStr);
                Log.d("Signature Valid:",String.valueOf(verifySign(progressData,progressSign)));
                }
        });
    }
    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }

    // Get current progress as json string
    private String getPrefs(){
        Context context = getActivity();
        SharedPreferences sharedPref = context.getSharedPreferences(
                getString(R.string.preference_file_key), Context.MODE_PRIVATE);
        String levelOne = sharedPref.getString(getResources().getString(R.string.first_level),"null");
        String levelTwo = sharedPref.getString(getResources().getString(R.string.second_level),"null");
        String levelThree = sharedPref.getString(getResources().getString(R.string.third_level),"null");
        JSONObject jsonObject = new JSONObject();
        try{
            jsonObject.put(getResources().getString(R.string.first_level),levelOne);
            jsonObject.put(getResources().getString(R.string.second_level),levelTwo);
            jsonObject.put(getResources().getString(R.string.third_level),levelThree);
        }
        catch (JSONException e){
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

    // Sign the current progress
    private byte[] getSign(String data){
        KeyStore ks = null;
        try {
            ks = KeyStore.getInstance("AndroidKeyStore");
        } catch (KeyStoreException e) {
            e.printStackTrace();
        }
        try {
            ks.load(null);
        } catch (CertificateException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        }
        KeyStore.Entry entry = null;
        try {
            entry = ks.getEntry("sign", null);
        } catch (KeyStoreException e) {
            e.printStackTrace();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        } catch (UnrecoverableEntryException e) {
            e.printStackTrace();
        }
        if (!(entry instanceof KeyStore.PrivateKeyEntry)) {
            Log.w("Error", "Not an instance of a PrivateKeyEntry");
        }
        Signature s = null;
        try {
            s = Signature.getInstance("SHA256withRSA");
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        }
        try {
            s.initSign(((KeyStore.PrivateKeyEntry) entry).getPrivateKey());
        } catch (InvalidKeyException e) {
            e.printStackTrace();
        }
        try {
            s.update(data.getBytes());
            byte[] signature = s.sign();
            return signature;
        } catch (SignatureException e) {
            e.printStackTrace();
        }
        return null;
    }

    private boolean verifySign(String data, byte[] signature){
        KeyStore ks = null;
        try {
            ks = KeyStore.getInstance("AndroidKeyStore");
        } catch (KeyStoreException e) {
            e.printStackTrace();
        }
        try {
            ks.load(null);
        } catch (CertificateException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        }
        KeyStore.Entry entry = null;
        try {
            entry = ks.getEntry("sign", null);
        } catch (KeyStoreException e) {
            e.printStackTrace();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        } catch (UnrecoverableEntryException e) {
            e.printStackTrace();
        }
        if (!(entry instanceof KeyStore.PrivateKeyEntry)) {
            Log.w("Error:", "Not an instance of a PrivateKeyEntry");
            return false;
        }
        Signature s = null;
        try {
            s = Signature.getInstance("SHA256withRSA");
            s.initVerify(((KeyStore.PrivateKeyEntry) entry).getCertificate());
            s.update(data.getBytes());
            boolean valid = s.verify(signature);
            return valid;
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        } catch (SignatureException e) {
            e.printStackTrace();
        } catch (InvalidKeyException e) {
            e.printStackTrace();
        }
        return false;
    }

    private void storeDb(String data, String signature){
        FirebaseAuth mAuth = FirebaseAuth.getInstance();
        uid = mAuth.getCurrentUser().getUid();
        Log.d("user:",uid);
        Map<String, Object> user = new HashMap<>();
        user.put(dbData, data);
        user.put(dbSign, signature);
        mDB = FirebaseFirestore.getInstance();
        mDB.collection(dbPath).document(uid)
                .set(user)
                .addOnSuccessListener(new OnSuccessListener<Void>() {
                    @Override
                    public void onSuccess(Void aVoid) {
                        Log.d("Writing key to DB:", "success");
                        getidToken();
                    }

                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        Log.w("Writing key to DB:", "error", e);

                    }
                });

    }

    private void getidToken(){
        String idToken = null;
        FirebaseUser mUser = FirebaseAuth.getInstance().getCurrentUser();
        mUser.getIdToken(true)
                .addOnCompleteListener(new OnCompleteListener<GetTokenResult>() {
                    public void onComplete(@NonNull Task<GetTokenResult> task) {
                        if (task.isSuccessful()) {
                            String idToken = task.getResult().getToken();
                            //Log.d("token",idToken);
                            getFlag(idToken);
                        } else {
                            Log.w("Token Fetch","Failed");
                        }
                    }
                });
    }

    private String getFlag(String token){
        // to-do update server URL
       HttpUrl.Builder urlBuilder = HttpUrl.parse("https://bridgekeeper-e1f23910.challenges.bsidessf.net/get-flag").newBuilder();
       urlBuilder.addQueryParameter("token",token);
       String url = urlBuilder.build().toString();
       Log.d("url",url);
        Request request = new Request.Builder()
                .url(url)
                .build();
        client.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(@NotNull Call call, @NotNull IOException e) {
                e.printStackTrace();
            }

            @Override
            public void onResponse(@NotNull Call call, @NotNull Response response) throws IOException {
                responseStr = response.body().string();
                Log.d("Response:",responseStr);
            }
        });
        return responseStr;
    }

}