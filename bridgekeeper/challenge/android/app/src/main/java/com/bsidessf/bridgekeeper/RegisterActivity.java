package com.bsidessf.bridgekeeper;

import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Build;
import android.security.keystore.KeyGenParameterSpec;
import android.security.keystore.KeyProperties;
import android.text.TextUtils;
import android.util.Base64;
import android.util.Patterns;
import android.widget.EditText;
import android.widget.Button;
import android.widget.Toast;
import android.os.Bundle;
import android.view.View;
import android.util.Log;

import androidx.annotation.NonNull;


import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.common.base.Splitter;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.firestore.FirebaseFirestore;
import java.io.IOException;
import java.io.StringWriter;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.Signature;
import java.security.SignatureException;
import java.security.UnrecoverableEntryException;
import java.security.cert.Certificate;
import java.security.cert.CertificateEncodingException;
import java.security.cert.CertificateException;
import java.util.HashMap;
import java.util.Map;


public class RegisterActivity extends AppCompatActivity {
    private FirebaseAuth mAuth;
    private static final String TAG = "EmailPassword";
    EditText mEmail;
    EditText mPassword;
    EditText mPassword2;
    Button mButton;
    private FirebaseFirestore mDB;
    private static String dbPath = "certs";
    private static String dbCert = "cert";
    private static String uid = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_register);
        // For Firebase Auth
        mAuth = FirebaseAuth.getInstance();
        // For Firebase Database
        mDB = FirebaseFirestore.getInstance();
        // Getting UI elements
        mEmail = (EditText) findViewById(R.id.username);
        mPassword = (EditText) findViewById(R.id.password);
        mPassword2 = (EditText) findViewById(R.id.password2);
        mButton = (Button) findViewById(R.id.register);
        mButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                createAccount(mEmail.getText().toString(), mPassword.getText().toString());
            }
        });
    }

    private void createAccount(String email, String password) {
        Log.d(TAG, "createAccount:" + email);
        if (!validateForm()) {
            return;
        }


        // [START create_user_with_email]
        mAuth.createUserWithEmailAndPassword(email, password)
                .addOnCompleteListener(this, new OnCompleteListener<AuthResult>() {
                    @RequiresApi(api = Build.VERSION_CODES.O)
                    @Override
                    public void onComplete(@NonNull Task<AuthResult> task) {
                        if (task.isSuccessful()) {
                            // Sign in success, update UI with the signed-in user's information
                            Log.d(TAG, "createUserWithEmail:success");
                            uid = mAuth.getCurrentUser().getUid();
                            // Generate keypair and save public key to database
                            createKeys();
                            // Store the key
                            storeDb(getCertificate());
                            // Start Main Activity
                            Intent intent = new Intent(RegisterActivity.this, MainActivity.class);
                            startActivity(intent);
                        } else {
                            // If sign in fails, display a message to the user.
                            Log.w(TAG, "createUserWithEmail:failure", task.getException());
                            Toast.makeText(RegisterActivity.this, "Authentication failed.",
                                    Toast.LENGTH_SHORT).show();
                        }
                    }
                });
        // [END create_user_with_email]
    }

    // Make sure email and password is entered
    // Make sure password and confirm password match

    private boolean validateForm() {
        boolean valid = true;
        String email = mEmail.getText().toString();
        CharSequence emailChars = mEmail.getText();
        if (TextUtils.isEmpty(email)) {
            mEmail.setError("Required.");
            valid = false;
        } else if (!validateEmail(emailChars)) {
            mEmail.setError("Should be valid Email");
            valid = false;
        } else {
            mEmail.setError(null);
        }

        String password = mPassword.getText().toString();
        if (TextUtils.isEmpty(password)) {
            mPassword.setError("Required.");
            valid = false;
        } else {
            mPassword.setError(null);
        }

        if (password.length() < 6) {
            mPassword.setError("Password must be atleast 6 characters");
            valid = false;
        }

        String password2 = mPassword2.getText().toString();
        if (TextUtils.isEmpty(password)) {
            mPassword2.setError("Required.");
            valid = false;
        } else {
            mPassword2.setError(null);
        }

        if (!password.equals(password2)) {
            mPassword2.setError("Passwords should match.");
            valid = false;
        }
        return valid;
    }


    // Make sure user entered an email address
    private boolean validateEmail(CharSequence input) {
        return Patterns.EMAIL_ADDRESS.matcher(input).matches();
    }

    // Create keypair for the user
    private void createKeys() {
        KeyPairGenerator kpg = null;
        try {
            kpg = KeyPairGenerator.getInstance(
                    KeyProperties.KEY_ALGORITHM_RSA, "AndroidKeyStore");
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        } catch (NoSuchProviderException e) {
            e.printStackTrace();
        }

        try {
            kpg.initialize(new KeyGenParameterSpec.Builder(
                    "sign",
                    KeyProperties.PURPOSE_SIGN | KeyProperties.PURPOSE_VERIFY)
                    .setKeySize(2048)
                    .setDigests(KeyProperties.DIGEST_SHA256)
                    .setSignaturePaddings(KeyProperties.SIGNATURE_PADDING_RSA_PKCS1)
                    .build());
        } catch (InvalidAlgorithmParameterException e) {
            e.printStackTrace();
        }

        KeyPair keypair = kpg.generateKeyPair();
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    private void storeDb(String cert) {
        Map<String, Object> user = new HashMap<>();
        user.put(dbCert, cert);
        mDB.collection(dbPath).document(uid)
                .set(user)
                .addOnSuccessListener(new OnSuccessListener<Void>() {
                    @Override
                    public void onSuccess(Void aVoid) {
                        Log.d("Writing key to DB:", "success");
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        Log.w("Writing key to DB:", "error", e);
                    }
                });

    }

    private String getCertificate() {
        KeyStore ks = null;
        String keyStr = null;
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
        }
        Certificate cert = ((KeyStore.PrivateKeyEntry) entry).getCertificate();
        try {
            keyStr = Base64.encodeToString(cert.getPublicKey().getEncoded(),Base64.NO_WRAP);
            //Log.d("Public Key encoded",keyStr);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return keyStr;
    }

}